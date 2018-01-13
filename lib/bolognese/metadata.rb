require_relative 'doi_utils'
require_relative 'author_utils'
require_relative 'date_utils'
require_relative 'datacite_utils'
require_relative 'utils'

require_relative 'readers/bibtex_reader'
require_relative 'readers/citeproc_reader'
require_relative 'readers/codemeta_reader'
require_relative 'readers/crosscite_reader'
require_relative 'readers/crossref_reader'
require_relative 'readers/datacite_json_reader'
require_relative 'readers/datacite_reader'
require_relative 'readers/ris_reader'
require_relative 'readers/schema_org_reader'

require_relative 'writers/bibtex_writer'
require_relative 'writers/citation_writer'
require_relative 'writers/citeproc_writer'
require_relative 'writers/codemeta_writer'
require_relative 'writers/crosscite_writer'
require_relative 'writers/crossref_writer'
require_relative 'writers/datacite_writer'
require_relative 'writers/datacite_json_writer'
require_relative 'writers/jats_writer'
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
    include Bolognese::Readers::CrossciteReader
    include Bolognese::Readers::CrossrefReader
    include Bolognese::Readers::DataciteReader
    include Bolognese::Readers::DataciteJsonReader
    include Bolognese::Readers::RisReader
    include Bolognese::Readers::SchemaOrgReader

    include Bolognese::Writers::BibtexWriter
    include Bolognese::Writers::CitationWriter
    include Bolognese::Writers::CiteprocWriter
    include Bolognese::Writers::CodemetaWriter
    include Bolognese::Writers::CrossciteWriter
    include Bolognese::Writers::CrossrefWriter
    include Bolognese::Writers::DataciteWriter
    include Bolognese::Writers::DataciteJsonWriter
    include Bolognese::Writers::JatsWriter
    include Bolognese::Writers::RdfXmlWriter
    include Bolognese::Writers::RisWriter
    include Bolognese::Writers::SchemaOrgWriter
    include Bolognese::Writers::TurtleWriter

    attr_accessor :doi, :author, :title, :publisher, :contributor, :license,
      :date_accepted, :date_available, :date_copyrighted, :date_collected,
      :date_submitted, :date_valid, :date_created, :date_modified,
      :date_registered, :date_updated, :provider_id, :client_id, :journal,
      :volume, :issue, :first_page, :last_page, :url, :version, :keywords, :editor,
      :description, :alternate_name, :language, :content_size, :spatial_coverage,
      :schema_version, :additional_type, :has_part, :same_as,
      :is_previous_version_of, :is_new_version_of,   :is_cited_by, :cites,
      :is_supplement_to, :is_supplemented_by, :is_continued_by, :continues,
      :has_metadata, :is_metadata_for, :is_referenced_by, :references,
      :is_documented_by, :documents, :is_compiled_by, :compiles,
      :is_variant_form_of, :is_original_form_of, :is_reviewed_by, :reviews,
      :is_derived_from, :is_source_of, :format, :funding, :type, :bibtex_type,
      :citeproc_type, :ris_type, :style, :locale, :state

    attr_reader :id, :from, :raw, :metadata, :doc, :provider,
      :page_start, :page_end, :should_passthru, :errors,
      :related_identifier, :reverse, :name_detector

    def initialize(input: nil, from: nil, style: nil, locale: nil, regenerate: false, **options)
      id = normalize_id(input, options)

      if id.present?
        @from = from || find_from_format(id: id)

        # generate name for method to call dynamically
        hsh = @from.present? ? send("get_" + @from, id: id, sandbox: options[:sandbox]) : nil
        string = hsh.to_h.fetch("string", nil)
      elsif File.exist?(input)
        ext = File.extname(input)
        if %w(.bib .ris .xml .json).include?(ext)
          string = IO.read(input)
          @from = from || find_from_format(string: string, ext: ext)
        else
          $stderr.puts "File type #{ext} not supported"
          exit 1
        end
      else
        hsh = { "url" => options[:url],
                "state" => options[:state],
                "date_registered" => options[:date_registered],
                "date_updated" => options[:date_updated],
                "provider_id" => options[:provider_id],
                "client_id" => options[:client_id] }
        string = input
        @from = from || find_from_format(string: string)
      end

      # generate name for method to call dynamically
      @metadata = @from.present? ? send("read_" + @from, string: string, sandbox: options[:sandbox], doi: options[:doi], url: options[:url]) : {}
      @raw = string.present? ? string.strip : nil

      # replace DOI in XML if provided in options
      if @from == "datacite" && options[:doi].present?
        doc = Nokogiri::XML(string, nil, 'UTF-8', &:noblanks)
        node = doc.at_css("identifier")
        node.content = options[:doi].upcase
        @raw = doc.to_xml.strip
      end

      @should_passthru = (@from == "datacite") && !regenerate

      @url = hsh.to_h["url"].presence
      @state = hsh.to_h["state"].presence
      @date_registered = hsh.to_h["date_registered"].presence
      @date_updated = hsh.to_h["date_updated"].presence
      @provider_id = hsh.to_h["provider_id"].presence
      @client_id = hsh.to_h["client_id"].presence

      @style = style || "apa"
      @locale = locale || "en-US"
    end

    def exists?
      metadata.fetch("id", nil).present?
    end

    def valid?
      exists? && errors.nil?
    end

    # validate against DataCite schema, unless there are already errors in the reader
    def errors
      xml = should_passthru ? raw : datacite_xml
      metadata.fetch("errors", nil) || datacite_errors(xml: xml,
                                                       schema_version: schema_version)
    end

    def id
      @doi.present? ? doi_as_url(@doi) : metadata.fetch("id", nil)
    end

    def type
      @type ||= metadata.fetch("type", nil)
    end

    def additional_type
      @additional_type ||= metadata.fetch("additional_type", nil)
    end

    def citeproc_type
      @citeproc_type ||= metadata.fetch("citeproc_type", nil)
    end

    def bibtex_type
      @bibtex_type ||= metadata.fetch("bibtex_type", nil)
    end

    def ris_type
      @ris_type ||= metadata.fetch("ris_type", nil)
    end

    def resource_type_general
      @resource_type_general ||= metadata.fetch("resource_type_general", nil)
    end

    def doi
      @doi ||= metadata.fetch("doi", nil)
    end

    def url
      @url ||= metadata.fetch("url", nil)
    end

    def state
      @state ||= metadata.fetch("state", nil)
    end

    def title
      @title ||= metadata.fetch("title", nil)
    end

    def alternate_name
      @alternate_name ||= metadata.fetch("alternate_name", nil)
    end

    def author
      @author ||= metadata.fetch("author", nil)
    end

    def editor
      @editor ||= metadata.fetch("editor", nil)
    end

    def publisher
      @publisher ||= metadata.fetch("publisher", nil)
    end

    def provider
      @provider ||= metadata.fetch("provider", nil)
    end

    def date_created
      @date_created ||= metadata.fetch("date_created", nil)
    end

    def date_accepted
      @date_accepted ||= metadata.fetch("date_accepted", nil)
    end

    def date_available
      @date_available ||= metadata.fetch("date_available", nil)
    end

    def date_copyrighted
      @date_copyrighted ||= metadata.fetch("date_copyrighted", nil)
    end

    def date_collected
      @date_collected ||= metadata.fetch("date_collected", nil)
    end

    def date_submitted
      @date_submitted ||= metadata.fetch("date_submitted", nil)
    end

    def date_valid
      @date_valid ||= metadata.fetch("date_valid", nil)
    end

    def date_published
      @date_published ||= metadata.fetch("date_published", nil)
    end

    def date_modified
      @date_modified ||= metadata.fetch("date_modified", nil)
    end

    def date_registered
      @date_registered ||= metadata.fetch("date_registered", nil)
    end

    def date_updated
      @date_updated ||= metadata.fetch("date_updated", nil)
    end

    def volume
      @volume ||= metadata.fetch("volume", nil)
    end

    def first_page
      @first_page ||= metadata.fetch("first_page", nil)
    end

    def last_page
      @last_page ||= metadata.fetch("last_page", nil)
    end

    def description
      @description ||= metadata.fetch("description", nil)
    end

    def license
      @license ||= metadata.fetch("license", nil)
    end

    def version
      @version ||= metadata.fetch("version", nil)
    end

    def keywords
      @keywords ||= metadata.fetch("keywords", nil)
    end

    def language
      @language ||= metadata.fetch("language", nil)
    end

    def content_size
      @content_size ||= metadata.fetch("content_size", nil)
    end

    def schema_version
      @schema_version ||= metadata.fetch("schema_version", nil)
    end

    def funding
      @funding ||= metadata.fetch("funding", nil)
    end

    def provider_id
      @provider_id ||= metadata.fetch("provider_id", nil)
    end

    def client_id
      @client_id ||= metadata.fetch("client_id", nil)
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

    def related_identifier_hsh(relation_type)
      Array.wrap(send(relation_type)).select { |r| r["id"] || r["issn"] }
        .map { |r| r.merge("relationType" => relation_type.camelize) }
    end

    def related_identifier
      relation_types = %w(is_part_of has_part references is_referenced_by is_supplement_to is_supplemented_by)
      relation_types.reduce([]) { |sum, r| sum += related_identifier_hsh(r) }
    end

    # recognize given name. Can be loaded once as ::NameDetector, e.g. in a Rails initializer
    def name_detector
      @name_detector ||= defined?(::NameDetector) ? ::NameDetector : nil
    end

    def publication_year
      date_published.present? ? date_published[0..3].to_i.presence : nil
    end

    def container_title
      Array.wrap(is_part_of).length == 1 ? is_part_of.to_h.fetch("title", nil) : nil
    end

    def descriptions
      Array.wrap(description)
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
