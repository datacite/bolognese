# frozen_string_literal: true

module Bolognese
  module Readers
    module DataciteJsonReader
      def read_datacite_json(string: nil, **options)
        errors = jsonlint(string)
        return { "errors" => errors } if errors.present?

        read_options = ActiveSupport::HashWithIndifferentAccess.new(options.except(:string, :sandbox))

        meta = string.present? ? Maremma.from_json(string) : {}

        state = meta.fetch("doi", nil).present? || read_options.present? ? "findable" : "not_found"

        dates = Array.wrap(meta.fetch("dates", nil)).map do |d|
          { "date" => d["date"],
            "dateType" => d["dateType"],
            "dateInformation" => d["dateInformation"] }.compact
        end
        dates << { "date" => meta.fetch("publicationYear", nil), "dateType" => "Issued" } if meta.fetch("publicationYear", nil).present? && get_date(dates, "Issued").blank?
        schema_org = meta.dig("types", "type") || Bolognese::Utils::CR_TO_SO_TRANSLATIONS[meta.dig("types", "resourceType").to_s.underscore.camelcase] || Bolognese::Utils::DC_TO_SO_TRANSLATIONS[meta.dig("types", "resourceTypeGeneral").to_s.dasherize] || "CreativeWork"
        types = { 
          "resourceTypeGeneral" => meta.dig("types", "resourceTypeGeneral"),
          "resourceType" => meta.dig("types", "resourceType"),
          "schemaOrg" => schema_org,
          "bibtex" => meta.dig("types", "bibtex") || Bolognese::Utils::CR_TO_BIB_TRANSLATIONS[meta.dig("types", "resourceType").to_s.underscore.camelcase] || Bolognese::Utils::SO_TO_BIB_TRANSLATIONS[schema_org] || "misc",
          "citeproc" => meta.dig("types", "citeproc") || Bolognese::Utils::CR_TO_CP_TRANSLATIONS[meta.dig("types", "resourceType").to_s.underscore.camelcase] || Bolognese::Utils::SO_TO_CP_TRANSLATIONS[schema_org] || "article",
          "ris" => meta.dig("types", "ris") || Bolognese::Utils::CR_TO_RIS_TRANSLATIONS[meta.dig("types", "resourceType").to_s.underscore.camelcase] || Bolognese::Utils::DC_TO_RIS_TRANSLATIONS[meta.dig("types", "resourceTypeGeneral").to_s.dasherize] || "GEN" }.compact

        { "id" => meta.fetch("id", nil),
          "types" => types,
          "doi" => validate_doi(meta.fetch("doi", nil)),
          "url" => normalize_id(meta.fetch("url", nil)),
          "titles" => meta.fetch("titles", nil),
          "alternate_identifiers" => Array.wrap(meta.fetch("alternateIdentifiers", nil)),
          "creator" => meta.fetch("creator", nil),
          "contributor" => meta.fetch("contributor", nil),
          "publisher" => meta.fetch("publisher", nil),
          "periodical" => meta.fetch("periodical", nil),
          "agency" => "DataCite",
          "funding_references" => meta.fetch("fundingReferences", nil),
          "related_identifiers" => Array.wrap(meta.fetch("relatedIdentifiers", nil)),
          "dates" => dates,
          "publication_year" => meta.fetch("publicationYear", nil),
          "descriptions" => meta.fetch("descriptions", nil),
          "rights_list" => meta.fetch("rightsList", nil),
          "version_info" => meta.fetch("version", nil),
          "subjects" => meta.fetch("subjects", nil),
          "language" => meta.fetch("language", nil),
          "sizes" => meta.fetch("sizes", nil),
          "formats" => meta.fetch("formats", nil),
          "geo_locations" => meta.fetch("geoLocations", nil),
          "schema_version" => meta.fetch("schemaVersion", nil),
          "state" => state
        }.merge(read_options)
      end
    end
  end
end
