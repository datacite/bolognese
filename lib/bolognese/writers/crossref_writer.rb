module Bolognese
  module Writers
    module CrossrefWriter
      def crossref
        to == "crossref" ? raw : nil
      end
    end
  end
end
