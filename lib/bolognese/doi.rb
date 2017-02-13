module Bolognese
  module Doi
    def doi_from_url(url)
      if /(http|https):\/\/(dx\.)?doi\.org\/(\w+)/.match(url)
        uri = Addressable::URI.parse(url)
        uri.path[1..-1].upcase
      elsif id.is_a?(String) && id.starts_with?("doi:")
        url[4..-1].upcase
      end
    end

    def doi_as_url(doi)
      Addressable::URI.encode("https://doi.org/#{clean_doi(doi)}") if doi.present?
    end

    # remove non-printing whitespace
    def clean_doi(doi)
      doi.gsub(/\u200B/, '')
    end
  end
end
