module Bolognese
  class Crossref < Metadata

    # CrossRef types from https://api.crossref.org/types
    CR_TO_SO_TRANSLATIONS = {
      "Proceedings" => nil,
      "ReferenceBook" => "Book",
      "JournalIssue" => "PublicationIssue",
      "ProceedingsArticle" => nil,
      "Other" => "CreativeWork",
      "Dissertation" => "Thesis",
      "Dataset" => "Dataset",
      "EditedBook" => "Book",
      "JournalArticle" => "ScholarlyArticle",
      "Journal" => nil,
      "Report" => nil,
      "BookSeries" => nil,
      "ReportSeries" => nil,
      "BookTrack" => nil,
      "Standard" => nil,
      "BookSection" => nil,
      "BookPart" => nil,
      "Book" => "Book",
      "BookChapter" => "Chapter",
      "StandardSeries" => nil,
      "Monograph" => "Book",
      "Component" => "CreativeWork",
      "ReferenceEntry" => nil,
      "JournalVolume" => "PublicationVolume",
      "BookSet" => nil,
      "PostedContent" => "ScholarlyArticle"
    }

    def initialize(id: nil, string: nil)
      id = normalize_doi(id) if id.present?

      if string.present?
        @raw = string
      elsif id.present?
        response = Maremma.get(id, accept: "application/vnd.crossref.unixref+xml", host: true, raw: true)
        @raw = response.body.fetch("data", nil)
      end
    end

    alias_method :crossref, :raw
    alias_method :as_crossref, :raw
    alias_method :schema_org, :as_schema_org

    def metadata
      @metadata ||= raw.present? ? Maremma.from_xml(raw).fetch("doi_records", {}).fetch("doi_record", {}) : {}
    end

    def exists?
      metadata.present?
    end

    def doi
      bibliographic_metadata.dig("doi_data", "doi")
    end

    def url
      bibliographic_metadata.dig("doi_data", "resource")
    end

    def id
      normalize_doi(doi)
    end

    def journal_metadata
      metadata.dig("crossref", "journal", "journal_metadata").presence || {}
    end

    def bibliographic_metadata
      if metadata.dig("crossref", "journal", "journal_article").present?
        metadata.dig("crossref", "journal", "journal_article")
      else
        k = metadata.fetch("crossref", {}).keys.last
        metadata.dig("crossref", k).presence || {}
      end
    end

    def program_metadata
      bibliographic_metadata.dig("program") ||
      bibliographic_metadata.dig("crossmark", "custom_metadata", "program") || {}
    end

    def resource_type_general
      SO_TO_DC_TRANSLATIONS[type]
    end

    def type
      CR_TO_SO_TRANSLATIONS[additional_type] || "ScholarlyArticle"
    end

    def additional_type
      if metadata.dig("crossref", "journal").present?
        metadata.dig("crossref", "journal").keys.last.camelize
      else
        metadata.dig("crossref").keys.last.camelize
      end
    end

    def name
      parse_attribute(bibliographic_metadata.dig("titles", "title"))
    end

    def alternate_name
      if bibliographic_metadata.fetch("publisher_item", nil).present?
        parse_attribute(bibliographic_metadata.dig("publisher_item", "item_number"))
      else
        parse_attribute(bibliographic_metadata.fetch("item_number", nil))
      end
    end

    def description
      des = bibliographic_metadata.fetch("abstract", {}).values.first
      if des.is_a?(Hash)
        des.to_xml
      elsif des.is_a?(String)
        des
      end
    end

    def license
      access_indicator = Array.wrap(program_metadata).find { |m| m["name"] == "AccessIndicators" }
      if access_indicator.present?
        parse_attribute(access_indicator["license_ref"])
      else
        nil
      end
    end

    def author
      people("author")
    end

    def editor
      people("editor")
    end

    def people(contributor_role)
      person = bibliographic_metadata.dig("contributors", "person_name")
      Array(person).select { |a| a["contributor_role"] == contributor_role }.map do |a|
        { "@type" => "Person",
          "@id" => parse_attribute(a["ORCID"]),
          "givenName" => a["given_name"],
          "familyName" => a["surname"] }.compact
      end.presence
    end

    def date_published
      pub_date = bibliographic_metadata.fetch("publication_date", nil) ||
        bibliographic_metadata.fetch("acceptance_date", nil)
      if pub_date.present?
        get_date_from_parts(pub_date["year"], pub_date["month"], pub_date["day"])
      else
        nil
      end
    end

    def date_modified
      Time.parse(metadata.fetch("timestamp", "")).utc.iso8601
    end

    def page_start
      bibliographic_metadata.dig("pages", "first_page")
    end

    def page_end
      bibliographic_metadata.dig("pages", "last_page")
    end

    def is_part_of
      if journal_metadata.present?
        { "@type" => "Periodical",
          "name" => journal_metadata["full_title"],
          "issn" => parse_attribute(journal_metadata.fetch("issn", nil)) }.compact
      else
        nil
      end
    end

    def container_title
      is_part_of.fetch("name", nil)
    end

    def citation
       citations = bibliographic_metadata.dig("citation_list", "citation")
       Array.wrap(citations).map do |c|
         { "@type" => "CreativeWork",
           "@id" => normalize_id(c["doi"]),
           "position" => c["key"],
           "name" => c["article_title"],
           "datePublished" => c["cYear"] }.compact
       end.presence
    end

    def provider
      { "@type" => "Organization",
        "name" => "Crossref" }
    end
  end
end
