# frozen_string_literal: true

module Bolognese
  module Writers
    module CrossciteWriter
      def crosscite
        JSON.pretty_generate crosscite_hsh.presence
      end
    end
  end
end
