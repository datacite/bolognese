module Bolognese
  # frozen_string_literal: true
  
  module Writers
    module DataciteJsonWriter
      def datacite_json
        hsh = {
          "id" => identifier,
          "doi" => doi,
          "url" => url,
          "creator" => creator,
          "title" => title,
          "publisher" => publisher,
          "container-title" => periodical && periodical["title"],
          "resource-type-general" => resource_type_general,
          "resource-type" => additional_type,
          "subject" => keywords.present? ? keywords.split(", ") : nil,
          "contributor" => contributor,
          "dates" => to_datacite_json(dates),
          "publication-year" => publication_year,
          "language" => language,
          "alternate-identifiers" => alternate_identifiers,
          "related-identifiers" => to_datacite_json(related_identifiers),
          "size" => size,
          "formats" => formats,
          "version" => version,
          "rights" => rights,
          "description" => description,
          "geo-location" => geo_location,
          "funding-references" => to_datacite_json(funding_references),
          "schema-version" => schema_version,
          "provider-id" => provider_id,
          "client-id" => client_id,
          "provider" => service_provider
        }.compact
        JSON.pretty_generate hsh.presence
      end
    end
  end
end
