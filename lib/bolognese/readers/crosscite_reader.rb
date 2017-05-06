module Bolognese
  module Readers
    module CrossciteReader
      def read_citeproc(string: nil)
        errors = jsonlint(string)
        return { "errors" => errors } if errors.present?

        string.present? ? Maremma.from_json(string) : {}
      end
    end
  end
end
