module Bolognese
  module Readers
    module DataciteJsonReader
      def read_datacite_json(string: nil)
        errors = jsonlint(string)
        return { "errors" => errors } if errors.present?

        meta = string.present? && errors.empty? ? Maremma.from_json(string) : {}

        resource_type_general = meta.fetch("resource-type-general", nil)
        type = Bolognese::Utils::DC_TO_SO_TRANSLATIONS[resource_type_general.to_s.dasherize] || "CreativeWork"

        hsh = { "id" => meta.fetch("id", nil),
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
          "container_title" => meta.fetch("publisher", nil),
          "publisher" => meta.fetch("publisher", nil),
          "provider" => "DataCite",
          #{}"is_part_of" => is_part_of,
          "date_created" => meta.fetch("date-created", nil),
          "date_accepted" => meta.fetch("date-accepted", nil),
          "date_available" => meta.fetch("date-available", nil),
          "date_copyrighted" => meta.fetch("date-copyrighted", nil),
          "date_collected" => meta.fetch("date-collected", nil),
          "date_submitted" => meta.fetch("date-submitted", nil),
          "date_valid" => meta.fetch("date-valid", nil),
          "date_published" => meta.fetch("date-published", nil),
          "date_modified" => meta.fetch("date-modified", nil),
          "publication_year" => meta.fetch("publication-year", nil),
          #{}"volume" => meta.volume.to_s.presence,
          #{}"pagination" => meta.pages.to_s.presence,
          "description" => meta.fetch("description", nil),
          "license" => meta.fetch("license", nil),
          "version" => meta.fetch("version", nil),
          "keywords" => Array.wrap(meta.fetch("subject", nil)).join(", ").presence,
          "language" => meta.fetch("language", nil),
          "content_size" => meta.fetch("size", nil),
          "schema_version" => meta.fetch("schema-version", nil)
        }
        puts hsh
        hsh
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

      # def dates
      #   Array.wrap(metadata.dig("dates", "date"))
      # end
      #
      # #Accepted Available Copyrighted Collected Created Issued Submitted Updated Valid
      #
      # def date(date_type)
      #   dd = dates.find { |d| d["dateType"] == date_type } || {}
      #   dd.fetch("__content__", nil)
      # end

      # def related_identifier
      #   metadata.fetch("related_identifier", nil)
      # end
      #
      # def get_related_identifier(relation_type: nil)
      #   Array.wrap(related_identifier).select { |r| relation_type.split(" ").include?(r["relationType"]) }.unwrap
      # end
      #
      # def is_identical_to
      #   get_related_identifier(relation_type: "IsIdenticalTo")
      # end
      #
      # def is_part_of
      #   get_related_identifier(relation_type: "IsPartOf")
      # end
      #
      # def has_part
      #   get_related_identifier(relation_type: "HasPart")
      # end
      #
      # def is_previous_version_of
      #   get_related_identifier(relation_type: "IsPreviousVersionOf")
      # end
      #
      # def is_new_version_of
      #   get_related_identifier(relation_type: "IsNewVersionOf")
      # end
      #
      # def references
      #   get_related_identifier(relation_type: "Cites IsCitedBy Supplements IsSupplementTo References IsReferencedBy").presence
      # end
    end
  end
end
