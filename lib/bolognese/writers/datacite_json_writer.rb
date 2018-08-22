module Bolognese
  # frozen_string_literal: true
  
  module Writers
    module DataciteJsonWriter
      def datacite_json
        hsh = {
          "id" => identifier,
          "doi" => doi,
          "url" => b_url,
          "creator" => author,
          "title" => title,
          "publisher" => publisher,
          "container_title" => container_title,
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
          "alternate_identifier" => alternate_identifier,
          "references" => references,
          "is_referenced_by" => is_referenced_by,
          "is_part_of" => is_part_of,
          "has_part" => has_part,
          "size" => content_size,
          "version" => b_version,
          "rights" => license,
          "description" => description,
          "geo-location" => spatial_coverage,
          "funding-reference" => funding,
          "schemaVersion" => schema_version,
          "provider_id" => provider_id,
          "client_id" => client_id,
          "provider" => service_provider
        }.compact
        JSON.pretty_generate hsh.presence
      end
    end
  end
end
