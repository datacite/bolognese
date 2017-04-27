module Bolognese
  module Readers
    module SchemaOrgReader
      SO_TO_DC_RELATION_TYPES = {
        "citation" => "References",
        "sameAs" => "IsIdenticalTo",
        "isPartOf" => "IsPartOf",
        "hasPart" => "HasPart",
        "isPredecessor" => "IsPreviousVersionOf",
        "isSuccessor" => "IsNewVersionOf"
      }

      def read_schema_org(id: nil, string: nil)
        if id.present?
          id = normalize_id(id)
          response = Maremma.get(id)
          doc = Nokogiri::XML(response.body.fetch("data", nil), nil, 'UTF-8')
          string = doc.at_xpath('//script[@type="application/ld+json"]')
          string = string.text if string.present?
        end

        errors = jsonlint(string)
        meta = string.present? && errors.empty? ? Maremma.from_json(string) : {}

        id = normalize_id(meta.fetch("@id", nil))
        type = meta.fetch("@type", nil)
        resource_type_general = Bolognese::Utils::SO_TO_DC_TRANSLATIONS[type]
        author = get_authors(from_schema_org(Array.wrap(meta.fetch("author", nil))))
        editor = get_authors(from_schema_org(Array.wrap(meta.fetch("editor", nil))))
        publisher = meta.dig("publisher", "name")
        container_title = if publisher.is_a?(Hash)
                            publisher.fetch("name", nil)
                          elsif publisher.is_a?(String)
                            publisher
                          end
        date_published = meta.fetch("datePublished", nil)

        { "id" => id,
          "type" => type,
          "additional_type" => meta.fetch("additionalType", nil),
          "citeproc_type" => Bolognese::Utils::SO_TO_CP_TRANSLATIONS[type] || "article-journal",
          "bibtex_type" => Bolognese::Utils::SO_TO_BIB_TRANSLATIONS[type] || "misc",
          "ris_type" => Bolognese::Utils::SO_TO_RIS_TRANSLATIONS[resource_type_general.to_s.dasherize] || "GEN",
          "resource_type_general" => resource_type_general,
          "doi" => validate_doi(id),
          "url" => normalize_id(meta.fetch("url", nil)),
          "title" => meta.fetch("name", nil),
          "alternate_name" => meta.fetch("alternateName", nil),
          "author" => author,
          "container_title" => container_title,
          "publisher" => meta.dig("publisher", "name"),
          "provider" => meta.fetch("provider", nil),
          #{}"is_part_of" => is_part_of,
          "date_created" => meta.fetch("dateCreated", nil),
          "date_published" => date_published,
          "date_modified" => meta.fetch("dateModified", nil),
          "publication_year" => date_published.present? ? date_published[0..3].to_i.presence : nil,
          #{}"volume" => meta.volume.to_s.presence,
          #{}"pagination" => meta.pages.to_s.presence,
          "description" => { "text" => meta.fetch("description", nil) },
          "license" => { "id" => meta.fetch("license", nil) },
          "version" => meta.fetch("version", nil),
          "keywords" => meta.fetch("keywords", nil)
        }
      end

      # def related_identifier
      #   Array.wrap(is_identical_to) +
      #   Array.wrap(is_part_of) +
      #   Array.wrap(has_part) +
      #   Array.wrap(is_previous_version_of) +
      #   Array.wrap(is_new_version_of) +
      #   Array.wrap(references) +
      #   Array.wrap(is_supplemented_by)
      # end
      #
      # def get_related_identifier(relation_type: nil)
      #   normalize_ids(ids: metadata.fetch(relation_type, nil),
      #                 relation_type: SO_TO_DC_RELATION_TYPES[relation_type])
      # end
      #
      # def get_reverse_related_identifier(relation_type: nil)
      #   normalize_ids(ids: metadata.dig("@reverse", relation_type),
      #                 relation_type: SO_TO_DC_RELATION_TYPES[relation_type])
      # end
      #
      # def is_identical_to
      #   get_related_identifier(relation_type: "sameAs")
      # end
      #
      # def is_part_of
      #   get_related_identifier(relation_type: "isPartOf")
      # end
      #
      # def has_part
      #   get_related_identifier(relation_type: "hasPart")
      # end
      #
      # def is_previous_version_of
      #   get_related_identifier(relation_type: "isPredecessor")
      # end
      #
      # def is_new_version_of
      #   get_related_identifier(relation_type: "isSuccessor")
      # end
      #
      # def references
      #   get_related_identifier(relation_type: "citation")
      # end
      #
      # def is_referenced_by
      #   get_reverse_related_identifier(relation_type: "citation")
      # end
      #
      # def is_supplement_to
      #   get_reverse_related_identifier(relation_type: "isBasedOn")
      # end
      #
      # def is_supplemented_by
      #   get_related_identifier(relation_type: "isBasedOn")
      # end

    end
  end
end
