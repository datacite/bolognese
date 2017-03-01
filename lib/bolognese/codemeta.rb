module Bolognese
  class Codemeta < Metadata

    def initialize(id: nil, string: nil)
      id = normalize_id(id) if id.present?

      if string.present?
        @raw = string
      elsif id.present?
        response = Maremma.get(github_as_codemeta_url(id), raw: true)
        @raw = response.body.fetch("data", nil)
      end
    end

    def metadata
      @metadata ||= raw.present? ? Maremma.from_json(raw) : {}
    end

    def exists?
      metadata.present?
    end

    def valid?
      true
    end

    def doi
      doi_from_url(id)
    end

    def id
      normalize_id(metadata.fetch("@id", nil) || identifier)
    end

    def identifier
      metadata.fetch("identifier", nil)
    end

    def url
      normalize_id(metadata.fetch("codeRepository", nil))
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

    def title
      metadata.fetch("title", nil)
    end

    def alternate_name
      metadata.fetch("alternateName", nil)
    end

    def author
      authors = from_schema_org(Array.wrap(metadata.fetch("agents", nil)))
      get_authors(authors)
    end

    def editor
      editors = from_schema_org(Array.wrap(metadata.fetch("editor", nil)))
      get_authors(editors)
    end

    def description
      { "text" => metadata.fetch("description", nil) }
    end

    def license
      { "id" => metadata.fetch("license", nil) }
    end

    def version
      metadata.fetch("version", nil)
    end

    def keywords
      Array(metadata.fetch("tags", nil)).join(", ").presence
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
