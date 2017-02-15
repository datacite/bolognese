module Bolognese
  class Orcid
    # def get_orcid_metadata(orcid, options = {})
    #   return {} if orcid.blank?

    #   url = "https://pub.orcid.org/v2.0/#{orcid}/person"
    #   response = Maremma.get(url, options.merge(accept: "json"))

    #   name = response.body.fetch("data", {}).fetch("name", nil)
    #   return { "errors" => 'Resource not found.' } unless name.present?

    #   author = { "family" => name.fetch("family-name", {}).fetch("value", nil),
    #              "given" => name.fetch("given-names", {}).fetch("value", nil) }

    #   { "author" => [author],
    #     "title" => "ORCID record for #{[author.fetch('given', nil), author.fetch('family', nil)].compact.join(' ')}",
    #     "container-title" => "ORCID Registry",
    #     "issued" => Time.now.year.to_s,
    #     "URL" => orcid_as_url(orcid),
    #     "type" => 'entry' }
    # end

    def normalize_orcid(orcid)
      orcid = validate_orcid(orcid)
      return nil unless orcid.present?

      # turn ORCID ID into URL
      doi = "http://orcid.org/" + Addressable::URI.encode(doi)
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
