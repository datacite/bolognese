require_relative 'metadata_utils'

module Bolognese
  class Metadata
    include Bolognese::MetadataUtils

    def initialize(input: nil, from: nil, **options)
      id = normalize_id(input, options)

      if id.present?
        @from = from || find_from_format(id: id)

        # generate name for method to call dynamically
        hsh = @from.present? ? send("get_" + @from, id: id, sandbox: options[:sandbox]) : {}
        string = hsh.fetch("string", nil)
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
        hsh = { "b_url" => options[:b_url],
                "state" => options[:state],
                "date_registered" => options[:date_registered],
                "date_updated" => options[:date_updated],
                "provider_id" => options[:provider_id],
                "client_id" => options[:client_id] }
        string = input
        @from = from || find_from_format(string: string)
      end

      # make sure input is encoded as utf8
      string = string.force_encoding("UTF-8") if string.present?
      @string = string

      # input options for citation formatting
      @style = options[:style]
      @locale = options[:locale]

      # input specific metadata elements required for DataCite
      @doi = options[:doi].presence
      @author = options[:author].presence
      @title = options[:title].presence
      @publisher = options[:publisher].presence
      @resource_type_general = options[:resource_type_general].presence

      # input specific metadata elements recommended for DataCite
      @additional_type = options[:additional_type].presence
      @description = options[:description].presence
      @license = options[:license].presence
      @date_published = options[:date_published].presence

      @regenerate = options[:regenerate]
      @sandbox = options[:sandbox]

      @b_url = hsh.to_h["b_url"].presence || options[:b_url].presence
      @state = hsh.to_h["state"].presence
      @date_registered = hsh.to_h["date_registered"].presence
      @date_updated = hsh.to_h["date_updated"].presence
      @provider_id = hsh.to_h["provider_id"].presence
      @client_id = hsh.to_h["client_id"].presence

      # generate name for method to call dynamically
      @metadata = @from.present? ? send("read_" + @from, string: @string, id: id, sandbox: @sandbox, doi: @doi, url: @b_url) : {}
      @id = @metadata.fetch("id", nil) || id
    end
  end
end