require_relative 'doi_utils'

module Bolognese
  class Datacite < Metadata
    include Bolognese::DoiUtils

    DATACITE_TYPE_TRANSLATIONS = {
      "Audiovisual" => "VideoObject",
      "Collection" => "Collection",
      "Dataset" => "Dataset",
      "Event" => "Event",
      "Image" => "ImageObject",
      "InteractiveResource" => nil,
      "Model" => nil,
      "PhysicalObject" => nil,
      "Service" => "Service",
      "Software" => "SoftwareSourceCode",
      "Sound" => "AudioObject",
      "Text" => "ScholarlyArticle",
      "Workflow" => nil,
      "Other" => "CreativeWork"
    }

    attr_reader = :id, :metadata, :schema_org

    def initialize(doi)
      @id = normalize_doi(doi)
    end

    def raw
      response = Maremma.get(id, accept: "application/vnd.datacite.datacite+xml", raw: true)
      @raw = response.body.fetch("data", nil)
    end

    def metadata
      @metadata ||= raw.present? ? Maremma.from_xml(raw).fetch("resource", {}) : {}
    end

    def exists?
      metadata.present?
    end

    def type
      k = metadata.dig("resourceType", "resourceTypeGeneral")
      DATACITE_TYPE_TRANSLATIONS[k.to_s.dasherize] || "CreativeWork"
    end

    def additional_type
      metadata.fetch("resourceType", {}).fetch("text", nil) ||
      metadata.fetch("resourceType", {}).fetch("resourceTypeGeneral", nil)
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
