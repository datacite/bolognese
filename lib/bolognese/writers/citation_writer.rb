# frozen_string_literal: true

module Bolognese
  module Writers
    module CitationWriter
      def citation
        cp = CiteProc::Processor.new(style: style, locale: locale, format: 'html')
        cp.import Array.wrap(citeproc_hsh)
        bibliography = cp.render :bibliography, id: normalize_doi(doi)
        bibliography.first
      end
    end
  end
end
