module Bolognese
  module Utils
    def set_metadata(id: nil, string: nil, provider: nil, **options)
      output = options[:as] || "schema_org"

      if provider.present?
        p = case provider
            when "crossref" then Crossref.new(id: id)
            when "datacite" then Datacite.new(id: id, schema_version: options[:schema_version])
            when "bibtex" then Bibtex.new(string: string)
            else SchemaOrg.new(id: id)
            end

        puts p.send(output)
      else
        puts "not implemented"
      end
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
        element.fetch("__content__", nil)
      elsif element.is_a?(Array)
        element.map { |e| e.fetch("__content__", nil) }
      else
        nil
      end
    end

    def parse_attribute(element)
      if element.is_a?(String)
        element
      elsif element.is_a?(Hash)
        element.fetch("__content__", nil)
      elsif element.is_a?(Array)
        element.first.fetch("__content__", nil)
      else
        nil
      end
    end

    def find_provider(id)
      id = normalize_id(id)

      if /\A(?:(http|https):\/\/(dx\.)?doi.org\/)?(doi:)?(10\.\d{4,5}\/.+)\z/.match(id)
        get_doi_ra(id).fetch("id", nil)
      elsif /\A(?:(http|https):\/\/orcid\.org\/)?(\d{4}-\d{4}-\d{4}-\d{3}[0-9X]+)\z/.match(id)
        "orcid"
      else
        "schema_org"
      end
    end

    def normalize_id(id)
      return nil unless id.present?

      normalize_doi(id) || PostRank::URI.clean(id)
    end

    def normalize_orcid(orcid)
      orcid = validate_orcid(orcid)
      return nil unless orcid.present?

      # turn ORCID ID into URL
      "http://orcid.org/" + Addressable::URI.encode(orcid)
    end

    def normalize_ids(list)
      Array.wrap(list).map { |url| url.merge("@id" => normalize_id(url["@id"])) }
    end
  end
end
