# frozen_string_literal: true

module Bolognese
  module Writers
    module BibtexWriter
      def bibtex
        return nil unless valid?

        bib = {
          bibtex_type: types["bibtex"].presence || "misc",
          bibtex_key: identifier,
          doi: doi,
          url: url,
          author: authors_as_string(creator),
          keywords: subjects.present? ? Array.wrap(subjects).map { |k| parse_attributes(k, content: "subject", first: true) }.join(", ") : nil,
          language: language,
          title: parse_attributes(titles, content: "title", first: true),
          journal: periodical && periodical["title"],
          volume: volume,
          issue: issue,
          pages: [first_page, last_page].compact.join("-").presence,
          publisher: publisher,
          year: publication_year
        }.compact
        BibTeX::Entry.new(bib).to_s
      end
    end
  end
end
