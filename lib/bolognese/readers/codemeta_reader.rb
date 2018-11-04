# frozen_string_literal: true

module Bolognese
  module Readers
    module CodemetaReader
      def get_codemeta(id: nil, **options)
        return { "string" => nil, "state" => "not_found" } unless id.present?
        id = normalize_id(id)
        response = Maremma.get(github_as_codemeta_url(id), accept: "json", raw: true)
        string = response.body.fetch("data", nil)

        { "string" => string }
      end

      def read_codemeta(string: nil, **options)
        if string.present?
          errors = jsonlint(string)
          return { "errors" => errors } if errors.present?
        end

        meta = string.present? ? Maremma.from_json(string) : {}
        identifier = meta.fetch("identifier", nil)
        id = normalize_id(meta.fetch("@id", nil) || identifier)
        type = meta.fetch("@type", nil)
        author = get_authors(from_schema_org(Array.wrap(meta.fetch("agents", nil))))
        editor = get_authors(from_schema_org(Array.wrap(meta.fetch("editor", nil))))
        dates = []
        dates << { "date" => meta.fetch("datePublished"), "date_type" => "Issued" } if meta.fetch("datePublished", nil).present?
        dates << { "date" => meta.fetch("dateCreated"), "date_type" => "Created" } if meta.fetch("dateCreated", nil).present?
        dates << { "date" => meta.fetch("dateModified"), "date_type" => "Updated" } if meta.fetch("dateModified", nil).present?
        publication_year = meta.fetch("datePublished")[0..3] if meta.fetch("datePublished", nil).present?
        publisher = meta.fetch("publisher", nil)
        state = meta.present? ? "findable" : "not_found"

        { "id" => id,
          "type" => type,
          "additional_type" => meta.fetch("additionalType", nil),
          "citeproc_type" => Bolognese::Utils::SO_TO_CP_TRANSLATIONS[type] || "article-journal",
          "bibtex_type" => Bolognese::Utils::SO_TO_BIB_TRANSLATIONS[type] || "misc",
          "ris_type" => Bolognese::Utils::SO_TO_RIS_TRANSLATIONS[type] || "GEN",
          "resource_type_general" => Bolognese::Utils::SO_TO_DC_TRANSLATIONS[type],
          "identifier" => identifier,
          "doi" => validate_doi(id),
          "url" => normalize_id(meta.fetch("codeRepository", nil)),
          "title" => meta.fetch("title", nil),
          "creator" => author,
          "editor" => editor,
          "publisher" => publisher,
          #{}"is_part_of" => is_part_of,
          "dates" => dates,
          "publication_year" => publication_year,
          "description" => meta.fetch("description", nil).present? ? { "text" => sanitize(meta.fetch("description")) } : nil,
          "rights" => { "id" => meta.fetch("license", nil) },
          "version" => meta.fetch("version", nil),
          "keywords" => meta.fetch("tags", nil),
          "state" => state
        }
      end

      # def related_identifiers(relation_type)
      #   normalize_ids(ids: metadata.fetch(relation_type, nil), relation_type: relation_type)
      # end
      #
      # def same_as
      #   related_identifiers("isIdenticalTo")
      # end
      #
      # def is_part_of
      #   related_identifiers("isPartOf")
      # end
      #
      # def has_part
      #   related_identifiers("hasPart")
      # end
      #
      # def citation
      #   related_identifiers("citation")
      # end
    end
  end
end
