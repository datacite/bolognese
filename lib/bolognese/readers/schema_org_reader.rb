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

      def read_schema_org(string: nil)
        errors = jsonlint(string)
        return { "errors" => errors } if errors.present?

        meta = string.present? ? Maremma.from_json(string) : {}

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
          "is_identical_to" => schema_org_is_identical_to(meta),
          "is_part_of" => schema_org_is_part_of(meta),
          "has_part" => schema_org_has_part(meta),
          "references" => schema_org_references(meta),
          "is_referenced_by" => schema_org_is_referenced_by(meta),
          "is_supplement_to" => schema_org_is_supplement_to(meta),
          "is_supplemented_by" => schema_org_is_supplemented_by(meta),
          "date_created" => meta.fetch("dateCreated", nil),
          "date_published" => date_published,
          "date_modified" => meta.fetch("dateModified", nil),
          "description" => { "text" => meta.fetch("description", nil) },
          "license" => { "id" => meta.fetch("license", nil) },
          "version" => meta.fetch("version", nil),
          "keywords" => meta.fetch("keywords", nil)
        }
      end

      def get_schema_org(id: nil)
        return nil unless id.present?

        id = normalize_id(id)
        response = Maremma.get(id)
        doc = Nokogiri::XML(response.body.fetch("data", nil), nil, 'UTF-8')
        string = doc.at_xpath('//script[@type="application/ld+json"]')
        string.text if string.present?
      end

      def schema_org_related_identifier(meta, relation_type: nil)
        normalize_ids(ids: meta.fetch(relation_type, nil),
                      relation_type: SO_TO_DC_RELATION_TYPES[relation_type])
      end

      def schema_org_reverse_related_identifier(meta, relation_type: nil)
        normalize_ids(ids: meta.dig("@reverse", relation_type),
                      relation_type: SO_TO_DC_RELATION_TYPES[relation_type])
      end

      def schema_org_is_identical_to(meta)
        schema_org_related_identifier(meta, relation_type: "sameAs")
      end

      def schema_org_is_part_of(meta)
        schema_org_related_identifier(meta, relation_type: "isPartOf")
      end

      def schema_org_has_part(meta)
        schema_org_related_identifier(meta, relation_type: "hasPart")
      end

      def schema_org_is_previous_version_of(meta)
        schema_org_related_identifier(meta, relation_type: "isPredecessor")
      end

      def schema_org_is_new_version_of(meta)
        schema_org_related_identifier(meta, relation_type: "isSuccessor")
      end

      def schema_org_references(meta)
        schema_org_related_identifier(meta, relation_type: "citation")
      end

      def schema_org_is_referenced_by(meta)
        schema_org_reverse_related_identifier(meta, relation_type: "citation")
      end

      def schema_org_is_supplement_to(meta)
        schema_org_reverse_related_identifier(meta, relation_type: "isBasedOn")
      end

      def schema_org_is_supplemented_by(meta)
        schema_org_related_identifier(meta, relation_type: "isBasedOn")
      end
    end
  end
end
