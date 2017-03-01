module Bolognese
  class DataciteJson < Datacite

    def initialize(string: nil, regenerate: false)
      if string.present?
        @raw = string
      end
    end

    def metadata
      @metadata ||= raw.present? ? Maremma.from_json(raw).fetch("resource", {}) : {}
    end

    def datacite
      datacite_xml
    end
  end
end
