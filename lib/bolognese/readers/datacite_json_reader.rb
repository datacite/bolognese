# frozen_string_literal: true

module Bolognese
  module Readers
    module DataciteJsonReader
      def read_datacite_json(string: nil, **options)
        errors = jsonlint(string)
        return { "errors" => errors } if errors.present?

        meta = string.present? ? Maremma.from_json(string) : {}

        state = meta.fetch("doi", nil).present? ? "findable" : "not_found"
        related_identifiers = Array.wrap(meta.fetch("related-identifiers", nil)).map do |ri|
          { "related_identifier" => ri["related-identifier"],
            "relation_type" => ri["relation-type"],
            "related_identifier_type" => ri["related-identifier-type"],
            "resource_type_general" => ri["resource-type-general"] }.compact
        end
        alternate_identifiers = Array.wrap(meta.fetch("alternate-identifiers", nil)).map do |ai|
          { "alternate_identifier" => ai["alternate-identifier"],
            "alternate_identifier_type" => ai["alternate-identifier-type"] }.compact
        end
        dates = Array.wrap(meta.fetch("dates", nil)).map do |d|
          { "date" => d["date"],
            "date_type" => d["date-type"],
            "date_information" => d["date-information"] }.compact
        end
        dates << { "date" => meta.fetch("publication-year", nil), "date_type" => "Issued" } if meta.fetch("publication-year", nil).present? && get_date(dates, "Issued").blank?
        type = meta.dig("types", "type") || Bolognese::Utils::CR_TO_SO_TRANSLATIONS[meta.dig("types", "resource-type").to_s.underscore.camelcase] || Bolognese::Utils::DC_TO_SO_TRANSLATIONS[meta.dig("types", "resource-type-general").to_s.dasherize] || "CreativeWork"
        types = { 
          "type" => type,
          "resource_type_general" => meta.dig("types", "resource-type-general"),
          "resource_type" => meta.dig("types", "resource-type"),
          "bibtex" => meta.dig("types", "bibtex") || Bolognese::Utils::CR_TO_BIB_TRANSLATIONS[meta.dig("types", "resource-type").to_s.underscore.camelcase] || Bolognese::Utils::SO_TO_BIB_TRANSLATIONS[type] || "misc",
          "citeproc" => meta.dig("types", "citeproc") || Bolognese::Utils::CR_TO_CP_TRANSLATIONS[meta.dig("types", "resource-type").to_s.underscore.camelcase] || Bolognese::Utils::SO_TO_CP_TRANSLATIONS[type] || "article",
          "ris" => meta.dig("types", "ris") || Bolognese::Utils::CR_TO_RIS_TRANSLATIONS[meta.dig("types", "resource-type").to_s.underscore.camelcase] || Bolognese::Utils::DC_TO_RIS_TRANSLATIONS[meta.dig("types", "resource-type-general").to_s.dasherize] || "GEN" }.compact

        { "id" => meta.fetch("id", nil),
          "types" => types,
          "doi" => validate_doi(meta.fetch("doi", nil)),
          "url" => normalize_id(meta.fetch("url", nil)),
          "titles" => meta.fetch("titles", nil),
          "alternate_identifiers" => alternate_identifiers,
          "creator" => meta.fetch("creator", nil),
          "contributor" => meta.fetch("contributor", nil),
          "publisher" => meta.fetch("publisher", nil),
          "periodical" => meta.fetch("periodical", nil),
          "service_provider" => "DataCite",
          "funding_references" => meta.fetch("funding-references", nil),
          "related_identifiers" => related_identifiers,
          "dates" => dates,
          "publication_year" => meta.fetch("publication-year", nil),
          "descriptions" => meta.fetch("descriptions", nil),
          "rights_list" => meta.fetch("rights-list", nil),
          "version" => meta.fetch("version", nil),
          "subjects" => meta.fetch("subjects", nil),
          "language" => meta.fetch("language", nil),
          "sizes" => meta.fetch("sizes", nil),
          "formats" => meta.fetch("formats", nil),
          "geo_locations" => meta.fetch("geo-locations", nil),
          "schema_version" => meta.fetch("schema-version", nil),
          "state" => state
        }
      end
    end
  end
end
