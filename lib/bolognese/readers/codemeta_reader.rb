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

        read_options = ActiveSupport::HashWithIndifferentAccess.new(options.except(:doi, :id, :url, :sandbox, :validate))

        meta = string.present? ? Maremma.from_json(string) : {}

        identifiers = ([meta.fetch("@id", nil)] + Array.wrap(meta.fetch("identifier", nil))).map do |r|
          r = normalize_id(r) if r.is_a?(String)
          if r.is_a?(String) && r.start_with?("https://doi.org")
            { "identifierType" => "DOI", "identifier" => r }
          elsif r.is_a?(String)
              { "identifierType" => "URL", "identifier" => r }
          elsif r.is_a?(Hash)
            { "identifierType" => get_identifier_type(r["propertyID"]), "identifier" => r["value"] }
          end
        end.compact.uniq

        id = Array.wrap(identifiers).first.to_h.fetch("identifier", nil)
        doi = Array.wrap(identifiers).find { |r| r["identifierType"] == "DOI" }.to_h.fetch("identifier", nil)

        has_agents = meta.fetch("agents", nil)
        authors =  has_agents.nil? ? meta.fetch("authors", nil) : has_agents
        creators = get_authors(from_schema_org_creators(Array.wrap(authors)))

        contributors = get_authors(from_schema_org_contributors(Array.wrap(meta.fetch("editor", nil))))
        dates = []
        dates << { "date" => meta.fetch("datePublished"), "dateType" => "Issued" } if meta.fetch("datePublished", nil).present?
        dates << { "date" => meta.fetch("dateCreated"), "dateType" => "Created" } if meta.fetch("dateCreated", nil).present?
        dates << { "date" => meta.fetch("dateModified"), "dateType" => "Updated" } if meta.fetch("dateModified", nil).present?
        publication_year = meta.fetch("datePublished")[0..3] if meta.fetch("datePublished", nil).present?
        publisher = meta.fetch("publisher", nil)
        state = meta.present? || read_options.present? ? "findable" : "not_found"
        schema_org = meta.fetch("@type", nil)
        types = {
          "resourceTypeGeneral" => Bolognese::Utils::SO_TO_DC_TRANSLATIONS[schema_org],
          "resourceType" => meta.fetch("additionalType", nil),
          "schemaOrg" => schema_org,
          "citeproc" => Bolognese::Utils::SO_TO_CP_TRANSLATIONS[schema_org] || "article-journal",
          "bibtex" => Bolognese::Utils::SO_TO_BIB_TRANSLATIONS[schema_org] || "misc",
          "ris" => Bolognese::Utils::SO_TO_RIS_TRANSLATIONS[schema_org] || "GEN"
        }.compact
        subjects = Array.wrap(meta.fetch("tags", nil)).map do |s|
          { "subject" => s }
        end

        has_title = meta.fetch("title", nil)

        titles =  has_title.nil? ?  [{ "title" => meta.fetch("name", nil) }] : [{ "title" => has_title }]  

        { "id" => id,
          "types" => types,
          "identifiers" => identifiers,
          "doi" => doi_from_url(doi),
          "url" => normalize_id(meta.fetch("codeRepository", nil)),
          "titles" => titles,
          "creators" => creators,
          "contributors" => contributors,
          "publisher" => publisher,
          #{}"is_part_of" => is_part_of,
          "dates" => dates,
          "publication_year" => publication_year,
          "descriptions" => meta.fetch("description", nil).present? ? [{ "description" => sanitize(meta.fetch("description")), "descriptionType" => "Abstract" }] : nil,
          "rights_list" => [{ "rightsUri" => meta.fetch("license", nil) }.compact],
          "version_info" => meta.fetch("version", nil),
          "subjects" => subjects,
          "state" => state
        }.merge(read_options)
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
