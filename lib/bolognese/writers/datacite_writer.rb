# frozen_string_literal: true

module Bolognese
  module Writers
    module DataciteWriter
      # generate new DataCite XML version 4.0 if regenerate (!should_passthru) option is provided
      def datacite
        should_passthru ? raw : datacite_xml
      end
    end
  end
end
