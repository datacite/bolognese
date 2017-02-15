require_relative 'doi'

module Bolognese
  class Datacite
    include Bolognese::Doi

    DATACITE_TYPE_TRANSLATIONS = {
      "Audiovisual" => nil,
      "Collection" => nil,
      "Dataset" => "Dataset",
      "Event" => nil,
      "Image" => nil,
      "InteractiveResource" => nil,
      "Model" => nil,
      "PhysicalObject" => nil,
      "Service" => nil,
      "Software" => nil,
      "Sound" => nil,
      "Text" => nil,
      "Workflow" => nil,
      "Other" => nil
    }

    attr_reader = :id, :metadata, :schema_org

    def initialize(doi)
      @id = normalize_doi(doi)

      response = Maremma.get(@id, accept: "application/vnd.datacite.datacite+xml")
      @metadata = response.body.fetch("data", {}).fetch("resource", {})
    end

    def exists?
      metadata.present?
    end

    def type
      k = metadata.fetch("resourceType", {}).fetch("resourceTypeGeneral", "")
      DATACITE_TYPE_TRANSLATIONS[k.dasherize] || "CreativeWork"
    end

    def name
      metadata.dig("titles", "title")
    end

    def alternate_name
      metadata.dig("alternateIdentifiers", "alternateIdentifier", "text")
    end

    def description
      metadata.dig("descriptions", "description", "text")
    end

    def license
      metadata.dig("rightsList", "rights", "rightsURI")
    end

    def keywords
      Array(metadata.dig("subjects", "subject")).join(", ")
    end

    def author
      authors = metadata.dig("creators", "creator")
      authors = [authors] if authors.is_a?(Hash)
      get_authors(authors)
    end

    def version
      metadata.fetch("version")
    end

    def date_published
      metadata.fetch("publicationYear")
    end

    def date_modified

    end

    def related_identifiers(relation_type)
      Array(metadata.dig("relatedIdentifiers", "relatedIdentifier"))
        .select { |r| relation_type.split(" ").include?(r["relationType"]) && %w(DOI URL).include?(r["relatedIdentifierType"]) }
        .map do |work|
          work_id = work["relatedIdentifierType"] == "DOI" ? normalize_doi(work["text"]) : work["text"]
          { "@type" => "CreativeWork",
            "@id" => work_id }
        end
    end

    def is_part_of
      related_identifiers("IsPartOf").first
    end

    def has_part
      related_identifiers("HasPart")
    end

    def citation
      related_identifiers("Cites IsCitedBy Supplements IsSupplementTo References IsReferencedBy")
    end

    # def get_datacite_metadata(doi, options = {})
    #   return { error: 'No DOI provided.'} if doi.blank?

    #   params = { q: "doi:" + doi,
    #              rows: 1,
    #              fl: "doi,creator,title,publisher,publicationYear,resourceTypeGeneral,resourceType,datacentre,datacentre_symbol,prefix,relatedIdentifier,xml,minted,updated",
    #              wt: "json" }
    #   url = "https://search.datacite.org/api?" + URI.encode_www_form(params)

    #   response = Maremma.get(url, options)

    #   metadata = response.body.fetch("data", {}).fetch("response", {}).fetch("docs", []).first
    #   return { error: 'Resource not found.', status: 404 } if metadata.blank?

    #   doi = metadata.fetch("doi", nil)
    #   doi = doi.upcase if doi.present?
    #   title = metadata.fetch("title", []).first
    #   title = title.chomp(".") if title.present?

    #   xml = Base64.decode64(metadata.fetch('xml', "PGhzaD48L2hzaD4=\n"))
    #   doc = Nokogiri::XML(xml)
    #   issued = doc.at_xpath('//xmlns:date[@dateType="Issued"]')
    #   issued = issued.text if issued.present?

    #   xml = Hash.from_xml(xml).fetch("resource", {})
    #   authors = xml.fetch("creators", {}).fetch("creator", [])
    #   authors = [authors] if authors.is_a?(Hash)

    #   { "author" => get_hashed_authors(authors),
    #     "title" => title,
    #     "container-title" => metadata.fetch("publisher", nil),
    #     "published" => metadata.fetch("publicationYear", nil),
    #     "deposited" => metadata.fetch("minted", nil),
    #     "issued" => issued,
    #     "updated" => metadata.fetch("updated", nil),
    #     "DOI" => doi,
    #     "resource_type_id" => metadata.fetch("resourceTypeGeneral", nil),
    #     "resource_type" => metadata.fetch("resourceType", nil),
    #     "publisher_id" => metadata.fetch("datacentre_symbol", nil),
    #     "registration_agency_id" => "datacite" }
    # end

    def publisher
      metadata.fetch("publisher")
    end

    def provider
      { "@type" => "Organization",
        "name" => "DataCite" }
    end

    def as_schema_org
      { "@context" => "http://schema.org",
        "@type" => type,
        "@id" => id,
        "name" => name,
        "alternateName" => alternate_name,
        "author" => author,
        "editor" => editor,
        "description" => description,
        "license" => license,
        "version" => version,
        "keywords" => keywords,
        "datePublished" => date_published,
        "dateModified" => date_modified,
        "pageStart" => page_start,
        "pageEnd" => page_end,
        "isPartOf" => is_part_of,
        "hasPart" => has_part,
        "citation" => citation,
        "publisher" => publisher,
        "provider" => provider
      }.compact
    end
  end
end
