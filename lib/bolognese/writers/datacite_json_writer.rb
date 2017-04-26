module Bolognese
  module Writers
    module DataciteJsonWriter
      def datacite_json
        hsh = {
          "id" => id,
          "doi" => doi,
          "creator" => author,
          "title" => title,
          "publisher" => publisher,
          "publication-year" => publication_year,
          "resource-type-general" => resource_type_general,
          "resource-type" => additional_type,
          "subject" => keywords.present? ? keywords.split(", ") : nil,
          "contributor" => contributor,
          "date-accepted" => date_accepted,
          "date-available" => date_available,
          "date-copyrighted" => date_copyrighted,
          "date-collected" => date_collected,
          "date-created" => date_created,
          "date-published" => date_published,
          "date-modified" => date_modified,
          "date-submitted" => date_submitted,
          "date-valid" => date_valid,
          "language" => language,
          "alternate-identifier" => alternate_name,
          "related_identifier" => related_identifier,
          "size" => content_size,
          "format" => format,
          "version" => version,
          "rights" => license,
          "description" => description,
          "geo-location" => spatial_coverage,
          "funding-reference" => funder,
          "schemaVersion" => schema_version,
          "provider" => provider
        }.compact
        JSON.pretty_generate hsh.presence
      end
    end
  end
end
