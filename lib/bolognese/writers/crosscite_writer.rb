# frozen_string_literal: true

module Bolognese
  module Writers
    module CrossciteWriter
      def crosscite
        hsh = {
          "id" => identifier,
          "doi" => doi,
          "url" => url,
          "types" => types,
          "creator" => creator,
          "titles" => titles,
          "publisher" => publisher,
          "periodical" => periodical,
          "subjects" => subjects,
          "contributor" => contributor,
          "dates" => dates,
          "publication_year" => publication_year,
          "language" => language,
          "alternate_identifiers" => alternate_identifiers,
          "sizes" => sizes,
          "formats" => formats,
          "version" => version_info,
          "rights_list" => rights_list,
          "descriptions" => descriptions,
          "volume" => volume,
          "issue" => issue,
          "first_page" => first_page,
          "last_page" => last_page,
          "geo_locations" => geo_locations,
          "funding_references" => funding_references,
          "related_identifiers" => related_identifiers,
          "schema_version" => schema_version,
          "provider_id" => provider_id,
          "client_id" => client_id,
          "agency" => agency,
          "state" => state
        }.compact
        JSON.pretty_generate hsh.presence
      end
    end
  end
end
