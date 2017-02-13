module Bolognese
  module Datacite
    def get_datacite_metadata(doi, options = {})
      return {} if doi.blank?

      params = { q: "doi:" + doi,
                 rows: 1,
                 fl: "doi,creator,title,publisher,publicationYear,resourceTypeGeneral,resourceType,datacentre,datacentre_symbol,prefix,relatedIdentifier,xml,minted,updated",
                 wt: "json" }
      url = "https://search.datacite.org/api?" + URI.encode_www_form(params)

      response = Maremma.get(url, options)

      metadata = response.body.fetch("data", {}).fetch("response", {}).fetch("docs", []).first
      return { error: 'Resource not found.', status: 404 } if metadata.blank?

      doi = metadata.fetch("doi", nil)
      doi = doi.upcase if doi.present?
      title = metadata.fetch("title", []).first
      title = title.chomp(".") if title.present?

      xml = Base64.decode64(metadata.fetch('xml', "PGhzaD48L2hzaD4=\n"))
      doc = Nokogiri::XML(xml)
      issued = doc.at_xpath('//xmlns:date[@dateType="Issued"]')
      issued = issued.text if issued.present?

      xml = Hash.from_xml(xml).fetch("resource", {})
      authors = xml.fetch("creators", {}).fetch("creator", [])
      authors = [authors] if authors.is_a?(Hash)

      { "author" => get_hashed_authors(authors),
        "title" => title,
        "container-title" => metadata.fetch("publisher", nil),
        "published" => metadata.fetch("publicationYear", nil),
        "deposited" => metadata.fetch("minted", nil),
        "issued" => issued,
        "updated" => metadata.fetch("updated", nil),
        "DOI" => doi,
        "resource_type_id" => metadata.fetch("resourceTypeGeneral", nil),
        "resource_type" => metadata.fetch("resourceType", nil),
        "publisher_id" => metadata.fetch("datacentre_symbol", nil),
        "registration_agency_id" => "datacite" }
    end
  end
end
