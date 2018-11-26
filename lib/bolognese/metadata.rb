# frozen_string_literal: true

require_relative 'metadata_utils'

module Bolognese
  class Metadata
    include Bolognese::MetadataUtils

    attr_writer :id, :provider_id, :client_id, :doi, :identifier, :creator, :contributor, :titles, :publisher, 
                :rights_list, :dates, :publication_year, :volume, :first_page, :last_page, :url, :version,
                :subjects, :contributor, :descriptions, :alternate_identifiers, :language, :sizes,
                :formats, :schema_version, :meta, :periodical, :agency,
                :format, :funding_references, :state, :geo_locations,
                :types, :content_url, :related_identifiers

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
                "content_url" => options[:content_url],
                "creator" => options[:creator],
                "contributor" => options[:creator],
                "titles" => options[:titles],
                "publisher" => options[:publisher],
                "publication_year" => options[:publication_year] }
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

      # set attributes directly
      read_options = options.slice(
        :sandbox,
        :creator,
        :contributor,
        :titles,
        :types,
        :alternate_identifiers,
        :periodical,
        :publisher,
        :funding_references,
        :dates,
        :publication_year,
        :descriptions,
        :rights_list,
        :version,
        :subjects,
        :language,
        :geo_locations,
        :related_identifiers,
        :formats,
        :sizes
      ).compact

      # generate name for method to call dynamically
      @meta = @from.present? ? send("read_" + @from, { string: string }.merge(read_options)) : {}
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

    def version
      @version ||= meta.fetch("version", nil)
    end

    def publication_year
      @publication_year ||= meta.fetch("publication_year", nil)
    end

    def periodical
      @periodical ||= meta.fetch("periodical", nil)
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

    def alternate_identifiers
      @alternate_identifiers ||= meta.fetch("alternate_identifiers", nil)
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

    def identifier
      @identifier ||= meta.fetch("id", nil)
    end

    def types
      @types ||= meta.fetch("types", nil)
    end

    def titles
      @titles ||= meta.fetch("titles", nil)
    end

    def creator
      @creator ||= meta.fetch("creator", nil)
    end

    def contributor
      @contributor ||= meta.fetch("contributor", nil)
    end
  end
end