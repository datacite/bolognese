# frozen_string_literal: true

module Bolognese
  module Readers
    module DataciteJsonReader
      def read_datacite_json(string: nil, **options)
        errors = jsonlint(string)
        return { "errors" => errors } if errors.present?

        meta = string.present? ? Maremma.from_json(string) : {}

        resource_type_general = meta.fetch("resource-type-general", nil)
        type = Bolognese::Utils::DC_TO_SO_TRANSLATIONS[resource_type_general.to_s.dasherize] || "CreativeWork"
        state = meta.fetch("doi", nil).present? ? "findable" : "not_found"
        related_identifiers = Array.wrap(meta.fetch("related-identifiers", nil)).map do |ri|
          { "id" => ri["id"],
            "relation_type" => ri["relation-type"],
            "related_identifier_type" => ri["related-identifier-type"],
            "resource_type_general" => ri["resource-type-general"] }.compact
        end

        { "id" => meta.fetch("id", nil),
          "type" => type,
          "additional_type" => meta.fetch("resource-type", nil),
          "citeproc_type" => Bolognese::Utils::DC_TO_CP_TRANSLATIONS[resource_type_general.to_s.dasherize] || "other",
          "bibtex_type" => Bolognese::Utils::SO_TO_BIB_TRANSLATIONS[type] || "misc",
          "ris_type" => Bolognese::Utils::SO_TO_RIS_TRANSLATIONS[resource_type_general.to_s.dasherize] || "GEN",
          "resource_type_general" => resource_type_general,
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
          "dates" => meta.fetch("dates", nil),
          "date_published" => meta.fetch("date-published", nil) || meta.fetch("publication-year", nil),
          "date_modified" => meta.fetch("date-modified", nil),
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
