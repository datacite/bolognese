module Bolognese
  module Utils
    def parse_attributes(element)
      if element.is_a?(String)
        element
      elsif element.is_a?(Hash)
        element.fetch("text", nil)
      elsif element.is_a?(Array)
        element.map { |e| e.fetch("text", nil) }
      else
        nil
      end
    end

    def parse_attribute(element)
      if element.is_a?(String)
        element
      elsif element.is_a?(Hash)
        element.fetch("text", nil)
      elsif element.is_a?(Array)
        element.first.fetch("text", nil)
      else
        nil
      end
    end
  end
end
