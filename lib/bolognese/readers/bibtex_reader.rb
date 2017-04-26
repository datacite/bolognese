module Bolognese
  module Readers
    module BibtexReader
      def read_bibtex(id: nil, string: nil)
        string.present? ? BibTeX.parse(string).first : {}
      end
    end
  end
end
