require_relative 'doi_utils'
require_relative 'author_utils'
require_relative 'date_utils'
require_relative 'datacite_utils'
require_relative 'utils'

require_relative 'readers/bibtex_reader'
require_relative 'readers/citeproc_reader'
require_relative 'readers/codemeta_reader'
require_relative 'readers/crossref_reader'
require_relative 'readers/datacite_json_reader'
require_relative 'readers/datacite_reader'
require_relative 'readers/ris_reader'
require_relative 'readers/schema_org_reader'

require_relative 'writers/bibtex_writer'
require_relative 'writers/citeproc_writer'
require_relative 'writers/codemeta_writer'
require_relative 'writers/crossref_writer'
require_relative 'writers/datacite_writer'
require_relative 'writers/datacite_json_writer'
require_relative 'writers/rdf_xml_writer'
require_relative 'writers/ris_writer'
require_relative 'writers/schema_org_writer'
require_relative 'writers/turtle_writer'

module Bolognese
  class Metadata
    # include BenchmarkMethods
    include Bolognese::DoiUtils
    include Bolognese::AuthorUtils
    include Bolognese::DateUtils
    include Bolognese::DataciteUtils
    include Bolognese::Utils

    include Bolognese::Readers::BibtexReader
    include Bolognese::Readers::CiteprocReader
    include Bolognese::Readers::CodemetaReader
    include Bolognese::Readers::CrossrefReader
    include Bolognese::Readers::DataciteReader
    include Bolognese::Readers::DataciteJsonReader
    include Bolognese::Readers::RisReader
    include Bolognese::Readers::SchemaOrgReader

    include Bolognese::Writers::BibtexWriter
    include Bolognese::Writers::CiteprocWriter
    include Bolognese::Writers::CodemetaWriter
    include Bolognese::Writers::CrossrefWriter
    include Bolognese::Writers::DataciteWriter
    include Bolognese::Writers::DataciteJsonWriter
    include Bolognese::Writers::RdfXmlWriter
    include Bolognese::Writers::RisWriter
    include Bolognese::Writers::SchemaOrgWriter
    include Bolognese::Writers::TurtleWriter

    attr_reader :id, :from, :raw, :metadata, :doc, :provider, :schema_version, :license, :citation,
      :additional_type, :alternate_name, :url, :version, :keywords, :editor,
      :page_start, :page_end, :date_modified, :language, :spatial_coverage,
      :content_size, :funder, :journal, :bibtex_type, :date_created, :has_part,
      :publisher, :contributor, :same_as, :is_previous_version_of, :is_new_version_of,
      :should_passthru, :errors, :datacite_errors, :date_accepted, :date_available,
      :date_copyrighted, :date_collected, :date_submitted, :date_valid,
      :is_cited_by, :cites, :is_supplement_to, :is_supplemented_by,
      :is_continued_by, :continues, :has_metadata, :is_metadata_for,
      :is_referenced_by, :references, :is_documented_by, :documents,
      :is_compiled_by, :compiles, :is_variant_form_of, :is_original_form_of,
      :is_reviewed_by, :reviews, :is_derived_from, :is_source_of, :format,
      :related_identifier, :reverse, :citeproc_type, :ris_type, :volume, :issue,
      :name_detector

    def initialize(input: nil, from: nil, to: nil, regenerate: false)
      id = normalize_id(input)

      if id.present?
        from ||= find_from_format(id: id)
      else
        ext = File.extname(input)
        if %w(.bib .ris .xml .json).include?(ext)
          string = IO.read(input)
        else
          $stderr.puts "File type #{ext} not supported"
          exit 1
        end
        from ||= find_from_format(string: string, ext: ext)
      end

      to ||= "schema_org"

      @metadata = case from
          when "crossref" then read_crossref(id: id, string: string)
          when "datacite" then read_datacite(id: id, string: string)

          when "codemeta" then read_codemeta(id: id, string: string)
          when "datacite_json" then read_datacite_json(string: string)
          when "citeproc" then read_citeproc(string: string)
          when "bibtex" then read_bibtex(string: string)
          when "ris" then read_ris(string: string)
          else read_schema_org(id: id, string: string)
          end

      @should_passthru = !regenerate
    end

    def exists?
      metadata.fetch("id", nil).present?
    end

    # def valid?
    #   datacite.present? && errors.blank?
    # end

    def valid?
      metadata.fetch("errors", nil).nil?
    end

    def errors
      doc && doc.errors.map { |error| error.to_s }.unwrap
    end

    def id
      metadata.fetch("id", nil)
    end

    def type
      metadata.fetch("type", nil)
    end

    def additional_type
      metadata.fetch("additional_type", nil)
    end

    def citeproc_type
      metadata.fetch("citeproc_type", nil)
    end

    def bibtex_type
      metadata.fetch("bibtex_type", nil)
    end

    def ris_type
      metadata.fetch("ris_type", nil)
    end

    def resource_type_general
      metadata.fetch("resource_type_general", nil)
    end

    def doi
      metadata.fetch("doi", nil)
    end

    def url
      metadata.fetch("url", nil)
    end

    def title
      metadata.fetch("title", nil)
    end

    def alternate_name
      metadata.fetch("alternate_name", nil)
    end

    def author
      metadata.fetch("author", nil)
    end

    def editor
      metadata.fetch("editor", nil)
    end

    def funder
      metadata.fetch("funder", nil)
    end

    def container_title
      metadata.fetch("container_title", nil)
    end

    def publisher
      metadata.fetch("publisher", nil)
    end

    def provider
      metadata.fetch("provider", nil)
    end

    def date_created
      metadata.fetch("date_created", nil)
    end

    def date_accepted
      metadata.fetch("date_accepted", nil)
    end

    def date_available
      metadata.fetch("date_available", nil)
    end

    def date_copyrighted
      metadata.fetch("date_copyrighted", nil)
    end

    def date_collected
      metadata.fetch("date_collected", nil)
    end

    def date_submitted
      metadata.fetch("date_submitted", nil)
    end

    def date_valid
      metadata.fetch("date_valid", nil)
    end

    def date_published
      metadata.fetch("date_published", nil)
    end

    def date_modified
      metadata.fetch("date_modified", nil)
    end

    def publication_year
      metadata.fetch("publication_year", nil)
    end

    def volume
      metadata.fetch("volume", nil)
    end

    def pagination
      metadata.fetch("pagination", nil)
    end

    def description
      metadata.fetch("description", nil)
    end

    def license
      metadata.fetch("license", nil)
    end

    def version
      metadata.fetch("version", nil)
    end

    def keywords
      metadata.fetch("keywords", nil)
    end

    def language
      metadata.fetch("language", nil)
    end

    def content_size
      metadata.fetch("content_size", nil)
    end

    def schema_version
      metadata.fetch("schema_version", nil)
    end

    def is_identical_to
      metadata.fetch("is_identical_to", nil)
    end

    def is_part_of
      metadata.fetch("is_part_of", nil)
    end

    def has_part
      metadata.fetch("has_part", nil)
    end

    def is_previous_version_of
      metadata.fetch("is_previous_of", nil)
    end

    def is_new_version_of
      metadata.fetch("is_new_version_of", nil)
    end

    def is_variant_form_of
      metadata.fetch("is_variant_form_of", nil)
    end

    def is_original_form_of
      metadata.fetch("is_original_form_of", nil)
    end

    def references
      metadata.fetch("references", nil)
    end

    def is_referenced_by
      metadata.fetch("is_referenced_by", nil)
    end

    def is_supplement_to
      metadata.fetch("is_supplement_to", nil)
    end

    def is_supplemented_by
      metadata.fetch("is_supplemented_by", nil)
    end

    def reviews
      metadata.fetch("reviews", nil)
    end

    def is_reviewed_by
      metadata.fetch("is_reviewed_by", nil)
    end

    # recognize given name. Can be loaded once as ::NameDetector, e.g. in a Rails initializer
    def name_detector
      @name_detector ||= defined?(::NameDetector) ? ::NameDetector : GenderDetector.new
    end


    def descriptions
      Array.wrap(description)
    end

    def name
      if title.is_a?(Hash)
        title["text"]
      else
        title
      end
    end

    def reverse
      { "citation" => Array.wrap(is_referenced_by).map { |r| { "@id" => r["id"] }}.unwrap,
        "isBasedOn" => Array.wrap(is_supplement_to).map { |r| { "@id" => r["id"] }}.unwrap }.compact
    end

    def graph
      RDF::Graph.new << JSON::LD::API.toRdf(schema_hsh)
    end
  end
end
