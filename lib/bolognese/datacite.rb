module Bolognese
  class Datacite < Metadata

    DC_TO_SO_TRANSLATIONS = {
      "Audiovisual" => "VideoObject",
      "Collection" => "Collection",
      "Dataset" => "Dataset",
      "Event" => "Event",
      "Image" => "ImageObject",
      "InteractiveResource" => nil,
      "Model" => nil,
      "PhysicalObject" => nil,
      "Service" => "Service",
      "Software" => "SoftwareSourceCode",
      "Sound" => "AudioObject",
      "Text" => "ScholarlyArticle",
      "Workflow" => nil,
      "Other" => "CreativeWork"
    }

    def initialize(id: nil, string: nil)
      id = normalize_doi(id) if id.present?

      if string.present?
        @raw = string
      elsif id.present?
        response = Maremma.get(id, accept: "application/vnd.datacite.datacite+xml", raw: true)
        @raw = response.body.fetch("data", nil)
      end
    end

    alias_method :datacite, :raw
    alias_method :schema_org, :as_schema_org

    def metadata
      @metadata ||= raw.present? ? Maremma.from_xml(raw).fetch("resource", {}) : {}
    end

    def exists?
      metadata.present?
    end

    def doi
      metadata.fetch("identifier", {}).fetch("text", nil)
    end

    def id
      normalize_doi(doi)
    end

    def type
      k = metadata.dig("resourceType", "resourceTypeGeneral")
      DC_TO_SO_TRANSLATIONS[k.to_s.dasherize] || "CreativeWork"
    end

    def additional_type
      metadata.fetch("resourceType", {}).fetch("text", nil) ||
      metadata.fetch("resourceType", {}).fetch("resourceTypeGeneral", nil)
    end

    def name
      metadata.dig("titles", "title")
    end

    def alternate_name
      metadata.dig("alternateIdentifiers", "alternateIdentifier", "text")
    end

    def description
      des = metadata.dig("descriptions", "description", "text")
      if des.is_a?(Hash)
        des.to_xml
      elsif des.is_a?(String)
        des.strip
      end
    end

    def license
      metadata.dig("rightsList", "rights", "rightsURI")
    end

    def keywords
      Array.wrap(metadata.dig("subjects", "subject")).join(", ").presence
    end

    def author
      authors = metadata.dig("creators", "creator")
      authors = [authors] if authors.is_a?(Hash)
      get_authors(authors).presence
    end

    def editor
      editors = metadata.dig("contributors", "contributor")
      editors = [editors] if editors.is_a?(Hash)
      get_authors(editors).presence
    end

    def version
      metadata.fetch("version", nil)
    end

    def dates
      Array.wrap(metadata.dig("dates", "date"))
    end

    def date(date_type)
      dd = dates.find { |d| d["dateType"] == date_type } || {}
      dd.fetch("text", nil)
    end

    def date_created
      date("Created")
    end

    def date_published
      date("Issued") || metadata.fetch("publicationYear")
    end

    def date_modified
      date("Updated")
    end

    def related_identifiers(relation_type)
      Array(metadata.dig("relatedIdentifiers", "relatedIdentifier"))
        .select { |r| relation_type.split(" ").include?(r["relationType"]) && %w(DOI URL).include?(r["relatedIdentifierType"]) }
        .map do |work|
          work_id = work["relatedIdentifierType"] == "DOI" ? normalize_doi(work["text"]) : work["text"]
          { "@type" => "CreativeWork",
            "@id" => work_id }
        end
    end

    def is_part_of
      related_identifiers("IsPartOf").first
    end

    def has_part
      related_identifiers("HasPart").presence
    end

    def citation
      related_identifiers("Cites IsCitedBy Supplements IsSupplementTo References IsReferencedBy").presence
    end

    def publisher
      { "@type" => "Organization",
        "name" => metadata.fetch("publisher") }
    end

    def container_title
      publisher.fetch("name", nil)
    end

    def provider
      { "@type" => "Organization",
        "name" => "DataCite" }
    end
  end
end
