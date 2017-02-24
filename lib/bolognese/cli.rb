# encoding: UTF-8

require "thor"

require_relative 'doi_utils'
require_relative 'utils'

module Bolognese
  class CLI < Thor
    include Bolognese::DoiUtils
    include Bolognese::Utils

    def self.exit_on_failure?
      true
    end

    # from http://stackoverflow.com/questions/22809972/adding-a-version-option-to-a-ruby-thor-cli
    map %w[--version -v] => :__print_version

    desc "--version, -v", "print the version"
    def __print_version
      puts Bolognese::VERSION
    end

    desc "", "convert metadata"
    method_option :from, aliases: "-f"
    method_option :to, aliases: "-t", default: "schema_org"
    method_option :schema_version
    def convert(input)
      id = normalize_id(input)

      if id.present?
        from = options[:from] || find_from_format(id: id)
      else
        ext = File.extname(input)
        filename = File.basename(input)
        if %w(.bib .xml).include?(ext) || filename == "codemeta.json"
          string = IO.read(input)
        else
          $stderr.puts "File type #{ext} not supported"
          exit 1
        end
        from = options[:from] || find_from_format(string: string, ext: ext, filename: filename)
      end

      to = options[:to] || "schema_org"

      write(id: id, string: string, from: from, to: to, schema_version: options[:schema_version])
    end

    default_task :convert
  end
end
