module Bolognese
  module Writers
    module DataciteJsonWriter
      def datacite_json
        hsh = {
          "id" => id,
          "doi" => doi,
          "url" => url,
          "creator" => author,
          "title" => title,
          "publisher" => publisher,
          "resource_type_general" => resource_type_general,
          "resource_type" => additional_type,
          "subject" => keywords.present? ? keywords.split(", ") : nil,
          "contributor" => contributor,
          "date_accepted" => date_accepted,
          "date_available" => date_available,
          "date_copyrighted" => date_copyrighted,
          "date_collected" => date_collected,
          "date_created" => date_created,
          "date_published" => date_published,
          "date_modified" => date_modified,
          "date_submitted" => date_submitted,
          "date_registered" => date_registered,
          "date_updated" => date_updated,
          "date_valid" => date_valid,
          "publication_year" => publication_year,
          "language" => language,
          "alternate_identifier" => alternate_name,
          "references" => references,
          "is_referenced_by" => is_referenced_by,
          "is_part_of" => is_part_of,
          "has_part" => has_part,
          "size" => content_size,
          "format" => format,
          "version" => version,
          "rights" => license,
          "description" => description,
          "geo-location" => spatial_coverage,
          "funding-reference" => funding,
          "schemaVersion" => schema_version,
          "member_id" => member_id,
          "data_center_id" => data_center_id,
          "provider" => provider
        }.compact
        JSON.pretty_generate hsh.presence
      end
    end
  end
end
