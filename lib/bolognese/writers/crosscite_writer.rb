# frozen_string_literal: true

module Bolognese
  module Writers
    module CrossciteWriter
      def crosscite
        hsh = {
          "id" => identifier,
          "doi" => doi,
          "url" => b_url,
          "type" => type,
          "additional_type" => additional_type,
          "citeproc_type" => citeproc_type,
          "bibtex_type" => bibtex_type,
          "ris_type" => ris_type,
          "resource_type_general" => resource_type_general,
          "resource_type" => additional_type,
          "author" => author,
          "title" => title,
          "publisher" => publisher,
          "container_title" => container_title,
          "keywords" => keywords,
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
          "language" => language,
          "alternate_identifier" => alternate_identifier,
          "content_size" => content_size,
          "version" => b_version,
          "license" => license,
          "description" => description,
          "volume" => volume,
          "issue" => issue,
          "first_page" => first_page,
          "last_page" => last_page,
          "spatial_coverage" => spatial_coverage,
          "funding" => funding,
          "is_identical_to" => is_identical_to,
          "is_part_of" => is_part_of,
          "has_part" => has_part,
          "is_previous_version_of" => is_previous_version_of,
          "is_new_version_of" => is_new_version_of,
          "is_variant_form_of" => is_variant_form_of,
          "is_original_form_of" => is_original_form_of,
          "references" => references,
          "is_referenced_by" => is_referenced_by,
          "is_supplement_to" => is_supplement_to,
          "is_supplemented_by" => is_supplemented_by,
          "reviews" => reviews,
          "is_reviewed_by" => is_reviewed_by,
          "schema_version" => schema_version,
          "provider_id" => provider_id,
          "client_id" => client_id,
          "provider" => service_provider,
          "state" => state
        }.compact
        JSON.pretty_generate hsh.presence
      end
    end
  end
end
