# frozen_string_literal: true

module Bolognese
  module Writers
    module CitationWriter
      def citation
        cp = CiteProc::Processor.new(style: style, locale: locale, format: 'html')
        cp.import Array.wrap(citeproc_hsh)
        bibliography = cp.render :bibliography, id: id
        bibliography.first
      end
    end
  end
end
