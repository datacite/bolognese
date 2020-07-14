# frozen_string_literal: true

require_relative 'metadata_utils'

module Bolognese
  class Metadata
    include Bolognese::MetadataUtils

    attr_accessor :string, :from, :sandbox, :meta, :regenerate, :issue, :show_errors
    attr_reader :doc, :page_start, :page_end
    attr_writer :id, :provider_id, :client_id, :doi, :identifiers, :creators, :contributors, :titles, :publisher, 
                :rights_list, :dates, :publication_year, :volume, :url, :version_info,
                :subjects, :contributor, :descriptions, :language, :sizes,
                :formats, :schema_version, :meta, :container, :agency,
                :format, :funding_references, :state, :geo_locations,
                :types, :content_url, :related_identifiers, :style, :locale, :date_registered

    def initialize(input, **opts)
      options = HashWithIndifferentAccess.new(opts)
      id = normalize_id(input, options)
      ra = nil

      if id.present?
        @from = options[:from] || find_from_format(id: id)

        # mEDRA, KISTI, JaLC and OP DOIs are found in the Crossref index
        if @from == "medra"
          ra = "mEDRA"
        elsif @from == "kisti"
          ra = "KISTI"
        elsif @from == "jalc"
          ra = "JaLC"
        elsif @from == "op"
          ra = "OP"
        end

        # generate name for method to call dynamically
        hsh = @from.present? ? send("get_" + @from, id: id, sandbox: options[:sandbox]) : {}
        string = hsh.fetch("string", nil)

      elsif input.present? && File.exist?(input)
        filename = File.basename(input)
        ext = File.extname(input)
        if %w(.bib .ris .xml .json).include?(ext)
          hsh = { 
            "url" => options[:url],
            "state" => options[:state],
            "date_registered" => options[:date_registered],
            "date_updated" => options[:date_updated],
            "provider_id" => options[:provider_id],
            "client_id" => options[:client_id],
            "content_url" => options[:content_url] }
          string = IO.read(input)
          @from = options[:from] || find_from_format(string: string, filename: filename, ext: ext)
        else
          $stderr.puts "File type #{ext} not supported"
          exit 1
        end
      else
        hsh = { 
          "url" => options[:url],
          "state" => options[:state],
          "date_registered" => options[:date_registered],
          "date_updated" => options[:date_updated],
          "provider_id" => options[:provider_id],
          "client_id" => options[:client_id],
          "content_url" => options[:content_url],
          "creators" => options[:creators],
          "contributors" => options[:contributors],
          "titles" => options[:titles],
          "publisher" => options[:publisher],
          "publication_year" => options[:publication_year] }
        string = input
        @from = options[:from] || find_from_format(string: string)
      end

      # make sure input is encoded as utf8
      string = string.force_encoding("UTF-8") if string.present?
      @string = string

      # input options for citation formatting
      @style = options[:style]
      @locale = options[:locale]

      @sandbox = options[:sandbox]

      # options that come from the datacite database
      @url = hsh.to_h["url"].presence || options[:url].presence
      @state = hsh.to_h["state"].presence
      @date_registered = hsh.to_h["date_registered"].presence
      @date_updated = hsh.to_h["date_updated"].presence
      @provider_id = hsh.to_h["provider_id"].presence
      @client_id = hsh.to_h["client_id"].presence
      @content_url = hsh.to_h["content_url"].presence

      # set attributes directly
      read_options = options.slice(
        "creators",
        "contributors",
        "titles",
        "types",
        "identifiers",
        "container",
        "publisher",
        "funding_references",
        "dates",
        "publication_year",
        "descriptions",
        "rights_list",
        "version_info",
        "subjects",
        "language",
        "geo_locations",
        "related_identifiers",
        "formats",
        "sizes"
      ).compact

      @regenerate = options[:regenerate] || read_options.present?
      # generate name for method to call dynamically
      opts = { string: string, sandbox: options[:sandbox], doi: options[:doi], id: id, ra: ra }.merge(read_options)
      @meta = @from.present? ? send("read_" + @from, **opts) : {}
    end

    def id
      @id ||= meta.fetch("id", nil)
    end

    def doi
      @doi ||= meta.fetch("doi", nil)
    end

    def provider_id
      @provider_id ||= meta.fetch("provider_id", nil)
    end

    def client_id
      @client_id ||= meta.fetch("client_id", nil)
    end

    def exists?
      (@state || meta.fetch("state", nil)) != "not_found"
    end

    def valid?
      exists? && errors.nil?
    end

    # validate against DataCite schema, unless there are already errors in the reader
    def errors
      meta.fetch("errors", nil) || datacite_errors(xml: datacite, schema_version: schema_version)
    end
    
    def descriptions
      @descriptions ||= meta.fetch("descriptions", nil)
    end

    def rights_list
      @rights_list ||= meta.fetch("rights_list", nil)
    end

    def subjects
      @subjects ||= meta.fetch("subjects", nil)
    end

    def language
      @language ||= meta.fetch("language", nil)
    end

    def sizes
      @sizes ||= meta.fetch("sizes", nil)
    end

    def formats
      @formats ||= meta.fetch("formats", nil)
    end

    def schema_version
      @schema_version ||= meta.fetch("schema_version", nil)
    end

    def funding_references
      @funding_references ||= meta.fetch("funding_references", nil)
    end

    def related_identifiers
      @related_identifiers ||= meta.fetch("related_identifiers", nil)
    end

    def url
      @url ||= meta.fetch("url", nil)
    end

    def version_info
      @version_info ||= meta.fetch("version_info", nil) || meta.fetch("version", nil)
    end

    def publication_year
      @publication_year ||= meta.fetch("publication_year", nil)
    end

    def container
      @container ||= meta.fetch("container", nil)
    end

    def geo_locations
      @geo_locations ||= meta.fetch("geo_locations", nil)
    end

    def dates
      @dates ||= meta.fetch("dates", nil)
    end

    def publisher
      @publisher ||= meta.fetch("publisher", nil)
    end

    def identifiers
      @identifiers ||= meta.fetch("identifiers", nil)
    end

    def content_url
      @content_url ||= meta.fetch("content_url", nil)
    end

    def agency
      @agency ||= meta.fetch("agency", nil)
    end

    def state
      @state ||= meta.fetch("state", nil)
    end

    def date_registered
      @date_registered ||= meta.fetch("date_registered", nil)
    end

    def types
      @types ||= meta.fetch("types", nil)
    end

    def titles
      @titles ||= meta.fetch("titles", nil)
    end

    def creators
      @creators ||= meta.fetch("creators", nil)
    end

    def contributors
      @contributors ||= meta.fetch("contributors", nil)
    end
  end
end