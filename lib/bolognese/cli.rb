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

    desc "get pid", "read metadata for PID"
    def get(pid)
      metadata = Metadata.new(pid)
      provider = case metadata.provider
        when "crossref" then Crossref.new(pid)
        when "datacte" then DataCite.new(pid)
        end

      puts provider.schema.org
    end
  end
end
