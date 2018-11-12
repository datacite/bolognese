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
          "titles" => titles,
          "publisher" => publisher,
          "periodical" => periodical,
          "types" => to_datacite_json(types, first: true),
          "subjects" => to_datacite_json(subjects),
          "contributor" => contributor,
          "dates" => to_datacite_json(dates),
          "publication-year" => publication_year,
          "language" => language,
          "alternate-identifiers" => to_datacite_json(alternate_identifiers),
          "related-identifiers" => to_datacite_json(related_identifiers),
          "sizes" => sizes,
          "formats" => formats,
          "version" => version,
          "rights-list" => to_datacite_json(rights_list),
          "descriptions" => to_datacite_json(descriptions),
          "geo-locations" => to_datacite_json(geo_locations),
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
