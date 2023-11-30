# frozen_string_literal: true

module Bolognese
  module Readers
    module CrossciteReader
      def read_crosscite(string: nil, **options)
        errors = jsonlint(string)
        return { "errors" => errors } if errors.present?

        crosscite = string.present? ? Maremma.from_json(string) : {}
        crosscite["publisher"] = normalize_publisher(crosscite["publisher"]) if crosscite.fetch("publisher", nil).present?

        crosscite
      end
    end
  end
end
