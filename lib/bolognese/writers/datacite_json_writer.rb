module Bolognese
  # frozen_string_literal: true
  
  module Writers
    module DataciteJsonWriter
      def datacite_json
        hsh = {
          "id" => id,
          "doi" => doi,
          "url" => url,
          "creators" => creators,
          "titles" => titles,
          "publisher" => publisher,
          "container" => container,
          "types" => to_datacite_json(types, first: true),
          "subjects" => to_datacite_json(subjects),
          "contributors" => contributors,
          "dates" => to_datacite_json(dates),
          "publicationYear" => publication_year,
          "language" => language,
          "identifiers" => to_datacite_json(identifiers),
          "relatedIdentifiers" => to_datacite_json(related_identifiers),
          "sizes" => sizes,
          "formats" => formats,
          "version" => version_info,
          "rightsList" => to_datacite_json(rights_list),
          "descriptions" => to_datacite_json(descriptions),
          "geoLocations" => to_datacite_json(geo_locations),
          "fundingReferences" => to_datacite_json(funding_references),
          "schemaVersion" => schema_version,
          "providerId" => provider_id,
          "clientIsd" => client_id,
          "agency" => agency
        }.compact
        JSON.pretty_generate hsh.presence
      end
    end
  end
end
