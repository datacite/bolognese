require_relative 'doi_utils'
require_relative 'author_utils'
require_relative 'date_utils'
require_relative 'datacite_utils'
require_relative 'utils'
require_relative 'writers/bibtex_writer'
require_relative 'writers/citeproc_writer'
require_relative 'writers/codemeta_writer'
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
    include Bolognese::Writers::BibtexWriter
    include Bolognese::Writers::CiteprocWriter
    include Bolognese::Writers::CodemetaWriter
    include Bolognese::Writers::DataciteJsonWriter
    include Bolognese::Writers::RdfXmlWriter
    include Bolognese::Writers::RisWriter
    include Bolognese::Writers::SchemaOrgWriter
    include Bolognese::Writers::TurtleWriter

    attr_reader :id, :raw, :doc, :provider, :schema_version, :license, :citation,
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

    # recognize given name. Can be loaded once as ::NameDetector, e.g. in a Rails initializer
    def name_detector
      @name_detector ||= defined?(::NameDetector) ? ::NameDetector : GenderDetector.new
    end

    def publication_year
      date_published && date_published[0..3]
    end

    def descriptions
      Array.wrap(description)
    end

    def pagination
      [page_start, page_end].compact.join("-").presence
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
