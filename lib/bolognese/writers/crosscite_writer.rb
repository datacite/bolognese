module Bolognese
  module Writers
    module CrossciteWriter
      def crosscite
        return nil unless valid?

        hsh = {
          "id" => id,
          "doi" => doi,
          "url" => url,
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
          "date_valid" => date_valid,
          "language" => language,
          "alternate_name" => alternate_name,
          "references" => references,
          "content_size" => content_size,
          "format" => format,
          "version" => version,
          "license" => license,
          "description" => description,
          "volume" => volume,
          "issue" => issue,
          "pagination" => pagination,
          "spatial_coverage" => spatial_coverage,
          "funding" => funding,
          "schema_version" => schema_version,
          "member_id" => member_id,
          "data_center_id" => data_center_id,
          "provider" => provider
        }.compact
        JSON.pretty_generate hsh.presence
      end
    end
  end
end
