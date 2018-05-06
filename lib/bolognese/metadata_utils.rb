require_relative 'doi_utils'
require_relative 'author_utils'
require_relative 'datacite_utils'
require_relative 'utils'

module Bolognese
  module MetadataUtils
    # include BenchmarkMethods
    include Bolognese::DoiUtils
    include Bolognese::AuthorUtils
    include Bolognese::DataciteUtils
    include Bolognese::Utils

    attr_accessor :string, :from, :sandbox, :b_doi, :regenerate, :issue, :contributor,
                  :spatial_coverage

    attr_writer :identifier, :author, :title, :publisher, :license,
                :date_accepted, :date_available, :date_copyrighted, :date_collected,
                :date_submitted, :date_valid, :date_created, :date_modified, :date_updated, 
                :journal, :volume, :first_page, :last_page,
                :keywords, :editor, :description, :alternate_name, :language, :content_size,
                :schema_version, :has_part, :same_as,
                :is_previous_version_of, :is_new_version_of, :is_cited_by, :cites,
                :is_supplement_to, :is_supplemented_by, :is_continued_by, :continues,
                :has_metadata, :is_metadata_for, :is_referenced_by, :references,
                :is_documented_by, :documents, :is_compiled_by, :compiles,
                :is_variant_form_of, :is_original_form_of, :is_reviewed_by, :reviews,
                :is_derived_from, :is_source_of, :format, :funding, :style, :locale, :state,
                :type, :additional_type, :citeproc_type, :bibtex_type, :ris_type, :meta

    attr_reader :doc, :service_provider, :page_start, :page_end, :related_identifier, :reverse, :name_detector

    # replace DOI in XML if provided in options
    def raw
      r = string.present? ? string.strip : nil
      return r unless (from == "datacite" && r.present?)

      doc = Nokogiri::XML(string, nil, 'UTF-8', &:noblanks)
      node = doc.at_css("identifier")
      node.content = doi.to_s.upcase
      doc.to_xml.strip
    end

    def should_passthru
      (from == "datacite") && regenerate.blank?
    end

    # generate name for method to call dynamically
    # the id might change
    def meta
      m = from.present? ? send("read_" + from, string: string, sandbox: sandbox) : {}
      @identifier = b_doi || m.fetch("id", nil) || m.fetch("identifier", nil)

      m
    end

    def type
      @type ||= meta.fetch("type", nil)
    end

    def additional_type
      @additional_type ||= meta.fetch("additional_type", nil)
    end

    def citeproc_type
      @citeproc_type ||= meta.fetch("citeproc_type", nil)
    end

    def bibtex_type
      @bibtex_type ||= meta.fetch("bibtex_type", nil)
    end

    def ris_type
      @ris_type ||= meta.fetch("ris_type", nil)
    end

    def resource_type_general
      @resource_type_general ||= meta.fetch("resource_type_general", nil)
    end

    def identifier
      @identifier ||= meta.fetch("id", nil)
    end

    def state
      @state ||= meta.fetch("state", nil)
    end

    def title
      @title ||= meta.fetch("title", nil)
    end

    def alternate_name
      @alternate_name ||= meta.fetch("alternate_name", nil)
    end

    def author
      @author ||= meta.fetch("author", nil)
    end

    def editor
      @editor ||= meta.fetch("editor", nil)
    end

    def publisher
      @publisher ||= meta.fetch("publisher", nil)
    end

    def service_provider
      @service_provider ||= meta.fetch("service_provider", nil)
    end

    def date_created
      @date_created ||= meta.fetch("date_created", nil)
    end

    def date_accepted
      @date_accepted ||= meta.fetch("date_accepted", nil)
    end

    def date_available
      @date_available ||= meta.fetch("date_available", nil)
    end

    def date_copyrighted
      @date_copyrighted ||= meta.fetch("date_copyrighted", nil)
    end

    def date_collected
      @date_collected ||= meta.fetch("date_collected", nil)
    end

    def date_submitted
      @date_submitted ||= meta.fetch("date_submitted", nil)
    end

    def date_valid
      @date_valid ||= meta.fetch("date_valid", nil)
    end

    def date_published
      @date_published ||= meta.fetch("date_published", nil)
    end

    def date_modified
      @date_modified ||= meta.fetch("date_modified", nil)
    end

    def date_registered
      @date_registered ||= meta.fetch("date_registered", nil)
    end

    def date_updated
      @date_updated ||= meta.fetch("date_updated", nil)
    end

    def volume
      @volume ||= meta.fetch("volume", nil)
    end

    def first_page
      @first_page ||= meta.fetch("first_page", nil)
    end

    def last_page
      @last_page ||= meta.fetch("last_page", nil)
    end

    def description
      @description ||= meta.fetch("description", nil)
    end

    def license
      @license ||= meta.fetch("license", nil)
    end

    def keywords
      @keywords ||= meta.fetch("keywords", nil)
    end

    def language
      @language ||= meta.fetch("language", nil)
    end

    def content_size
      @content_size ||= meta.fetch("content_size", nil)
    end

    def schema_version
      @schema_version ||= meta.fetch("schema_version", nil)
    end

    def funding
      @funding ||= meta.fetch("funding", nil)
    end

    def is_identical_to
      meta.fetch("is_identical_to", nil)
    end

    def is_part_of
      meta.fetch("is_part_of", nil)
    end

    def has_part
      meta.fetch("has_part", nil)
    end

    def is_previous_version_of
      meta.fetch("is_previous_of", nil)
    end

    def is_new_version_of
      meta.fetch("is_new_version_of", nil)
    end

    def is_variant_form_of
      meta.fetch("is_variant_form_of", nil)
    end

    def is_original_form_of
      meta.fetch("is_original_form_of", nil)
    end

    def references
      meta.fetch("references", nil)
    end

    def is_referenced_by
      meta.fetch("is_referenced_by", nil)
    end

    def is_supplement_to
      meta.fetch("is_supplement_to", nil)
    end

    def is_supplemented_by
      meta.fetch("is_supplemented_by", nil)
    end

    def reviews
      meta.fetch("reviews", nil)
    end

    def is_reviewed_by
      meta.fetch("is_reviewed_by", nil)
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
      Array.wrap(is_part_of).first.to_h.fetch("title", nil)
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

    def style
      @style || "apa"
    end

    def locale
      @locale || "en-US"
    end
  end
end
