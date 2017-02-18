[![Build Status](https://travis-ci.org/datacite/bolognese.svg?branch=master)](https://travis-ci.org/datacite/bolognese)

# bolognese

Command-line utility for conversion of DOI metadata from and to [schema.org](https://schema.org) in JSON-LD.

## Features

* convert [Crossref XML](https://support.crossref.org/hc/en-us/articles/214936283-UNIXREF-query-output-format) to schema.org/JSON-LD
* convert [DataCite XML](http://schema.datacite.org/) to schema.org/JSON-LD
* fetch schema.org/JSON-LD from a URL
* convert schema.org/JSON-LD to [DataCite XML](http://schema.datacite.org/)
* convert Crossref XML to [DataCite XML](http://schema.datacite.org/)

Conversion to Crossref XML is not yet supported.

## Installation

The usual way with Bundler: add the following to your `Gemfile` to install the
current version of the gem:

```ruby
gem 'bolognese'
```

Then run `bundle install` to install into your environment.

You can also install the gem system-wide in the usual way:

```bash
gem install bolognese
```

## Commands

The bolognese commands understand URLs and DOIs as arguments. The `--as` command
line flag sets the format, either `crossref`, `datacite`, or `schema_org` (default).

## Examples

Convert Crossref XML to schema.org/JSON-LD:
```
bolognese read https://doi.org/10.7554/elife.01567
```

Read Crossref XML:
```
bolognese read https://doi.org/10.7554/elife.01567 --as crossref
```

Convert Crossref XML to DataCite XML:
```
bolognese read https://doi.org/10.7554/elife.01567 --as datacite
```

Convert DataCite XML to schema.org/JSON-LD:
```
bolognese read 10.5061/DRYAD.8515
```

Read DataCite XML:
```
bolognese read 10.5061/DRYAD.8515 --as datacite
```

## Development

We use rspec for unit testing:

```
bundle exec rspec
```

Follow along via [Github Issues](https://github.com/datacite/bolognese/issues).

### Note on Patches/Pull Requests

* Fork the project
* Write tests for your new feature or a test that reproduces a bug
* Implement your feature or make a bug fix
* Do not mess with Rakefile, version or history
* Commit, push and make a pull request. Bonus points for topical branches.

## License
**bolognese** is released under the [MIT License](https://github.com/datacite/bolognese/blob/master/LICENSE.md).
