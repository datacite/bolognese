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
    method_option :as, default: "schema_org"
    def open(pid)
      provider = Metadata.new(id: pid).provider

      case
      when provider == "crossref" && options[:as] == "crossref"
        puts Crossref.new(id: pid).raw
      when provider == "crossref" && options[:as] == "datacite"
        puts Crossref.new(id: pid).as_datacite
      when provider == "crossref"
        puts Crossref.new(id: pid).as_schema_org
      when provider == "datacite" && options[:as] == "datacite"
        puts Datacite.new(id: pid).raw
      when "datacite"
        puts Datacite.new(id: pid).as_schema_org
      else
        puts "not implemented"
      end
    end
  end
end
