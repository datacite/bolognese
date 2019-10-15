# encoding: UTF-8
# frozen_string_literal: true

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
    method_option :regenerate, :type => :boolean, :force => false
    method_option :style, aliases: "-s", default: "apa"
    method_option :locale, aliases: "-l", default: "en-US"
    method_option :ignore_errors, aliases: "-e", default: "false"
    def convert(input)
      metadata = Metadata.new(input: input,
                              from: options[:from],
                              regenerate: options[:regenerate],
                              style: options[:style],
                              locale: options[:locale])
      to = options[:to] || "schema_org"

      if metadata.valid? || options[:ignore_errors]
        puts metadata.send(to)
      else
        $stderr.puts metadata.errors
      end
    end

    default_task :convert
  end
end
