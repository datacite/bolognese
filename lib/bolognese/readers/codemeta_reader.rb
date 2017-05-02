module Bolognese
  module Readers
    module CodemetaReader
      def read_codemeta(id: nil, string: nil)
        if id.present?
          id = normalize_id(id)
          response = Maremma.get(github_as_codemeta_url(id), raw: true)
          string = response.body.fetch("data", nil)
        end

        errors = jsonlint(string)
        return { "errors" => errors } if errors.present?

        meta = string.present? ? Maremma.from_json(string) : {}
        identifier = meta.fetch("identifier", nil)
        id = normalize_id(meta.fetch("@id", nil) || identifier)
        type = meta.fetch("@type", nil)
        author = get_authors(from_schema_org(Array.wrap(meta.fetch("agents", nil))))
        editor = get_authors(from_schema_org(Array.wrap(meta.fetch("editor", nil))))
        date_published = meta.fetch("datePublished", nil)
        publisher = meta.fetch("publisher", nil)
        container_title = if publisher.is_a?(Hash)
                            publisher.fetch("name", nil)
                          elsif publisher.is_a?(String)
                            publisher
                          else
                            nil
                          end

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
          "alternate_name" => meta.fetch("alternateName", nil),
          "author" => author,
          "editor" => editor,
          "container_title" => container_title,
          "publisher" => publisher,
          #{}"is_part_of" => is_part_of,
          "date_created" => meta.fetch("dateCreated", nil),
          "date_published" => date_published,
          "date_modified" => meta.fetch("dateModified", nil),
          "description" => { "text" => meta.fetch("description", nil) },
          "license" => { "id" => meta.fetch("license", nil) },
          "version" => meta.fetch("version", nil),
          "keywords" => Array.wrap(meta.fetch("tags", nil)).join(", ").presence
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
