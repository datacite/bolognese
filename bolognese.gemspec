require "date"
require File.expand_path("../lib/bolognese/version", __FILE__)

Gem::Specification.new do |s|
  s.authors       = "Martin Fenner"
  s.email         = "mfenner@datacite.org"
  s.name          = "bolognese"
  s.homepage      = "https://github.com/datacite/bolognese"
  s.summary       = "Ruby client library for conversion of DOI Metadata"
  s.date          = Date.today
  s.description   = "Ruby gem and command-line utility for conversion of DOI metadata from and to different metadata formats, including schema.org."
  s.require_paths = ["lib"]
  s.version       = Bolognese::VERSION
  s.extra_rdoc_files = ["README.md"]
  s.license       = 'MIT'
  s.required_ruby_version = '~> 2.3'

  # Declary dependencies here, rather than in the Gemfile
  s.add_dependency 'maremma', '>= 4.3', '< 5'
  s.add_dependency 'faraday', '0.17.0'
  s.add_dependency 'nokogiri', '~> 1.10.4'
  s.add_dependency 'loofah', '~> 2.0', '>= 2.0.3'
  s.add_dependency 'builder', '~> 3.2', '>= 3.2.2'
  s.add_dependency 'activesupport', '>= 4.2.5', '< 6'
  s.add_dependency 'bibtex-ruby', '~> 4.1'
  s.add_dependency 'thor', '~> 0.19'
  s.add_dependency 'colorize', '~> 0.8.1'
  s.add_dependency 'namae', '~> 1.0'
  s.add_dependency 'edtf', '~> 3.0', '>= 3.0.4'
  s.add_dependency 'citeproc-ruby', '~> 1.1', '>= 1.1.10'
  s.add_dependency 'csl-styles', '~> 1.0', '>= 1.0.1.8'
  s.add_dependency 'iso8601', '~> 0.9.1'
  s.add_dependency 'postrank-uri', '~> 1.0', '>= 1.0.18'
  s.add_dependency 'json-ld-preloaded', '~> 3.0'
  s.add_dependency 'jsonlint', '~> 0.3.0'
  s.add_dependency 'oj', '~> 3.10'
  s.add_dependency "oj_mimic_json", "~> 1.0", ">= 1.0.1"
  s.add_dependency 'rdf-turtle', '~> 3.0', '>= 3.0.6'
  s.add_dependency 'rdf-rdfxml', '~> 2.2'
  s.add_dependency 'benchmark_methods', '~> 0.7'
  s.add_dependency 'gender_detector', '~> 0.1.2'
  s.add_dependency 'concurrent-ruby', '~> 1.0.5'
  s.add_development_dependency 'bundler', '>= 1.0'
  s.add_development_dependency 'rspec', '~> 3.4'
  s.add_development_dependency 'rspec-xsd', '~> 0.1.0'
  s.add_development_dependency 'rake', '~> 12.0'
  s.add_development_dependency 'rack-test', '~> 0'
  s.add_development_dependency 'vcr', '~> 3.0', '>= 3.0.3'
  s.add_development_dependency 'webmock', '~> 3.0', '>= 3.0.1'
  s.add_development_dependency 'codeclimate-test-reporter', '~> 1.0', '>= 1.0.8'
  s.add_development_dependency 'simplecov', '~> 0.1'
  s.add_development_dependency 'hashdiff', ['>= 1.0.0.beta1', '< 2.0.0']

  s.require_paths = ["lib"]
  s.files       = `git ls-files`.split($/)
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = ["bolognese"]
end
