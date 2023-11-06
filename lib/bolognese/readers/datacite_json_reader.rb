# frozen_string_literal: true

module Bolognese
  module Readers
    module DataciteJsonReader
      def read_datacite_json(string: nil, **options)
        errors = jsonlint(string)
        return { "errors" => errors } if errors.present?

        datacite_json = string.present? ? Maremma.from_json(string).transform_keys! { |key| key.underscore } : {}
        datacite_json["publisher"] = normalize_publisher(datacite_json.fetch("publisher", nil)) if datacite_json.fetch("publisher", nil).present?

        datacite_json
      end
    end
  end
end
