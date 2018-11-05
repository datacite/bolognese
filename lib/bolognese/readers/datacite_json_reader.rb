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
          { "id" => ri["id"],
            "relation_type" => ri["relation-type"],
            "related_identifier_type" => ri["related-identifier-type"],
            "resource_type_general" => ri["resource-type-general"] }.compact
        end
        dates = Array.wrap(meta.fetch("dates", nil)).map do |d|
          { "date" => d["date"],
            "date_type" => d["date-type"] }.compact
        end
        dates << { "date" => meta.fetch("publication-year", nil), "date_type" => "Issued" } if meta.fetch("publication-year", nil).present? && get_date(dates, "Issued").blank?
        resource_type_general = meta.fetch("resource-type-general", nil)
        resource_type = meta.fetch("resource-type", nil)
        type = Bolognese::Utils::CR_TO_SO_TRANSLATIONS[resource_type.to_s.underscore.camelcase] || Bolognese::Utils::DC_TO_SO_TRANSLATIONS[resource_type_general.to_s.dasherize] || "CreativeWork"
        types = {
          "type" => type,
          "resource_type_general" => resource_type_general,
          "resource_type" => resource_type,
          "citeproc" => Bolognese::Utils::CR_TO_CP_TRANSLATIONS[resource_type.to_s.underscore.camelcase] || Bolognese::Utils::SO_TO_CP_TRANSLATIONS[type] || "article",
          "bibtex" => Bolognese::Utils::CR_TO_BIB_TRANSLATIONS[resource_type.to_s.underscore.camelcase] || Bolognese::Utils::SO_TO_BIB_TRANSLATIONS[type] || "misc",
          "ris" => Bolognese::Utils::CR_TO_RIS_TRANSLATIONS[resource_type.to_s.underscore.camelcase] || Bolognese::Utils::DC_TO_RIS_TRANSLATIONS[resource_type_general.to_s.dasherize] || "GEN"
        }.compact

        { "id" => meta.fetch("id", nil),
          "types" => types,
          "doi" => validate_doi(meta.fetch("doi", nil)),
          "url" => normalize_id(meta.fetch("url", nil)),
          "title" => meta.fetch("title", nil),
          "alternate_identifiers" => meta.fetch("alternate-identifiers", nil),
          "creator" => meta.fetch("creator", nil),
          "editor" => meta.fetch("contributor", nil),
          "publisher" => meta.fetch("publisher", nil),
          "periodical" => meta.fetch("periodical", nil),
          "service_provider" => "DataCite",
          "funding_references" => meta.fetch("funding-references", nil),
          "related_identifiers" => related_identifiers,
          "dates" => dates,
          "publication_year" => meta.fetch("publication-year", nil),
          "description" => meta.fetch("description", nil),
          "rights" => meta.fetch("rights", nil),
          "version" => meta.fetch("version", nil),
          "keywords" => meta.fetch("subject", nil),
          "language" => meta.fetch("language", nil),
          "size" => meta.fetch("size", nil),
          "formats" => meta.fetch("formats", nil),
          "geo_location" => meta.fetch("geo-location", nil),
          "schema_version" => meta.fetch("schema-version", nil),
          "state" => state
        }
      end
    end
  end
end
