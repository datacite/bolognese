module Bolognese
  module Writers
    module BibtexWriter
      def bibtex
        bib = {
          bibtex_type: bibtex_type.presence || "misc",
          bibtex_key: id,
          doi: doi,
          url: url,
          author: authors_as_string(author),
          keywords: keywords,
          language: language,
          title: title,
          journal: container_title,
          volume: volume,
          issue: issue,
          pages: pagination,
          publisher: publisher,
          year: publication_year
        }.compact
        BibTeX::Entry.new(bib).to_s
      end
    end
  end
end
