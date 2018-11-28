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

        read_options = ActiveSupport::HashWithIndifferentAccess.new(options.except(:string, :sandbox))

        meta = string.present? ? Maremma.from_json(string) : {}

        identifier = Array.wrap(meta.fetch("identifier", nil))
        if identifier.length > 1
          alternate_identifiers = identifier[1..-1].map do |r|
            if r.is_a?(String)
              { "alternateIdentifierType" => "URL", "alternateIdentifier" => r }
            elsif r.is_a?(Hash)
              { "alternateIdentifierType" => r["propertyID"], "alternateIdentifier" => r["value"] }
            end
          end
        else
          alternate_identifiers = nil
        end
        identifier = identifier.first

        id = normalize_id(meta.fetch("@id", nil) || meta.fetch("identifier", nil))
        schema_org = meta.fetch("@type", nil) && meta.fetch("@type").camelcase
        resource_type_general = Bolognese::Utils::SO_TO_DC_TRANSLATIONS[schema_org]
        types = {
          "resourceTypeGeneral" => resource_type_general,
          "resourceType" => meta.fetch("additionalType", nil),
          "schemaOrg" => schema_org,
          "citeproc" => Bolognese::Utils::SO_TO_CP_TRANSLATIONS[schema_org] || "article-journal",
          "bibtex" => Bolognese::Utils::SO_TO_BIB_TRANSLATIONS[schema_org] || "misc",
          "ris" => Bolognese::Utils::SO_TO_RIS_TRANSLATIONS[resource_type_general.to_s.dasherize] || "GEN"
        }.compact
        authors = meta.fetch("author", nil) || meta.fetch("creator", nil)
        author = get_authors(from_schema_org(Array.wrap(authors)))
        contributor = get_authors(from_schema_org(Array.wrap(meta.fetch("editor", nil))))
        publisher = parse_attributes(meta.fetch("publisher", nil), content: "name", first: true)

        ct = (schema_org == "Dataset") ? "includedInDataCatalog" : "Periodical"
        periodical = if meta.fetch(ct, nil).present?
          {
            "type" => (schema_org == "Dataset") ? "DataCatalog" : "Periodical",
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

        rights_list = {
          "rightsUri" => parse_attributes(meta.fetch("license", nil), content: "id", first: true),
          "rights" => parse_attributes(meta.fetch("license", nil), content: "name", first: true)
        }

        funding_references = Array.wrap(meta.fetch("funder", nil)).compact.map do |fr|
          if fr["@id"].present?
            {
              "funderName" => fr["name"],
              "funderIdentifier" => fr["@id"],
              "funderIdentifierType" => fr["@id"].to_s.start_with?("https://doi.org/10.13039") ? "Crossref Funder ID" : "Other" }.compact
          else
            {
              "funderName" => fr["name"] }.compact
          end
        end
        dates = []
        dates << { "date" => meta.fetch("datePublished"), "dateType" => "Issued" } if meta.fetch("datePublished", nil).present?
        dates << { "date" => meta.fetch("dateCreated"), "dateType" => "Created" } if meta.fetch("dateCreated", nil).present?
        dates << { "date" => meta.fetch("dateModified"), "dateType" => "Updated" } if meta.fetch("dateModified", nil).present?
        publication_year = meta.fetch("datePublished")[0..3] if meta.fetch("datePublished", nil).present?
        
        state = meta.present? || read_options.present? ? "findable" : "not_found"
        geo_locations = Array.wrap(meta.fetch("spatialCoverage", nil)).map do |gl|
          if gl.dig("geo", "box")
            s, w, n, e = gl.dig("geo", "box").split(" ", 4)
            geo_location_box = {
              "westBoundLongitude" => w,
              "eastBoundLongitude" => e,
              "southBoundLatitude" => s,
              "northBoundLatitude" => n
            }.compact.presence
          else
            geo_location_box = nil
          end
          geo_location_point = { "pointLongitude" => gl.dig("geo", "longitude"), "pointLatitude" => gl.dig("geo", "latitude") }.compact.presence

          {
            "geoLocationPlace" => gl.dig("geo", "address"),
            "geoLocationPoint" => geo_location_point,
            "geoLocationBox" => geo_location_box
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
          "agency" => parse_attributes(meta.fetch("provider", nil), content: "name", first: true),
          "periodical" => periodical,
          "related_identifiers" => related_identifiers,
          "publication_year" => publication_year,
          "dates" => dates,
          "descriptions" => meta.fetch("description", nil).present? ? [{ "description" => sanitize(meta.fetch("description")), "descriptionType" => "Abstract" }] : nil,
          "rights_list" => rights_list,
          "version_info" => meta.fetch("version", nil).to_s.presence,
          "subjects" => subjects,
          "state" => state,
          "schema_version" => meta.fetch("schemaVersion", nil).to_s.presence,
          "funding_references" => funding_references,
          "geo_locations" => geo_locations
        }.merge(read_options)
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
