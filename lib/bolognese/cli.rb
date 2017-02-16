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
      metadata = Metadata.new(pid)
      provider = case metadata.provider
        when "crossref" then Crossref.new(pid)
        when "datacite" then Datacite.new(pid)
        when "orcid" then Orcid.new(pid)
        end

      case options[:as]
      when "schema_org" then provider.as_schema_org
      when "crossref"
        provider == "crossref" ? Crossref.new(pid).raw : "not implemented"
      when "datacite"
        provider == "datacite" ? Datacite.new(pid).raw : "not implemented"
      end
    end
  end
end
