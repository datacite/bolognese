# frozen_string_literal: true

module Bolognese
  module Writers
    module CrossciteWriter
      def crosscite
        hsh = {
          "id" => id,
          "doi" => doi,
          "url" => url,
          "types" => types,
          "creators" => creators,
          "titles" => titles,
          "publisher" => publisher,
          "container" => container,
          "subjects" => subjects,
          "contributors" => contributors,
          "dates" => dates,
          "publication_year" => publication_year,
          "language" => language,
          "identifiers" => identifiers,
          "sizes" => sizes,
          "formats" => formats,
          "version" => version_info,
          "rights_list" => rights_list,
          "descriptions" => descriptions,
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
