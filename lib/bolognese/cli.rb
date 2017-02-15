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
    method_option :sandbox, :type => :boolean, :force => false
    def read(pid)
      metadata = Metadata.new(pid)
      puts metadata.service
    end
  end
end
