require_relative 'doi_utils'
require_relative 'datacite_utils'
require_relative 'utils'

module Bolognese
  class Crossref < Metadata
    include Bolognese::DoiUtils
    include Bolognese::Utils
    include Bolognese::DataciteUtils

    # CrossRef types from https://api.crossref.org/types
    CR_TO_SO_TRANSLATIONS = {
      "Proceedings" => nil,
      "ReferenceBook" => nil,
      "JournalIssue" => nil,
      "ProceedingsArticle" => nil,
      "Other" => nil,
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
      "Component" => nil,
      "ReferenceEntry" => nil,
      "JournalVolume" => nil,
      "BookSet" => nil,
      "PostedContent" => nil
    }

    attr_reader = :id, :metadata, :schema_org

    def initialize(doi)
      @id = normalize_doi(doi)
    end

    def raw
      response = Maremma.get(@id, accept: "application/vnd.crossref.unixref+xml", host: true, raw: true)
      @raw ||= response.body.fetch("data", nil)
    end

    def metadata
      @metadata ||= raw.present? ? Maremma.from_xml(raw).fetch("doi_records", {}).fetch("doi_record", {}) : {}
    end

    def exists?
      metadata.present?
    end

    def doi
      doi_from_url(id)
    end

    def journal_metadata
      metadata.dig("crossref", "journal", "journal_metadata").presence || {}
    end

    def bibliographic_metadata
      if metadata.dig("crossref", "journal", "journal_article").present?
        metadata.dig("crossref", "journal", "journal_article")
      else
        k = metadata.dig("crossref").keys.last
        metadata.dig("crossref", k).presence || {}
      end
    end

    def program_metadata
      bibliographic_metadata.dig("program") ||
      bibliographic_metadata.dig("crossmark", "custom_metadata", "program") || {}
    end

    def additional_type
      if metadata.dig("crossref", "journal").present?
        metadata.dig("crossref", "journal").keys.last.camelize
      else
        metadata.dig("crossref").keys.last.camelize
      end
    end

    def type
      CR_TO_SO_TRANSLATIONS[additional_type] || "CreativeWork"
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
      bibliographic_metadata.fetch("abstract", {}).values.first
    end

    def license
      access_indicator = Array.wrap(program_metadata).find { |m| m["name"] == "AccessIndicators" }
      if access_indicator.present?
        parse_attribute(access_indicator["license_ref"])
      else
        nil
      end
    end

    def keywords

    end

    def author
      person = bibliographic_metadata.dig("contributors", "person_name")
      Array(person).select { |a| a["contributor_role"] == "author" }.map do |a|
        { "@type" => "Person",
          "@id" => a["ORCID"],
          "givenName" => a["given_name"],
          "familyName" => a["surname"] }.compact
      end
    end

    def editor
      person = bibliographic_metadata.dig("contributors", "person_name")
      Array(person).select { |a| a["contributor_role"] == "editor" }.map do |a|
        { "@type" => "Person",
          "@id" => a["ORCID"],
          "givenName" => a["given_name"],
          "familyName" => a["surname"] }.compact
      end.presence
    end

    def version

    end

    def date_created

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

    def citation
       citations = bibliographic_metadata.dig("citation_list", "citation")
       Array(citations).map do |c|
         { "@type" => "CreativeWork",
           "@id" => normalize_doi(c["doi"]),
           "position" => c["key"],
           "name" => c["article_title"],
           "datePublished" => c["cYear"] }.compact
       end.presence
    end

    def related_identifiers

    end

    def provider
      { "@type" => "Organization",
        "name" => "Crossref" }
    end

    def as_schema_org
      { "@context" => "http://schema.org",
        "@type" => type,
        "@id" => id,
        "additionalType" => additional_type,
        "name" => name,
        "alternateName" => alternate_name,
        "author" => author,
        "editor" => editor,
        "description" => description,
        "license" => license,
        "datePublished" => date_published,
        "dateModified" => date_modified,
        "pageStart" => page_start,
        "pageEnd" => page_end,
        "isPartOf" => is_part_of,
        "citation" => citation,
        "provider" => provider
      }.compact
    end
  end
end
