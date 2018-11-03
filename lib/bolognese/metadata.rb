# frozen_string_literal: true

require_relative 'metadata_utils'

module Bolognese
  class Metadata
    include Bolognese::MetadataUtils

    attr_writer :id, :provider_id, :client_id, :doi, :identifier, :creator, :title, :publisher, :rights, :dates, :date_published, :date_modified,
                :date_updated, :journal, :volume, :first_page, :last_page, :url, :version, :resource_type_general,
                :keywords, :editor, :description, :alternate_identifiers, :language, :size,
                :formats, :schema_version, :resource_type_general, :meta, :periodical,
                :format, :funding_references, :style, :locale, :state, :geo_location,
                :type, :additional_type, :citeproc_type, :bibtex_type, :ris_type, :content_url, :related_identifiers


    def initialize(input: nil, from: nil, **options)
      id = normalize_id(input, options)

      if id.present?
        @from = from || find_from_format(id: id)

        # generate name for method to call dynamically
        hsh = @from.present? ? send("get_" + @from, id: id, sandbox: options[:sandbox]) : {}
        string = hsh.fetch("string", nil)
      elsif input.present? && File.exist?(input)
        ext = File.extname(input)
        if %w(.bib .ris .xml .json).include?(ext)
          hsh = { "url" => options[:url],
            "state" => options[:state],
            "date_registered" => options[:date_registered],
            "date_updated" => options[:date_updated],
            "provider_id" => options[:provider_id],
            "client_id" => options[:client_id],
            "content_url" => options[:content_url] }
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
                "client_id" => options[:client_id],
                "content_url" => options[:content_url] }
        string = input
        @from = from || find_from_format(string: string)
      end

      # make sure input is encoded as utf8
      string = string.force_encoding("UTF-8") if string.present?
      @string = string

      # input options for citation formatting
      @style = options[:style]
      @locale = options[:locale]

      @regenerate = options[:regenerate]
      @sandbox = options[:sandbox]

      # options that come from the datacite database
      @url = hsh.to_h["url"].presence || options[:url].presence
      @state = hsh.to_h["state"].presence
      @date_registered = hsh.to_h["date_registered"].presence
      @date_updated = hsh.to_h["date_updated"].presence
      @provider_id = hsh.to_h["provider_id"].presence
      @client_id = hsh.to_h["client_id"].presence
      @content_url = hsh.to_h["content_url"].presence

      # generate name for method to call dynamically
      @meta = @from.present? ? send("read_" + @from, string: string, sandbox: options[:sandbox]) : {}
      @identifier = normalize_doi(options[:doi] || input, options) || @meta.fetch("id", nil) || @meta.fetch("identifier", nil)
    end

    def id
      @id ||= meta.fetch("id", nil)
    end

    def doi
      @doi ||= @identifier.present? ? doi_from_url(@identifier) : meta.fetch("doi", nil)
    end

    def provider_id
      @provider_id ||= meta.fetch("provider_id", nil)
    end

    def client_id
      @client_id ||= meta.fetch("client_id", nil)
    end

    def exists?
      (@state || meta.fetch("state", "not_found")) != "not_found"
    end

    def valid?
      exists? && errors.nil?
    end

    # validate against DataCite schema, unless there are already errors in the reader
    def errors
      meta.fetch("errors", nil) || datacite_errors(xml: datacite, schema_version: schema_version)
    end
    
    def description
      @description ||= meta.fetch("description", nil)
    end

    def rights
      @rights ||= meta.fetch("rights", nil)
    end

    def keywords
      @keywords ||= meta.fetch("keywords", nil)
    end

    def language
      @language ||= meta.fetch("language", nil)
    end

    def size
      @size ||= meta.fetch("size", nil)
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

    def version
      @version ||= meta.fetch("version", nil)
    end

    def publication_year
      date_published.present? ? date_published[0..3].to_i.presence : nil
    end

    def periodical
      @periodical ||= meta.fetch("periodical", nil)
    end

    def descriptions
      Array.wrap(description)
    end

    def geo_location
      @geo_location ||= meta.fetch("geo_location", nil)
    end

    def dates
      @dates ||= meta.fetch("dates", nil)
    end

    def publisher
      @publisher ||= meta.fetch("publisher", nil)
    end

    def alternate_identifiers
      @alternate_identifiers ||= meta.fetch("alternate_identifiers", nil)
    end

    def content_url
      @content_url ||= meta.fetch("content_url", nil)
    end

    def state
      @state ||= meta.fetch("state", nil)
    end

    def identifier
      @identifier ||= meta.fetch("id", nil)
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

    def title
      @title ||= meta.fetch("title", nil)
    end

    def creator
      @creator ||= meta.fetch("creator", nil)
    end

    def date_published
      @date_published ||= meta.fetch("date_published", nil)
    end

    def date_modified
      @date_modified ||= meta.fetch("date_modified", nil)
    end

    def date_updated
      @date_updated ||= meta.fetch("date_updated", nil)
    end
  end
end