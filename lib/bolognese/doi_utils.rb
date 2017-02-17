module Bolognese
  module DoiUtils
    def validate_doi(doi)
      Array(/\A(?:(http|https):\/\/(dx\.)?doi.org\/)?(doi:)?(10\.\d{4,5}\/.+)\z/.match(doi)).last
    end

    def normalize_doi(doi)
      doi = validate_doi(doi)
      return nil unless doi.present?

      # remove non-printing whitespace and downcase
      doi = doi.gsub(/\u200B/, '').downcase

      # turn DOI into URL, escape unsafe characters
      "https://doi.org/" + Addressable::URI.encode(doi)
    end

    def doi_from_url(url)
      if /(http|https):\/\/(dx\.)?doi\.org\/(\w+)/.match(url)
        uri = Addressable::URI.parse(url)
        uri.path[1..-1].downcase
      elsif url.is_a?(String) && url.starts_with?("doi:")
        url[4..-1].downcase
      end
    end

    def doi_as_url(doi)
      "https://doi.org/#{clean_doi(doi)}" if doi.present?
    end

    # get DOI registration agency, assume a normalized DOI
    def get_doi_ra(doi)
      return {} if doi.blank?

      url = "https://doi.crossref.org/doiRA/#{doi_from_url(doi)}"
      response = Maremma.get(url, host: true, timeout: 120)

      ra = response.body.fetch("data", {}).first.fetch("RA", nil)
      if ra.present?
        { "id" => ra.downcase,
          "name" => ra }
      else
        { "errors" => response.body.fetch("errors", nil) || response.body.fetch("data", nil) }
      end
    end
  end
end
