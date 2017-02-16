# encoding: UTF-8

require "thor"

module Bolognese
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    # from http://stackoverflow.com/questions/22809972/adding-a-version-option-to-a-ruby-thor-cli
    map %w[--version -v] => :__print_version

    desc "--version, -v", "print the version"
    def __print_version
      puts Bolognese::VERSION
    end

    desc "read pid", "read metadata for PID"
    method_option :as, :default => "schema_org"
    def read(pid)
      provider = Metadata.new(pid).provider

      case
      when provider == "crossref" && options[:as] == "crossref"
        puts Crossref.new(pid).raw
      when provider == "crossref"
        puts Crossref.new(pid).as_schema_org
      when provider == "datacite" && options[:as] == "datacite"
        puts Datacite.new(pid).raw
      when "datacite"
        puts Datacite.new(pid).as_schema_org
      else
        puts "not implemented"
      end
    end
  end
end
