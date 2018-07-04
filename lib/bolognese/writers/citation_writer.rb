# frozen_string_literal: true

module Bolognese
  module Writers
    module CitationWriter
      def citation
        params = { style: style, locale: locale }
        citation_url = "https://citation.crosscite.org/format?" + URI.encode_www_form(params)
        response = Maremma.post citation_url, content_type: 'json', data: citeproc
        response.body.fetch("data", nil)
      end
    end
  end
end
