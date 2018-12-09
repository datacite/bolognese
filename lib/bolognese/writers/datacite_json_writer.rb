module Bolognese
  # frozen_string_literal: true
  
  module Writers
    module DataciteJsonWriter
      def datacite_json
        JSON.pretty_generate crosscite_hsh.transform_keys! { |key| key.camelcase(uppercase_first_letter = :lower) } if crosscite_hsh.present?
      end
    end
  end
end
