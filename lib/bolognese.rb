# frozen_string_literal: true

require 'active_support/all'
require 'nokogiri'
require 'maremma'
require 'bibtex'
require 'loofah'
require 'json/ld'
require 'rdf/turtle'
require 'rdf/rdfxml'
require 'logger'
require 'iso8601'
require 'jsonlint'
require 'gender_detector'
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
