module Bolognese
  module Utils
    def normalize_orcid(orcid)
      orcid = validate_orcid(orcid)
      return nil unless orcid.present?

      # turn ORCID ID into URL
      "http://orcid.org/" + Addressable::URI.encode(orcid)
    end

    def orcid_from_url(url)
      Array(/\Ahttp:\/\/orcid\.org\/(.+)/.match(url)).last
    end

    def orcid_as_url(orcid)
      "http://orcid.org/#{orcid}" if orcid.present?
    end

    def validate_orcid(orcid)
      Array(/\A(?:http:\/\/orcid\.org\/)?(\d{4}-\d{4}-\d{4}-\d{3}[0-9X]+)\z/.match(orcid)).last
    end

    def validate_url(str)
      if /\A(?:(http|https):\/\/(dx\.)?doi.org\/)?(doi:)?(10\.\d{4,5}\/.+)\z/.match(str)
        "DOI"
      elsif /\A(http|https):\/\//.match(str)
        "URL"
      end
    end

    def parse_attributes(element)
      if element.is_a?(String)
        element
      elsif element.is_a?(Hash)
        element.fetch("text", nil)
      elsif element.is_a?(Array)
        element.map { |e| e.fetch("text", nil) }
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

    def normalize_url(url)
      return nil unless url.present?

      normalize_doi(url) || PostRank::URI.clean(url)
    end

    def normalize_ids(list)
      Array.wrap(list).map { |url| url.merge("@id" => normalize_url(url["@id"])) }
    end
  end
end
