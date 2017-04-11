module Bolognese
  module DoiUtils
    def validate_doi(doi)
      Array(/\A(?:(http|https):\/(\/)?(dx\.)?doi.org\/)?(doi:)?(10\.\d{4,5}\/.+)\z/.match(doi)).last
    end

    def validate_prefix(doi)
      Array(/\A(?:(http|https):\/(\/)?(dx\.)?doi.org\/)?(doi:)?(10\.\d{4,5})\/.+\z/.match(doi)).last
    end

    def normalize_doi(doi)
      doi = validate_doi(doi)
      return nil unless doi.present?

      # remove non-printing whitespace and downcase
      doi = doi.delete("\u200B").downcase

      # turn DOI into URL, escape unsafe characters
      "https://doi.org/" + Addressable::URI.encode(doi)
    end

    def doi_from_url(url)
      if /\A(?:(http|https):\/\/(dx\.)?doi.org\/)?(doi:)?(10\.\d{4,5}\/.+)\z/.match(url)
        uri = Addressable::URI.parse(url)
        uri.path.gsub(/^\//, '').downcase
      end
    end

    def doi_as_url(doi)
      "https://doi.org/#{clean_doi(doi)}" if doi.present?
    end

    # get DOI registration agency
    def get_doi_ra(doi)
      prefix = validate_prefix(doi)
      return nil if prefix.blank?

      url = "https://api.datacite.org/prefixes/#{prefix}"
      result = Maremma.get(url)

      result.body.fetch("data", {}).fetch('attributes', {}).fetch('registration-agency', nil)
    end
  end
end
