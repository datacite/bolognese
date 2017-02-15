module Bolognese
  class Orcid < Metadata
    include Bolognese::PidUtils
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
  end
end
