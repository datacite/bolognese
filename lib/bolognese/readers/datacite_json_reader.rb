# frozen_string_literal: true

module Bolognese
  module Readers
    module DataciteJsonReader
      def read_datacite_json(string: nil, **options)
        errors = jsonlint(string)
        return { "errors" => errors } if errors.present?

        string.present? ? Maremma.from_json(string).transform_keys! { |key| key.underscore } : {}
      end
    end
  end
end
