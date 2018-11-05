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
          "title" => title,
          "publisher" => publisher,
          "periodical" => periodical,
          "keywords" => keywords,
          "contributor" => contributor,
          "dates" => dates,
          "publication_year" => publication_year,
          "language" => language,
          "alternate_identifiers" => alternate_identifiers,
          "size" => size,
          "formats" => formats,
          "version" => version,
          "rights" => rights,
          "description" => description,
          "volume" => volume,
          "issue" => issue,
          "first_page" => first_page,
          "last_page" => last_page,
          "geo_location" => geo_location,
          "funding_references" => funding_references,
          "related_identifiers" => related_identifiers,
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
