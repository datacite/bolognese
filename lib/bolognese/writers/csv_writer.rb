module Bolognese
  module Writers
    module CsvWriter
      require "csv"

      def csv
        return nil unless valid?

        pages = container.to_h["firstPage"].present? ? [container["firstPage"], container["lastPage"]].join("-") : nil

        bib = {
          doi: doi,
          url: url,
          year: publication_year,
          registered: get_iso8601_date(date_registered),
          state: state,
          resource_type_general: types["resourceTypeGeneral"],
          bibtex_type: types["bibtex"].presence || "misc",
          title: parse_attributes(titles, content: "title", first: true),
          author: authors_as_string(creators),
          publisher: publisher,
          journal: container && container["title"],
          volume: container.to_h["volume"],
          issue: container.to_h["issue"],
          pages: pages
        }.values

        CSV.generate { |csv| csv << bib }
      end
    end
  end
end
