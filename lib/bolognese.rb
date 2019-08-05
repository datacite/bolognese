# frozen_string_literal: true

require 'active_support/all'
require 'nokogiri'
require 'maremma'
require 'postrank-uri'
require 'bibtex'
require 'colorize'
require 'loofah'
require 'json/ld/preloaded'
require 'rdf/turtle'
require 'rdf/rdfxml'
require 'logger'
require 'iso8601'
require 'jsonlint'
require 'benchmark_methods'
require 'gender_detector'
require 'citeproc/ruby'
require 'citeproc'
require 'csl/styles'
require 'edtf'

require "bolognese/version"
require "bolognese/metadata"
require "bolognese/cli"
require "bolognese/string"
require "bolognese/array"
require "bolognese/whitelist_scrubber"

ENV['USER_AGENT'] ||= "Mozilla/5.0 (compatible; Maremma/#{Maremma::VERSION}; mailto:info@datacite.org)"
