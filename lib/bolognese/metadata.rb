require_relative 'doi_utils'
require_relative 'author_utils'
require_relative 'date_utils'
require_relative 'datacite_utils'
require_relative 'utils'

require_relative 'readers/bibtex_reader'
require_relative 'readers/citeproc_reader'
require_relative 'readers/codemeta_reader'
require_relative 'readers/crossref_reader'
require_relative 'readers/datacite_reader'
require_relative 'readers/datacite_json_reader'
require_relative 'readers/schema_org_reader'

require_relative 'writers/bibtex_writer'
require_relative 'writers/citeproc_writer'
require_relative 'writers/codemeta_writer'
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
    include Bolognese::Readers::SchemaOrgReader

    include Bolognese::Writers::BibtexWriter
    include Bolognese::Writers::CiteprocWriter
    include Bolognese::Writers::CodemetaWriter
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

      id = normalize_doi(id) if id.present?

      @metadata = case from
          when "crossref" then read_crossref(id: id, string: string)
          when "datacite" then read_datacite(id: id, string: string)

          when "codemeta" then read_codemeta(id: id, string: string)
          when "datacite_json" then read_datacite_json(string: string)
          when "citeproc" then read_citeproc(string: string)
          when "bibtex" then read_bibtex(string: string)
          when "ris" then read_ris(string: string)
          else read_schema_org(id: id)
          end

      @should_passthru = !regenerate
    end

    def exists?
      metadata.present?
    end

    # def valid?
    #   datacite.present? && errors.blank?
    # end

    def errors
      doc && doc.errors.map { |error| error.to_s }.unwrap
    end

    def schema_version
      metadata.fetch("xmlns", nil)
    end

    def doi
      metadata.fetch("identifier", {}).fetch("__content__", nil)
    end

    def id
      normalize_doi(doi)
    end

    def resource_type_general
      metadata.dig("resourceType", "resourceTypeGeneral")
    end

    def type
      DC_TO_SO_TRANSLATIONS[resource_type_general.to_s.dasherize] || "CreativeWork"
    end

    def citeproc_type
      DC_TO_CP_TRANSLATIONS[resource_type_general.to_s.dasherize] || "other"
    end

    def ris_type
      DC_TO_RIS_TRANSLATIONS[resource_type_general.to_s.dasherize] || "GEN"
    end

    def additional_type
      metadata.fetch("resourceType", {}).fetch("__content__", nil) ||
      metadata.fetch("resourceType", {}).fetch("resourceTypeGeneral", nil)
    end

    def bibtex_type
      Bolognese::Utils::SO_TO_BIB_TRANSLATIONS[type] || "misc"
    end

    def title
      Array.wrap(metadata.dig("titles", "title")).map do |r|
        if r.is_a?(String)
          sanitize(r)
        else
          { "title_type" => r["titleType"], "lang" => r["xml:lang"], "text" => sanitize(r["__content__"]) }.compact
        end
      end.unwrap
    end

    def alternate_name
      Array.wrap(metadata.dig("alternateIdentifiers", "alternateIdentifier")).map do |r|
        { "type" => r["alternateIdentifierType"], "name" => r["__content__"] }.compact
      end.unwrap
    end

    def description
      Array.wrap(metadata.dig("descriptions", "description")).map do |r|
        { "type" => r["descriptionType"], "text" => sanitize(r["__content__"]) }.compact
      end.unwrap
    end

    def license
      Array.wrap(metadata.dig("rightsList", "rights")).map do |r|
        { "url" => r["rightsURI"], "name" => r["__content__"] }.compact
      end.unwrap
    end

    def keywords
      Array.wrap(metadata.dig("subjects", "subject")).map do |k|
        if k.is_a?(String)
          sanitize(k)
        else
          k.fetch("__content__", nil)
        end
      end.compact.join(", ").presence
    end

    def author
      get_authors(metadata.dig("creators", "creator"))
    end

    def editor
      get_authors(Array.wrap(metadata.dig("contributors", "contributor"))
                          .select { |r| r["contributorType"] == "Editor" })
    end

    def funder
      f = funder_contributor + funding_reference
      f.length > 1 ? f : f.first
    end

    def funder_contributor
      Array.wrap(metadata.dig("contributors", "contributor")).reduce([]) do |sum, f|
        if f["contributorType"] == "Funder"
          sum << { "name" => f["contributorName"] }
        else
          sum
        end
      end
    end

    def funding_reference
      Array.wrap(metadata.dig("fundingReferences", "fundingReference")).map do |f|
        funder_id = parse_attributes(f["funderIdentifier"])
        { "identifier" => normalize_id(funder_id),
          "name" => f["funderName"] }.compact
      end.uniq
    end

    def version
      metadata.fetch("version", nil)
    end

    def dates
      Array.wrap(metadata.dig("dates", "date"))
    end

    #Accepted Available Copyrighted Collected Created Issued Submitted Updated Valid

    def date(date_type)
      dd = dates.find { |d| d["dateType"] == date_type } || {}
      dd.fetch("__content__", nil)
    end

    def date_accepted
      date("Accepted")
    end

    def date_available
      date("Available")
    end

    def date_copyrighted
      date("Copyrighted")
    end

    def date_collected
      date("Collected")
    end

    def date_created
      date("Created")
    end

    # use datePublished for date issued
    def date_published
      date("Issued") || publication_year
    end

    def date_submitted
      date("Submitted")
    end

    # use dateModified for date updated
    def date_modified
      date("Updated")
    end

    def date_valid
      date("Valid")
    end

    def publication_year
      metadata.fetch("publicationYear", nil)
    end

    def language
      metadata.fetch("language", nil)
    end

    def spatial_coverage

    end

    def content_size
      metadata.fetch("size", nil)
    end

    def related_identifier(relation_type: nil)
      arr = Array.wrap(metadata.dig("relatedIdentifiers", "relatedIdentifier")).select { |r| %w(DOI URL).include?(r["relatedIdentifierType"]) }
      arr = arr.select { |r| relation_type.split(" ").include?(r["relationType"]) } if relation_type.present?

      arr.map { |work| { "id" => normalize_id(work["__content__"]), "relationType" => work["relationType"] } }.unwrap
    end

    def is_identical_to
      related_identifier(relation_type: "IsIdenticalTo")
    end

    def is_part_of
      related_identifier(relation_type: "IsPartOf")
    end

    def has_part
      related_identifier(relation_type: "HasPart")
    end

    def is_previous_version_of
      related_identifier(relation_type: "IsPreviousVersionOf")
    end

    def is_new_version_of
      related_identifier(relation_type: "IsNewVersionOf")
    end

    def is_variant_form_of
      related_identifier(relation_type: "IsVariantFormOf")
    end

    def is_original_form_of
      related_identifier(relation_type: "IsOriginalFormOf")
    end

    def references
      related_identifier(relation_type: "References Cites").presence
    end

    def is_referenced_by
      related_identifier(relation_type: "IsCitedBy IsReferencedBy").presence
    end

    def is_supplement_to
      related_identifier(relation_type: "IsSupplementTo")
    end

    def is_supplemented_by
      get_related_identifier(relation_type: "isSupplementedBy")
    end

    def reviews
      related_identifier(relation_type: "Reviews").presence
    end

    def is_reviewed_by
      related_identifier(relation_type: "IsReviewedBy").presence
    end

    def publisher
      metadata.fetch("publisher", nil)
    end

    alias_method :container_title, :publisher

    def provider
      "DataCite"
    end

    # recognize given name. Can be loaded once as ::NameDetector, e.g. in a Rails initializer
    def name_detector
      @name_detector ||= defined?(::NameDetector) ? ::NameDetector : GenderDetector.new
    end

    # def publication_year
    #   date_published && date_published[0..3]
    # end

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
