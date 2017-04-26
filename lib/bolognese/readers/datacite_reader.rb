module Bolognese
  module Readers
    module DataciteReader
      def read_datacite(id: nil, string: nil)
        if id.present?
          doi = doi_from_url(id)
          url = "https://search.datacite.org/api?q=doi:#{doi}&fl=doi,xml,media,minted,updated&wt=json"
          response = Maremma.get url
          attributes = response.body.dig("data", "response", "docs").first
          @raw = attributes.fetch('xml', "PGhzaD48L2hzaD4=\n")
          @raw = Base64.decode64(@raw)
          @doc = Nokogiri::XML(@raw, nil, 'UTF-8', &:noblanks) if @raw.present?
          @raw = @doc.to_s if @raw.present?
        elsif string.present?
          @raw = string
        end
        raw.present? ? Maremma.from_xml(raw).fetch("resource", {}) : {}
      end
    end
  end
end
