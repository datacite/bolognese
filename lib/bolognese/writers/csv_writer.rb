module Bolognese
  module Writers
    module CsvWriter
      require "csv"

      def csv
        return nil unless valid?

        bib = {
          doi: doi,
          url: url,
          registered: get_iso8601_date(date_registered),
          state: state,
          resource_type_general: types["resourceTypeGeneral"],
          resource_type: types["resourceType"],
          title: parse_attributes(titles, content: "title", first: true),
          author: authors_as_string(creators),
          publisher:  publisher.present? ? publisher["name"] : nil,
          publication_year: publication_year
        }.values

        CSV.generate { |csv| csv << bib }
      end
    end
  end
end
