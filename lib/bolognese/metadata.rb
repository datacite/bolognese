require_relative 'doi_utils'
require_relative 'author_utils'
require_relative 'date_utils'
require_relative 'datacite_utils'
require_relative 'utils'

module Bolognese
  class Metadata
    include Bolognese::DoiUtils
    include Bolognese::AuthorUtils
    include Bolognese::DateUtils
    include Bolognese::DataciteUtils
    include Bolognese::Utils

    attr_reader :id, :raw, :provider

    def initialize(id: nil)
      @id = normalize_id(id)
      @provider = find_provider(@id)
    end

    def normalize_id(id)
      normalize_doi(id) || normalize_orcid(id)
    end

    def find_provider(id)
      if /\A(?:(http|https):\/\/(dx\.)?doi.org\/)?(doi:)?(10\.\d{4,5}\/.+)\z/.match(id)
        get_doi_ra(id).fetch("id", nil)
      elsif /\A(?:(http|https):\/\/orcid\.org\/)?(\d{4}-\d{4}-\d{4}-\d{3}[0-9X]+)\z/.match(id)
        "orcid"
      else
        "schema_org"
      end
    end

    def url

    end

    def version

    end

    def keywords

    end

    def date_created

    end

    def page_start

    end

    def page_end

    end

    def has_part

    end

    def publisher

    end

    def as_schema_org
      { "@context" => "http://schema.org",
        "@type" => type,
        "@id" => id,
        "url" => url,
        "additionalType" => additional_type,
        "name" => name,
        "alternateName" => alternate_name,
        "author" => author,
        "editor" => editor,
        "description" => description,
        "license" => license,
        "version" => version,
        "keywords" => keywords,
        "dateCreated" => date_created,
        "datePublished" => date_published,
        "dateModified" => date_modified,
        "pageStart" => page_start,
        "pageEnd" => page_end,
        "isPartOf" => is_part_of,
        "hasPart" => has_part,
        "citation" => citation,
        "publisher" => publisher,
        "provider" => provider
      }.compact
    end
  end
end
