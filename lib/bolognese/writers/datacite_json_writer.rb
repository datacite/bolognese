module Bolognese
  # frozen_string_literal: true
  
  module Writers
    module DataciteJsonWriter
      def datacite_json
        # Remove the following line for the schema 4.5 release
        self.publisher = self.publisher['name'] if self.publisher&.respond_to?(:to_hash) && self.publisher.has_key?('name') && !self.publisher['name'].blank?
        JSON.pretty_generate crosscite_hsh.transform_keys! { |key| key.camelcase(uppercase_first_letter = :lower) } if crosscite_hsh.present?
      end
    end
  end
end
