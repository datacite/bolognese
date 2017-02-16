require_relative 'doi_utils'
require_relative 'author_utils'
require_relative 'date_utils'
require_relative 'pid_utils'
require_relative 'utils'

module Bolognese
  class Metadata
    include Bolognese::DoiUtils
    include Bolognese::AuthorUtils
    include Bolognese::DateUtils
    include Bolognese::PidUtils
    include Bolognese::Utils

    attr_reader :id, :provider

    def initialize(id)
      @id = normalize_id(id)
      @provider = find_provider(@id)
    end

    def normalize_id(id)
      normalize_doi(id) || normalize_orcid(id)
    end

    def find_provider(id)
      get_doi_ra(id).fetch("id", nil) || "orcid"
    end
  end
end
