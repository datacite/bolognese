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
                :types, :content_url, :related_identifiers, :related_items, :style, :locale, :date_registered

    def initialize(options={})
      options.symbolize_keys!
      id = normalize_id(options[:input], options)
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

      elsif options[:input].present? && File.exist?(options[:input])
        filename = File.basename(options[:input])
        ext = File.extname(options[:input])
        if %w(.bib .ris .xml .json).include?(ext)
          hsh = {
            "url" => options[:url],
            "state" => options[:state],
            "date_registered" => options[:date_registered],
            "date_updated" => options[:date_updated],
            "provider_id" => options[:provider_id],
            "client_id" => options[:client_id],
            "content_url" => options[:content_url] }
          string = IO.read(options[:input])
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
        string = options[:input]
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
        :creators,
        :contributors,
        :titles,
        :types,
        :identifiers,
        :container,
        :publisher,
        :funding_references,
        :dates,
        :publication_year,
        :descriptions,
        :rights_list,
        :version_info,
        :subjects,
        :language,
        :geo_locations,
        :related_identifiers,
        :related_items,
        :formats,
        :sizes
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

    def related_items
      @related_items ||= meta.fetch("related_items", nil)
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
      @container ||= begin
        generate_container || meta.fetch("container", nil)
      end
    end

    def geo_locations
      @geo_locations ||= meta.fetch("geo_locations", nil)
    end

    def dates
      @dates ||= meta.fetch("dates", nil)
    end

    def publisher
      @publisher ||= normalize_publisher(meta["publisher"]) if meta.fetch("publisher", nil).present?
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

    private

    def generate_container
      container_type = types&.dig("resourceTypeGeneral") == "Dataset" ? "DataRepository" : "Series"

      # relatedItem container
      related_item = Array.wrap(related_items).find { |ri| ri["relationType"] == "IsPublishedIn" }.to_h

      if related_item.present?
        return {
          "type" => container_type,
          "identifier" => related_item.dig("relatedItemIdentifier", "relatedItemIdentifier"),
          "identifierType" => related_item.dig("relatedItemIdentifier", "relatedItemIdentifierType"),
          "title" => related_item.dig("titles", 0).then { |t| t ? parse_attributes(t, content: "title", first: true) : nil },
          "volume" => related_item["volume"],
          "issue" => related_item["issue"],
          "edition" => related_item["edition"],
          "number" => related_item["number"],
          "chapterNumber" => related_item["numberType"] == "Chapter" ? related_item["number"] : nil,
          "firstPage" => related_item["firstPage"],
          "lastPage" => related_item["lastPage"]
        }.compact
      end

      # Legacy SeriesInformation/relatedIdentifier container fallback 
      series_information = Array.wrap(descriptions).find { |r| r["descriptionType"] == "SeriesInformation" }.to_h.fetch("description", nil)
      si = get_series_information(series_information)

      is_part_of = Array.wrap(related_identifiers).find { |ri| ri["relationType"] == "IsPartOf" }.to_h

      if si["title"].present?
        return {
          "type" => container_type,
          "identifier" => is_part_of["relatedIdentifier"],
          "identifierType" => is_part_of["relatedIdentifierType"],
          "title" => si["title"],
          "volume" => si["volume"],
          "issue" => si["issue"],
          "firstPage" => si["firstPage"],
          "lastPage" => si["lastPage"]
        }.compact
      end
    end
  end
end