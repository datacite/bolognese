# frozen_string_literal: true

require 'json/ld/preloaded'
require 'json/ld'

require_relative 'doi_utils'
require_relative 'author_utils'
require_relative 'datacite_utils'
require_relative 'utils'

require_relative 'readers/bibtex_reader'
require_relative 'readers/citeproc_reader'
require_relative 'readers/codemeta_reader'
require_relative 'readers/crosscite_reader'
require_relative 'readers/crossref_reader'
require_relative 'readers/datacite_json_reader'
require_relative 'readers/datacite_reader'
require_relative 'readers/npm_reader'
require_relative 'readers/ris_reader'
require_relative 'readers/schema_org_reader'

require_relative 'writers/bibtex_writer'
require_relative 'writers/citation_writer'
require_relative 'writers/citeproc_writer'
require_relative 'writers/codemeta_writer'
require_relative 'writers/crosscite_writer'
require_relative 'writers/crossref_writer'
require_relative 'writers/csv_writer'
require_relative 'writers/datacite_writer'
require_relative 'writers/datacite_json_writer'
require_relative 'writers/jats_writer'
require_relative 'writers/rdf_xml_writer'
require_relative 'writers/ris_writer'
require_relative 'writers/schema_org_writer'
require_relative 'writers/turtle_writer'

module Bolognese
  module MetadataUtils
    # include BenchmarkMethods
    include Bolognese::DoiUtils
    include Bolognese::AuthorUtils
    include Bolognese::DataciteUtils
    include Bolognese::Utils

    include Bolognese::Readers::BibtexReader
    include Bolognese::Readers::CiteprocReader
    include Bolognese::Readers::CodemetaReader
    include Bolognese::Readers::CrossciteReader
    include Bolognese::Readers::CrossrefReader
    include Bolognese::Readers::DataciteReader
    include Bolognese::Readers::DataciteJsonReader
    include Bolognese::Readers::NpmReader
    include Bolognese::Readers::RisReader
    include Bolognese::Readers::SchemaOrgReader

    include Bolognese::Writers::BibtexWriter
    include Bolognese::Writers::CitationWriter
    include Bolognese::Writers::CiteprocWriter
    include Bolognese::Writers::CodemetaWriter
    include Bolognese::Writers::CrossciteWriter
    include Bolognese::Writers::CrossrefWriter
    include Bolognese::Writers::CsvWriter
    include Bolognese::Writers::DataciteWriter
    include Bolognese::Writers::DataciteJsonWriter
    include Bolognese::Writers::JatsWriter
    include Bolognese::Writers::RdfXmlWriter
    include Bolognese::Writers::RisWriter
    include Bolognese::Writers::SchemaOrgWriter
    include Bolognese::Writers::TurtleWriter

    attr_reader :name_detector, :reverse

    # some dois in the Crossref index are from other registration agencies
    alias get_medra get_crossref
    alias read_medra read_crossref
    alias get_kisti get_crossref
    alias read_kisti read_crossref
    alias get_jalc get_crossref
    alias read_jalc read_crossref
    alias get_op get_crossref
    alias read_op read_crossref

    # replace DOI in XML if provided in options
    def raw
      r = string.present? ? string.strip : nil
      return r unless (from == "datacite" && r.present?)

      doc = Nokogiri::XML(string, nil, 'UTF-8', &:noblanks)
      node = doc.at_css("identifier")
      node.content = doi.to_s.upcase if node.present? && doi.present?
      doc.to_xml.strip
    end

    def should_passthru
      (from == "datacite") && regenerate.blank? && raw.present?
    end

    def container_title
      if container.present?
        container["title"]
      elsif types["citeproc"] == "article-journal"
        publisher
      else
        nil
      end
    end

    # recognize given name. Can be loaded once as ::NameDetector, e.g. in a Rails initializer
    def name_detector
      @name_detector ||= defined?(::NameDetector) ? ::NameDetector : nil
    end

    def reverse
      { "citation" => Array.wrap(related_identifiers).select { |ri| ri["relationType"] == "IsReferencedBy" }.map do |r| 
        { "@id" => normalize_doi(r["relatedIdentifier"]),
          "@type" => r["resourceTypeGeneral"] || "ScholarlyArticle",
          "identifier" => r["relatedIdentifierType"] == "DOI" ? nil : to_identifier(r) }.compact
        end.unwrap,
        "isBasedOn" => Array.wrap(related_identifiers).select { |ri| ri["relationType"] == "IsSupplementTo" }.map do |r| 
          { "@id" => normalize_doi(r["relatedIdentifier"]),
            "@type" => r["resourceTypeGeneral"] || "ScholarlyArticle",
            "identifier" => r["relatedIdentifierType"] == "DOI" ? nil : to_identifier(r) }.compact
        end.unwrap }.compact
    end

    def graph
      RDF::Graph.new << ::JSON::LD::API.toRdf(schema_hsh)
    end

    def citeproc_hsh
      page = container.to_h["firstPage"].present? ? [container["firstPage"], container["lastPage"]].compact.join("-") : nil
      if Array.wrap(creators).size == 1 && Array.wrap(creators).first.fetch("name", nil) == ":(unav)"
        author = nil
      else
        author = to_citeproc(creators)
      end

      {
        "type" => types["citeproc"],
        "id" => normalize_doi(doi),
        "categories" => Array.wrap(subjects).map { |k| parse_attributes(k, content: "subject", first: true) }.presence,
        "language" => language,
        "author" => author,
        "contributor" => to_citeproc(contributors),
        "issued" => get_date(dates, "Issued") ? get_date_parts(get_date(dates, "Issued")) : nil,
        "submitted" => Array.wrap(dates).find { |d| d["dateType"] == "Submitted" }.to_h.fetch("__content__", nil),
        "abstract" => parse_attributes(descriptions, content: "description", first: true),
        "container-title" => container_title,
        "DOI" => doi,
        "volume" => container.to_h["volume"],
        "issue" => container.to_h["issue"],
        "page" => page,
        "publisher" => publisher,
        "title" => parse_attributes(titles, content: "title", first: true),
        "URL" => url,
        "version" => version_info
      }.compact.symbolize_keys
    end

    def crosscite_hsh
      {
        "id" => normalize_doi(doi),
        "doi" => doi,
        "url" => url,
        "types" => types,
        "creators" => creators,
        "titles" => titles,
        "publisher" => publisher,
        "container" => container,
        "subjects" => subjects,
        "contributors" => contributors,
        "dates" => dates,
        "publication_year" => publication_year,
        "language" => language,
        "identifiers" => identifiers,
        "sizes" => sizes,
        "formats" => formats,
        "version" => version_info,
        "rights_list" => rights_list,
        "descriptions" => descriptions,
        "geo_locations" => geo_locations,
        "funding_references" => funding_references,
        "related_identifiers" => related_identifiers,
        "schema_version" => schema_version,
        "provider_id" => provider_id,
        "client_id" => client_id,
        "agency" => agency,
        "state" => state
      }.compact
    end

    def style
      @style ||= "apa"
    end

    def locale
      @locale ||= "en-US"
    end
  end
end
