require_relative 'doi'
require_relative 'author_utils'
require_relative 'date_utils'
require_relative 'pid_utils'

module Bolognese
  class Metadata
    include Bolognese::Doi
    include Bolognese::AuthorUtils
    include Bolognese::DateUtils
    include Bolognese::PidUtils

    attr_reader :id, :metadata, :service, :schema_org

    def initialize(id)
      @id = normalize_doi(id) || normalize_orcid(id)
      @service = select_service(@id)

      #response = Maremma.get(@id, accept: "application/vnd.crossref.unixref+xml", host: true)
      #@metadata = response.body.fetch("data", {}).fetch("doi_records", {}).fetch("doi_record", {})
    end

    def normalize_id(id)
      normalize_doi(id) || normalize_orcid(id)
    end

    def select_service(id)
      get_doi_ra(id).fetch("id", nil) || "orcid"
    end
  end
end
