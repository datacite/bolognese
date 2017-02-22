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

    def initialize(id: nil, string: nil, schema_version: nil)
      id = normalize_doi(id) if id.present?

      if string.present?
        @raw = string
      elsif id.present?
        response = Maremma.get(id, accept: "application/vnd.datacite.datacite+xml", raw: true)
        @raw = response.body.fetch("data", nil)
      end

      @schema_version = schema_version
    end

    alias_method :schema_org, :as_schema_org
    alias_method :bibtex, :as_bibtex

    def schema_version
      @schema_version ||= metadata.fetch("xsi:schemaLocation", "").split(" ").first
    end

    # show DataCite XML in different version if schema_version option is provided
    # currently only supports 4.0
    def datacite
      if schema_version != metadata.fetch("xsi:schemaLocation", "").split(" ").first
        as_datacite
      else
        raw
      end
    end

    def metadata
      @metadata ||= raw.present? ? Maremma.from_xml(raw).fetch("resource", {}) : {}
    end

    def exists?
      metadata.present?
    end

    def doi
      metadata.fetch("identifier", {}).fetch("__content__", nil)
    end

    def id
      normalize_doi(doi)
    end

    def resource_type_general
      metadata.dig("resourceType", "resourceTypeGeneral")
    end

    def type
      DC_TO_SO_TRANSLATIONS[resource_type_general.to_s.dasherize] || "CreativeWork"
    end

    def additional_type
      metadata.fetch("resourceType", {}).fetch("__content__", nil) ||
      metadata.fetch("resourceType", {}).fetch("resourceTypeGeneral", nil)
    end

    def bibtex_type
      Bolognese::Bibtex::SO_TO_BIB_TRANSLATIONS[type] || "misc"
    end

    def name
      metadata.dig("titles", "title")
    end

    def alternate_name
      metadata.dig("alternateIdentifiers", "alternateIdentifier", "__content__")
    end

    def description
      des = metadata.dig("descriptions", "description", "__content__")
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

    def funder
      f = funder_contributor + funding_reference
      f.length > 1 ? f : f.first
    end

    def funder_contributor
      Array.wrap(metadata.dig("contributors", "contributor")).reduce([]) do |sum, f|
        if f["contributorType"] == "Funder"
          sum << { "@type" => "Organization", "name" => f["contributorName"] }
        else
          sum
        end
      end
    end

    def funding_reference
      Array.wrap(metadata.dig("fundingReferences", "fundingReference")).map do |f|
        funder_id = parse_attribute(f["funderIdentifier"])
        { "@type" => "Organization",
          "@id" => normalize_id(funder_id),
          "name" => f["funderName"] }.compact
      end.uniq
    end

    def version
      metadata.fetch("version", nil)
    end

    def dates
      Array.wrap(metadata.dig("dates", "date"))
    end

    #Accepted Available Copyrighted Collected Created Issued Submitted Updated Valid

    def date(date_type)
      dd = dates.find { |d| d["dateType"] == date_type } || {}
      dd.fetch("__content__", nil)
    end

    def date_created
      date("Created")
    end

    def date_published
      date("Issued") || publication_year
    end

    def date_modified
      date("Updated")
    end

    def publication_year
      metadata.fetch("publicationYear")
    end

    def language
      metadata.fetch("language", nil)
    end

    def spatial_coverage

    end

    def content_size
      metadata.fetch("size", nil)
    end

    def related_identifiers(relation_type)
      Array(metadata.dig("relatedIdentifiers", "relatedIdentifier"))
        .select { |r| relation_type.split(" ").include?(r["relationType"]) && %w(DOI URL).include?(r["relatedIdentifierType"]) }
        .map do |work|
          { "@type" => "CreativeWork",
            "@id" => normalize_id(work["__content__"]) }
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
