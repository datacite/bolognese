module Bolognese
  module Writers
    module BibtexWriter
      def bibtex
        bib = {
          bibtex_type: bibtex_type.present? ? bibtex_type.to_sym : "misc",
          bibtex_key: id,
          doi: doi,
          url: url,
          author: authors_as_string(author),
          keywords: keywords,
          language: language,
          title: title,
          journal: journal,
          pages: pagination,
          publisher: publisher,
          year: publication_year
        }.compact
        BibTeX::Entry.new(bib).to_s
      end
    end
  end
end
