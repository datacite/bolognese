module Bolognese
  class Citeproc < Metadata

    SO_TO_DC_RELATION_TYPES = {
      "citation" => "References",
      "sameAs" => "IsIdenticalTo",
      "isPartOf" => "IsPartOf",
      "hasPart" => "HasPart",
      "isPredecessor" => "IsPreviousVersionOf",
      "isSuccessor" => "IsNewVersionOf"
    }

    def initialize(string: nil)
      @raw = string
    end

    def metadata
      @metadata ||= raw.present? ? Maremma.from_json(raw) : {}
    end

    def exists?
      metadata.present?
    end

    def valid?
      citeproc.present?
    end

    def doi
      metadata.fetch("DOI", nil)
    end

    def id
      normalize_id(metadata.fetch("id", nil))
    end

    def url
      normalize_id(metadata.fetch("URL", nil))
    end

    def resource_type_general
      SO_TO_DC_TRANSLATIONS[type]
    end

    def type
      CP_TO_SO_TRANSLATIONS[citeproc_type] || "CreativeWork"
    end

    def citeproc_type
      metadata.fetch("type", nil)
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

    def author
      authors = from_citeproc(Array.wrap(metadata.fetch("author", nil)))
      get_authors(authors)
    end

    def editor
      editors = from_citeproc(Array.wrap(metadata.fetch("editor", nil)))
      get_authors(editors)
    end

    def description
      { "text" => metadata.fetch("abstract", nil) }
    end

    def version
      metadata.fetch("version", nil)
    end

    def keywords
      metadata.fetch("categories", nil)
    end

    def date_published
      issued = metadata.fetch("issued", nil)
      get_date_from_date_parts(issued)
    end

    def publication_year
      date_published[0..3].to_i.presence
    end

    def is_part_of
      if container_title.present?
        { "type" => "Periodical",
          "name" => container_title,
          "issn" => metadata.fetch("ISSN", nil) }.compact
      end
    end

    def publisher
      metadata.fetch("publisher", nil)
    end

    def container_title
      metadata.fetch("container-title", nil)
    end
  end
end
