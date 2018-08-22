# frozen_string_literal: true

require_relative 'metadata_utils'

module Bolognese
  class Metadata
    include Bolognese::MetadataUtils

    attr_writer :id, :provider_id, :client_id, :doi

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
          string = IO.read(input)
          @from = from || find_from_format(string: string, ext: ext)
        else
          $stderr.puts "File type #{ext} not supported"
          exit 1
        end
      else
        hsh = { "b_url" => options[:b_url],
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
      @b_url = hsh.to_h["b_url"].presence || options[:b_url].presence
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
  end
end