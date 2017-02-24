require_relative 'doi_utils'
require_relative 'author_utils'
require_relative 'date_utils'
require_relative 'datacite_utils'
require_relative 'utils'

module Bolognese
  class Metadata
    include Bolognese::DoiUtils
    include Bolognese::AuthorUtils
    include Bolognese::DateUtils
    include Bolognese::DataciteUtils
    include Bolognese::Utils

    attr_reader :id, :raw, :provider, :schema_version, :license, :citation,
      :additional_type, :alternate_name, :url, :version, :keywords, :editor,
      :page_start, :page_end, :date_modified, :language, :spatial_coverage,
      :content_size, :funder, :journal, :bibtex_type, :date_created, :has_part,
      :publisher, :contributor, :schema_version, :same_as, :predecessor_of,
      :successor_of

    alias_method :datacite, :as_datacite

    def publication_year
      date_published && date_published[0..3]
    end

    def descriptions
      Array.wrap(description)
    end

    def pagination
      [page_start, page_end].compact.join("-").presence
    end

    def publisher_string
      publisher.to_h.fetch("name", nil)
    end

    def as_schema_org
      { "@context" => id.present? ? "http://schema.org" : nil,
        "@type" => type,
        "@id" => id,
        "url" => url,
        "additionalType" => additional_type,
        "name" => name,
        "alternateName" => alternate_name,
        "author" => author,
        "editor" => editor,
        "description" => description,
        "license" => license,
        "version" => version,
        "keywords" => keywords,
        "language" => language,
        "contentSize" => content_size,
        "dateCreated" => date_created,
        "datePublished" => date_published,
        "dateModified" => date_modified,
        "pageStart" => page_start,
        "pageEnd" => page_end,
        "spatialCoverage" => spatial_coverage,
        "sameAs" => same_as,
        "isPartOf" => is_part_of,
        "hasPart" => has_part,
        "predecessor_of" => predecessor_of,
        "successor_of" => successor_of,
        "citation" => citation,
        "schemaVersion" => schema_version,
        "publisher" => publisher,
        "funder" => funder,
        "provider" => provider
      }.compact.to_json
    end

    def as_codemeta
      { "@context" => id.present? ? "https://raw.githubusercontent.com/codemeta/codemeta/master/codemeta.jsonld" : nil,
        "@type" => type,
        "@id" => id,
        "identifier" => id,
        "codeRepository" => url,
        "title" => name,
        "agents" => author,
        "description" => description,
        "version" => version,
        "tags" => keywords.to_s.split(", ").presence,
        "dateCreated" => date_created,
        "datePublished" => date_published,
        "dateModified" => date_modified,
        "publisher" => publisher
      }.compact.to_json
    end

    def as_bibtex
      bib = {
        bibtex_type: bibtex_type.to_sym,
        bibtex_key: id,
        doi: doi,
        url: url,
        author: authors_as_string(author),
        keywords: keywords,
        language: language,
        title: name,
        journal: journal,
        pages: pagination,
        publisher: publisher_string,
        year: publication_year
      }.compact

      BibTeX::Entry.new(bib).to_s
    end
  end
end
