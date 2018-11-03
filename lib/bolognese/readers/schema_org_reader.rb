# frozen_string_literal: true

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

        identifier = Array.wrap(meta.fetch("identifier", nil))
        if identifier.length > 1
          alternate_identifiers = identifier[1..-1].map do |r|
            if r.is_a?(String)
              { "type" => "URL", "name" => r }
            elsif r.is_a?(Hash)
              { "type" => r["propertyID"], "name" => r["value"] }
            end
          end.unwrap
        else
          alternate_identifiers = nil
        end
        identifier = identifier.first

        id = normalize_id(meta.fetch("@id", nil) || meta.fetch("identifier", nil))
        type = meta.fetch("@type", nil) && meta.fetch("@type").camelcase
        resource_type_general = Bolognese::Utils::SO_TO_DC_TRANSLATIONS[type]
        authors = meta.fetch("author", nil) || meta.fetch("creator", nil)
        author = get_authors(from_schema_org(Array.wrap(authors)))
        editor = get_authors(from_schema_org(Array.wrap(meta.fetch("editor", nil))))
        publisher = parse_attributes(meta.fetch("publisher", nil), content: "name", first: true)

        ct = (type == "Dataset") ? "includedInDataCatalog" : "Periodical"
        periodical = if meta.fetch(ct, nil).present?
          {
            "type" => (type == "Dataset") ? "DataCatalog" : "Periodical",
            "title" => parse_attributes(from_schema_org(meta.fetch(ct, nil)), content: "name", first: true),
            "url" => parse_attributes(from_schema_org(meta.fetch(ct, nil)), content: "url", first: true)
          }.compact
        else
          nil
        end

        related_identifiers = Array.wrap(schema_org_is_identical_to(meta)) +
          Array.wrap(schema_org_is_part_of(meta)) +
          Array.wrap(schema_org_has_part(meta)) +
          Array.wrap(schema_org_is_previous_version_of(meta)) +
          Array.wrap(schema_org_is_new_version_of(meta)) +
          Array.wrap(schema_org_references(meta)) +
          Array.wrap(schema_org_is_referenced_by(meta)) +
          Array.wrap(schema_org_is_supplement_to(meta)) +
          Array.wrap(schema_org_is_supplemented_by(meta))

        rights = {
          "id" => parse_attributes(meta.fetch("license", nil), content: "id", first: true),
          "name" => parse_attributes(meta.fetch("license", nil), content: "name", first: true)
        }

        funding_references = from_schema_org(Array.wrap(meta.fetch("funder", nil)))
        funding_references = Array.wrap(meta.fetch("funder", nil)).compact.map do |fr|
          {
            "funder_name" => fr["name"],
            "funder_identifier" => fr["@id"],
            "funder_identifier_type" => fr["@id"].to_s.start_with?("https://doi.org/10.13039") ? "Crossref Funder ID" : nil }.compact
        end
        date_published = meta.fetch("datePublished", nil)
        state = meta.present? ? "findable" : "not_found"
        geo_location = Array.wrap(meta.fetch("spatialCoverage", nil)).map do |gl|
          if gl.dig("geo", "box")
            s, w, n, e = gl.dig("geo", "box").split(" ", 4)
            geo_location_box = {
              "west_bound_longitude" => w,
              "east_bound_longitude" => e,
              "south_bound_latitude" => s,
              "north_bound_latitude" => n
            }.compact.presence
          else
            geo_location_box = nil
          end
          geo_location_point = { "point_longitude" => gl.dig("geo", "longitude"), "point_latitude" => gl.dig("geo", "latitude") }.compact.presence

          {
            "geo_location_place" => gl.dig("geo", "address"),
            "geo_location_point" => geo_location_point,
            "geo_location_box" => geo_location_box
          }.compact
        end

        { "id" => id,
          "type" => type,
          "additional_type" => meta.fetch("additionalType", nil),
          "citeproc_type" => Bolognese::Utils::SO_TO_CP_TRANSLATIONS[type] || "article-journal",
          "bibtex_type" => Bolognese::Utils::SO_TO_BIB_TRANSLATIONS[type] || "misc",
          "ris_type" => Bolognese::Utils::SO_TO_RIS_TRANSLATIONS[resource_type_general.to_s.dasherize] || "GEN",
          "resource_type_general" => resource_type_general,
          "doi" => validate_doi(id),
          "identifier" => identifier,
          "alternate_identifiers" => alternate_identifiers,
          "url" => normalize_id(meta.fetch("url", nil)),
          "content_url" => Array.wrap(meta.fetch("contentUrl", nil)).unwrap,
          "size" => meta.fetch("contenSize", nil),
          "formats" => Array.wrap(meta.fetch("encodingFormat", nil) || meta.fetch("fileFormat", nil)).unwrap,
          "title" => meta.fetch("name", nil),
          "creator" => author,
          "editor" => editor,
          "publisher" => publisher,
          "service_provider" => parse_attributes(meta.fetch("provider", nil), content: "name", first: true),
          "periodical" => periodical,
          "related_identifiers" => related_identifiers,
          "date_created" => meta.fetch("dateCreated", nil),
          "date_published" => date_published,
          "date_modified" => meta.fetch("dateModified", nil),
          "description" => meta.fetch("description", nil).present? ? { "text" => sanitize(meta.fetch("description")) } : nil,
          "rights" => rights,
          "version" => meta.fetch("version", nil),
          "keywords" => meta.fetch("keywords", nil).to_s.split(", "),
          "state" => state,
          "schema_version" => meta.fetch("schemaVersion", nil),
          "funding_references" => funding_references,
          "geo_location" => geo_location
        }
      end

      def schema_org_related_identifier(meta, relation_type: nil)
        normalize_ids(ids: meta.fetch(relation_type, nil), relation_type: SO_TO_DC_RELATION_TYPES[relation_type])
      end

      def schema_org_reverse_related_identifier(meta, relation_type: nil)
        normalize_ids(ids: meta.dig("@reverse", relation_type), relation_type: SO_TO_DC_RELATION_TYPES[relation_type])
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
        schema_org_related_identifier(meta, relation_type: "PredecessorOf")
      end

      def schema_org_is_new_version_of(meta)
        schema_org_related_identifier(meta, relation_type: "SuccessorOf")
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
