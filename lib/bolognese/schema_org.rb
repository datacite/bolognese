module Bolognese
  class SchemaOrg < Metadata

    def initialize(id: nil, string: nil)
      id = normalize_id(id) if id.present?

      if string.present?
        @raw = string
      elsif id.present?
        response = Maremma.get(id)
        doc = Nokogiri::XML(response.body.fetch("data", nil))
        @raw = doc.at_xpath('//script[@type="application/ld+json"]')
      end
    end

    def metadata
      @metadata ||= raw.present? ? Maremma.from_json(raw) : {}
    end

    def exists?
      metadata.present?
    end

    def doi
      doi_from_url(id)
    end

    def id
      normalize_id(metadata.fetch("@id", nil))
    end

    def url
      normalize_id(metadata.fetch("url", nil))
    end

    def resource_type_general
      SO_TO_DC_TRANSLATIONS[type]
    end

    def type
      metadata.fetch("@type", nil)
    end

    def additional_type
      metadata.fetch("additionalType", nil)
    end

    def bibtex_type
      Bolognese::Bibtex::SO_TO_BIB_TRANSLATIONS[type] || "misc"
    end

    def name
      metadata.fetch("name", nil)
    end

    def alternate_name
      metadata.fetch("alternateName", nil)
    end

    def author
      arr = Array.wrap(metadata.fetch("author", nil)).map { |a| a.except("name") }
      array_unwrap(arr)
    end

    def editor
      arr = Array.wrap(metadata.fetch("editor", nil)).map { |a| a.except("name") }
      array_unwrap(arr)
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

    def same_as
      related_identifiers("isIdenticalTo")
    end

    def is_part_of
      related_identifiers("isPartOf")
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

    def container_title
      if publisher.is_a?(Hash)
        publisher.fetch("name", nil)
      elsif publisher.is_a?(String)
        publisher
      end
    end

    def provider
      metadata.fetch("provider", nil)
    end
  end
end
