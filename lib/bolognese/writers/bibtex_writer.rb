# frozen_string_literal: true

module Bolognese
  module Writers
    module BibtexWriter
      def bibtex
        return nil unless valid?

        pages = container.to_h["firstPage"].present? ? [container["firstPage"], container["lastPage"]].join("-") : nil

        bib = {
          bibtex_type: types["bibtex"].presence || "misc",
          bibtex_key: id,
          doi: doi,
          url: url,
          author: authors_as_string(creators),
          keywords: subjects.present? ? Array.wrap(subjects).map { |k| parse_attributes(k, content: "subject", first: true) }.join(", ") : nil,
          language: language,
          title: parse_attributes(titles, content: "title", first: true),
          journal: container && container["title"],
          volume: container.to_h["volume"],
          issue: container.to_h["issue"],
          pages: pages,
          publisher: publisher,
          year: publication_year
        }.compact
        BibTeX::Entry.new(bib).to_s
      end
    end
  end
end
