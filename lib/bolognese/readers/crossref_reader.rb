module Bolognese
  module Readers
    module CrossrefReader
      CONTACT_EMAIL = "tech@datacite.org"
      
      def read_crossref(id: nil, string: nil)
        id = normalize_doi(id) if id.present?

        if string.present?
          @raw = string
        elsif id.present?
          doi = doi_from_url(id)
          url = "http://www.crossref.org/openurl/?id=doi:#{doi}&noredirect=true&pid=#{CONTACT_EMAIL}&format=unixref"
          response = Maremma.get(url, accept: "text/xml", raw: true)
          @raw = response.body.fetch("data", nil)
          @raw = Nokogiri::XML(@raw, nil, 'UTF-8', &:noblanks).to_s if @raw.present?
        end

        if raw.present?
          m = Maremma.from_xml(raw).fetch("doi_records", {}).fetch("doi_record", {})
          m.dig("crossref", "error").nil? ? m : {}
        else
          {}
        end
      end
    end
  end
end
