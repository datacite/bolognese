module Bolognese
  class SchemaOrg < Metadata

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

    attr_reader = :id, :raw, :metadata, :schema_org

    def initialize(id: nil, string: nil)
      id = normalize_url(id) if id.present?

      if string.present?
        @raw = string
      elsif id.present?
        response = Maremma.get(id)
        @raw = response.body.fetch("data", nil)
      end
    end

    def metadata
      @metadata ||= begin
        if raw.present?
          doc = Nokogiri::XML(raw)
          tag = doc.at_xpath('//script[@type="application/ld+json"]')
          Maremma.from_json(tag)
        else
          {}
        end
      end
    end

    def exists?
      metadata.present?
    end

    def doi
      doi_from_url(id)
    end

    def id
      normalize_url(metadata.fetch("@id", nil))
    end

    def url
      normalize_url(metadata.fetch("url", nil))
    end

    def type
      metadata.fetch("@type", nil)
    end

    def additional_type
      metadata.fetch("additionalType", nil)
    end

    def name
      metadata.fetch("name", nil)
    end

    def alternate_name
      metadata.fetch("alternateName", nil)
    end

    def author
      Array(metadata.fetch("author", nil)).map { |a| a.except("name") }
    end

    def description
      metadata.fetch("description", nil)
    end

    def license
      metadata.fetch("license", nil)
    end

    def version
      metadata.fetch("version", nil)
    end

    def keywords
      metadata.fetch("keywords", nil)
    end

    def date_created
      metadata.fetch("dateCreated", nil)
    end

    def date_published
      metadata.fetch("datePublished", nil)
    end

    def date_modified
      metadata.fetch("dateModified", nil)
    end

    def related_identifiers(relation_type)
      normalize_ids(metadata.fetch(relation_type, nil))
    end

    def is_part_of
      related_identifiers("isPartOf").first
    end

    def has_part
      related_identifiers("hasPart")
    end

    def citation
      related_identifiers("citation")
    end

    def publisher
      metadata.fetch("publisher", nil)
    end

    def provider
      metadata.fetch("provider", nil)
    end

    def as_schema_org
      { "@context" => "http://schema.org",
        "@type" => type,
        "@id" => id,
        "url" => url,
        "name" => name,
        "alternateName" => alternate_name,
        "author" => author,
        "description" => description,
        "license" => license,
        "version" => version,
        "keywords" => keywords,
        "dateCreated" => date_created,
        "datePublished" => date_published,
        "dateModified" => date_modified,
        "isPartOf" => is_part_of,
        "hasPart" => has_part,
        "citation" => citation,
        "publisher" => publisher,
        "provider" => provider
      }.compact
    end
  end
end
