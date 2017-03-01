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

    CR_TO_BIB_TRANSLATIONS = {
      "Proceedings" => "proceedings",
      "ReferenceBook" => "book",
      "JournalIssue" => nil,
      "ProceedingsArticle" => nil,
      "Other" => nil,
      "Dissertation" => "phdthesis",
      "Dataset" => nil,
      "EditedBook" => "book",
      "JournalArticle" => "article",
      "Journal" => nil,
      "Report" => nil,
      "BookSeries" => nil,
      "ReportSeries" => nil,
      "BookTrack" => nil,
      "Standard" => nil,
      "BookSection" => "inbook",
      "BookPart" => nil,
      "Book" => "book",
      "BookChapter" => "inbook",
      "StandardSeries" => nil,
      "Monograph" => "book",
      "Component" => nil,
      "ReferenceEntry" => nil,
      "JournalVolume" => nil,
      "BookSet" => nil,
      "PostedContent" => "article"
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

    def metadata
      @metadata ||= raw.present? ? Maremma.from_xml(raw).fetch("doi_records", {}).fetch("doi_record", {}) : {}
    end

    def exists?
      metadata.present?
    end

    def valid?
      true
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
      metadata.dig("crossref", "journal", "journal_article").presence ||
      metadata.dig("crossref", "conference", "conference_paper").presence ||
      metadata.dig("crossref", metadata.fetch("crossref", {}).keys.last).presence || {}
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

    def bibtex_type
      CR_TO_BIB_TRANSLATIONS[additional_type] || "misc"
    end

    def title
      parse_attributes(bibliographic_metadata.dig("titles", "title"))
    end

    def alternate_name
      if bibliographic_metadata.fetch("publisher_item", nil).present?
        parse_attributes(bibliographic_metadata.dig("publisher_item", "item_number"))
      else
        parse_attributes(bibliographic_metadata.fetch("item_number", nil))
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
        parse_attributes(access_indicator["license_ref"])
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
      Array.wrap(person).select { |a| a["contributor_role"] == contributor_role }.map do |a|
        { "type" => "Person",
          "id" => parse_attributes(a["ORCID"]),
          "name" => [a["given_name"], a["surname"]].join(" "),
          "givenName" => a["given_name"],
          "familyName" => a["surname"] }.compact
      end.unwrap
    end

    def funder
      fundref = Array.wrap(program_metadata).find { |a| a["name"] == "fundref" } || {}
      Array.wrap(fundref.fetch("assertion", [])).select { |a| a["name"] == "fundgroup" }.map do |f|
        { "id" => normalize_id(f.dig("assertion", "assertion", "__content__")),
          "name" => f.dig("assertion", "__content__").strip }.compact
      end.unwrap
    end

    def date_published
      pub_date = Array.wrap(bibliographic_metadata.fetch("publication_date", nil)).presence ||
        Array.wrap(bibliographic_metadata.fetch("acceptance_date", nil))
      if pub_date.present?
        get_date_from_parts(pub_date.first["year"], pub_date.first["month"], pub_date.first["day"])
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
        { "type" => "Periodical",
          "name" => journal_metadata["full_title"],
          "issn" => parse_attributes(journal_metadata.fetch("issn", nil)) }.compact
      else
        nil
      end
    end

    def container_title
      is_part_of.to_h.fetch("name", nil)
    end

    alias_method :journal, :container_title

    def related_identifier(relation_type: nil)
      references
    end

    def references
       refs = bibliographic_metadata.dig("citation_list", "citation")
       Array.wrap(refs).map do |c|
         { "id" => normalize_id(c["doi"]),
           "relationType" => "Cites",
           "position" => c["key"],
           "name" => c["article_title"],
           "datePublished" => c["cYear"] }.compact
       end.unwrap
    end

    def provider
      "Crossref"
    end
  end
end
