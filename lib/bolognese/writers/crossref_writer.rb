module Bolognese
  module Writers
    module CrossrefWriter
      def crossref
        from == "crossref" ? raw : nil
      end
    end
  end
end
