require_relative 'doi'

module Bolognese
  class Crossref
    include Bolognese::Doi

    # CrossRef types from https://api.crossref.org/types
    CROSSREF_TYPE_TRANSLATIONS = {
      "proceedings" => nil,
      "reference-book" => nil,
      "journal-issue" => nil,
      "proceedings-article" => nil,
      "other" => nil,
      "dissertation" => nil,
      "dataset" => "Dataset",
      "edited-book" => "Book",
      "journal-article" => "ScholarlyArticle",
      "journal" => nil,
      "report" => "report",
      "book-series" => nil,
      "report-series" => nil,
      "book-track" => nil,
      "standard" => nil,
      "book-section" => nil,
      "book-part" => nil,
      "book" => "Book",
      "book-chapter" => nil,
      "standard-series" => nil,
      "monograph" => "book",
      "component" => nil,
      "reference-entry" => nil,
      "journal-volume" => nil,
      "book-set" => nil,
      "posted-content" => nil
    }

    attr_reader = :id, :metadata, :schema_org

    def initialize(doi)
      @id = normalize_doi(doi)

      response = Maremma.get(@id, accept: "application/vnd.crossref.unixref+xml", host: true)
      @metadata = response.body.fetch("data", {}).fetch("doi_records", {}).fetch("doi_record", {})
    end

    def exists?
      metadata.present?
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

    def type
      if metadata.dig("crossref", "journal").present?
        k = metadata.dig("crossref", "journal").keys.last
      else
        k = metadata.dig("crossref").keys.last
      end
      CROSSREF_TYPE_TRANSLATIONS[k.dasherize] || "CreativeWork"
    end

    def name
      title = bibliographic_metadata.dig("titles", "title")
      if title.is_a?(String)
        title
      elsif title.is_a?(Array)
        title.first
      else
        nil
      end
    end

    def alternate_name
      bibliographic_metadata.dig("publisher_item", "item_number", "text") ||
      bibliographic_metadata.dig("item_number", "text")
    end

    def description
      bibliographic_metadata.fetch("abstract", {}).values.first
    end

    def license
      access_indicator = Array.wrap(program_metadata).find { |m| m["name"] == "AccessIndicators" }
      case
      when access_indicator["license_ref"].is_a?(String)
        access_indicator["license_ref"]
      when access_indicator["license_ref"].is_a?(Hash)
        access_indicator.dig("license_ref", "text")
      when access_indicator["license_ref"].is_a?(Array)
        access_indicator.fetch("license_ref")
                        .find { |l| l["applies_to"] == "vor" }.fetch("text", nil)
      else nil
      end
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
      end
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
          "issn" => journal_metadata.dig("issn", "text") }
      else
        nil
      end
    end

    def citation
       citations = bibliographic_metadata.dig("citation_list", "citation")
       Array(citations).select { |c| c["doi"].present? }.map do |c|
         { "@type" => "CreativeWork",
           "@id" => normalize_doi(c["doi"]) }
       end
    end

    def provider
      { "@type" => "Organization",
        "name" => "Crossref" }
    end

    def as_schema_org
      { "@context" => "http://schema.org",
        "@type" => type,
        "@id" => id,
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
