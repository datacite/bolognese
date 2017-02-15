module Bolognese
  module PidUtils
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
  end
end
