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
              { "alternate_identifier_type" => "URL", "alternate_identifier" => r }
            elsif r.is_a?(Hash)
              { "alternate_identifier_type" => r["propertyID"], "alternate_identifier" => r["value"] }
            end
          end
        else
          alternate_identifiers = nil
        end
        identifier = identifier.first

        id = normalize_id(meta.fetch("@id", nil) || meta.fetch("identifier", nil))
        type = meta.fetch("@type", nil) && meta.fetch("@type").camelcase
        resource_type_general = Bolognese::Utils::SO_TO_DC_TRANSLATIONS[type]
        types = {
          "type" => type,
          "resource_type_general" => resource_type_general,
          "resource_type" => meta.fetch("additionalType", nil),
          "citeproc" => Bolognese::Utils::SO_TO_CP_TRANSLATIONS[type] || "article-journal",
          "bibtex" => Bolognese::Utils::SO_TO_BIB_TRANSLATIONS[type] || "misc",
          "ris" => Bolognese::Utils::SO_TO_RIS_TRANSLATIONS[resource_type_general.to_s.dasherize] || "GEN"
        }.compact
        authors = meta.fetch("author", nil) || meta.fetch("creator", nil)
        author = get_authors(from_schema_org(Array.wrap(authors)))
        contributor = get_authors(from_schema_org(Array.wrap(meta.fetch("editor", nil))))
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

        funding_references = Array.wrap(meta.fetch("funder", nil)).compact.map do |fr|
          {
            "funder_name" => fr["name"],
            "funder_identifier" => fr["@id"],
            "funder_identifier_type" => fr["@id"].to_s.start_with?("https://doi.org/10.13039") ? "Crossref Funder ID" : nil }.compact
        end
        dates = []
        dates << { "date" => meta.fetch("datePublished"), "date_type" => "Issued" } if meta.fetch("datePublished", nil).present?
        dates << { "date" => meta.fetch("dateCreated"), "date_type" => "Created" } if meta.fetch("dateCreated", nil).present?
        dates << { "date" => meta.fetch("dateModified"), "date_type" => "Updated" } if meta.fetch("dateModified", nil).present?
        publication_year = meta.fetch("datePublished")[0..3] if meta.fetch("datePublished", nil).present?
        
        state = meta.present? ? "findable" : "not_found"
        geo_locations = Array.wrap(meta.fetch("spatialCoverage", nil)).map do |gl|
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
        subjects = Array.wrap(meta.fetch("keywords", nil).to_s.split(", ")).map do |s|
          { "subject" => s }
        end

        { "id" => id,
          "types" => types,
          "doi" => validate_doi(id),
          "identifier" => identifier,
          "alternate_identifiers" => alternate_identifiers,
          "url" => normalize_id(meta.fetch("url", nil)),
          "content_url" => Array.wrap(meta.fetch("contentUrl", nil)),
          "sizes" => Array.wrap(meta.fetch("contenSize", nil)).presence,
          "formats" => Array.wrap(meta.fetch("encodingFormat", nil) || meta.fetch("fileFormat", nil)),
          "titles" => meta.fetch("name", nil).present? ? [{ "title" => meta.fetch("name", nil) }] : nil,
          "creator" => author,
          "contributor" => contributor,
          "publisher" => publisher,
          "service_provider" => parse_attributes(meta.fetch("provider", nil), content: "name", first: true),
          "periodical" => periodical,
          "related_identifiers" => related_identifiers,
          "publication_year" => publication_year,
          "dates" => dates,
          "descriptions" => meta.fetch("description", nil).present? ? [{ "description" => sanitize(meta.fetch("description")) }] : nil,
          "rights" => rights,
          "version" => meta.fetch("version", nil),
          "subjects" => subjects,
          "state" => state,
          "schema_version" => meta.fetch("schemaVersion", nil),
          "funding_references" => funding_references,
          "geo_locations" => geo_locations
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
