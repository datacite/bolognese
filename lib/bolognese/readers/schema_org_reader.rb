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

      def get_schema_org(id: nil, **options)
        return { "string" => nil, "state" => "not_found" } unless id.present?

        id = normalize_id(id)
        response = Maremma.get(id)
        doc = Nokogiri::XML(response.body.fetch("data", nil), nil, 'UTF-8')

        # workaround for xhtml documents
        nodeset = doc.css("script")
        string = nodeset.find { |element| element["type"] == "application/ld+json" }
        string = string.text if string.present?

        { "string" => string }
      end

      def read_schema_org(string: nil, **options)
        if string.present?
          errors = jsonlint(string)
          return { "errors" => errors } if errors.present?
        end

        meta = string.present? ? Maremma.from_json(string) : {}

        id = normalize_id(meta.fetch("@id", nil))
        type = meta.fetch("@type", nil) && meta.fetch("@type").camelcase
        resource_type_general = Bolognese::Utils::SO_TO_DC_TRANSLATIONS[type]
        authors = meta.fetch("author", nil) || meta.fetch("creator", nil)
        author = get_authors(from_schema_org(Array.wrap(authors)))
        editor = get_authors(from_schema_org(Array.wrap(meta.fetch("editor", nil))))
        publisher = if meta.dig("publisher").is_a?(Hash)
                      meta.dig("publisher", "name")
                    elsif publisher.is_a?(String)
                      meta.dig("publisher")
                    end

        included_in_data_catalog = from_schema_org(Array.wrap(meta.fetch("includedInDataCatalog", nil)))
        included_in_data_catalog = Array.wrap(included_in_data_catalog).map { |dc| { "title" => dc["name"], "url" => dc["url"] } }
        is_part_of = schema_org_is_part_of(meta) || included_in_data_catalog

        license = {
          "id" => parse_attributes(meta.fetch("license", nil), content: "id", first: true),
          "name" => parse_attributes(meta.fetch("license", nil), content: "name", first: true)
        }

        date_published = meta.fetch("datePublished", nil)
        state = meta.present? ? "findable" : "not_found"

        { "id" => id,
          "type" => type,
          "additional_type" => meta.fetch("additionalType", nil),
          "citeproc_type" => Bolognese::Utils::SO_TO_CP_TRANSLATIONS[type] || "article-journal",
          "bibtex_type" => Bolognese::Utils::SO_TO_BIB_TRANSLATIONS[type] || "misc",
          "ris_type" => Bolognese::Utils::SO_TO_RIS_TRANSLATIONS[resource_type_general.to_s.dasherize] || "GEN",
          "resource_type_general" => resource_type_general,
          "doi" => validate_doi(id),
          "b_url" => normalize_id(meta.fetch("url", nil)),
          "title" => meta.fetch("name", nil),
          "alternate_name" => meta.fetch("alternateName", nil),
          "author" => author,
          "publisher" => meta.dig("publisher", "name"),
          "service_provider" => meta.fetch("provider", nil),
          "is_identical_to" => schema_org_is_identical_to(meta),
          "is_part_of" => is_part_of,
          "has_part" => schema_org_has_part(meta),
          "references" => schema_org_references(meta),
          "is_referenced_by" => schema_org_is_referenced_by(meta),
          "is_supplement_to" => schema_org_is_supplement_to(meta),
          "is_supplemented_by" => schema_org_is_supplemented_by(meta),
          "date_created" => meta.fetch("dateCreated", nil),
          "date_published" => date_published,
          "date_modified" => meta.fetch("dateModified", nil),
          "description" => meta.fetch("description", nil).present? ? { "text" => sanitize(meta.fetch("description")) } : nil,
          "license" => license,
          "b_version" => meta.fetch("version", nil),
          "keywords" => meta.fetch("keywords", nil).to_s.split(", "),
          "state" => state
        }
      end

      def schema_org_related_identifier(meta, relation_type: nil)
        normalize_ids(ids: meta.fetch(relation_type, nil))
      end

      def schema_org_reverse_related_identifier(meta, relation_type: nil)
        normalize_ids(ids: meta.dig("@reverse", relation_type))
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
