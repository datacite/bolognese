module Bolognese
  # frozen_string_literal: true
  
  module Writers
    module DataciteJsonWriter
      def datacite_json
        # Remove the following line for the schema 4.5 release
        if crosscite_hsh.present?
          datacite_json_hsh = crosscite_hsh
          datacite_json_hsh['publisher'] = self.publisher['name'] if self.publisher&.respond_to?(:to_hash) && self.publisher.has_key?('name') && !self.publisher['name'].blank?
          JSON.pretty_generate datacite_json_hsh.transform_keys! { |key| key.camelcase(uppercase_first_letter = :lower) }
        end
      end
    end
  end
end
