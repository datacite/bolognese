module Bolognese
  module Readers
    module DataciteJsonReader
      def read_datacite_json(string: nil)
        errors = jsonlint(string)
        return { "errors" => errors } if errors.present?

        meta = string.present? ? Maremma.from_json(string) : {}

        resource_type_general = meta.fetch("resource-type-general", nil)
        type = Bolognese::Utils::DC_TO_SO_TRANSLATIONS[resource_type_general.to_s.dasherize] || "CreativeWork"

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
          "alternate_name" => meta.fetch("alternate-identifier", nil),
          "author" => meta.fetch("creator", nil),
          "editor" => meta.fetch("contributor", nil),
          "publisher" => meta.fetch("publisher", nil),
          "provider" => "DataCite",
          "is_part_of" => meta.fetch("is_part_of", nil),
          "has_part" => meta.fetch("has_part", nil),
          "references" => meta.fetch("references", nil),
          "is_referenced_by" => meta.fetch("is_referenced_by", nil),
          "date_created" => meta.fetch("date-created", nil),
          "date_accepted" => meta.fetch("date-accepted", nil),
          "date_available" => meta.fetch("date-available", nil),
          "date_copyrighted" => meta.fetch("date-copyrighted", nil),
          "date_collected" => meta.fetch("date-collected", nil),
          "date_submitted" => meta.fetch("date-submitted", nil),
          "date_valid" => meta.fetch("date-valid", nil),
          "date_published" => meta.fetch("date-published", nil),
          "date_modified" => meta.fetch("date-modified", nil),
          "description" => meta.fetch("description", nil),
          "license" => meta.fetch("license", nil),
          "version" => meta.fetch("version", nil),
          "keywords" => meta.fetch("subject", nil),
          "language" => meta.fetch("language", nil),
          "content_size" => meta.fetch("size", nil),
          "schema_version" => meta.fetch("schema-version", nil)
        }
      end

      # def funder
      #   f = funder_contributor + funding_reference
      #   f.length > 1 ? f : f.first
      # end
      #
      # def funder_contributor
      #   Array.wrap(metadata.dig("contributors", "contributor")).reduce([]) do |sum, f|
      #     if f["contributorType"] == "Funder"
      #       sum << { "name" => f["contributorName"] }
      #     else
      #       sum
      #     end
      #   end
      # end
      #
      # def funding_reference
      #   Array.wrap(metadata.dig("fundingReferences", "fundingReference")).map do |f|
      #     funder_id = parse_attributes(f["funderIdentifier"])
      #     { "identifier" => normalize_id(funder_id),
      #       "name" => f["funderName"] }.compact
      #   end.uniq
      # end
    end
  end
end
