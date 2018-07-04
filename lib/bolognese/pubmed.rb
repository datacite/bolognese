# frozen_string_literal: true

module Bolognese
  module Pubmed
    # def get_pubmed_metadata(pmid, options = {})
    #   return {} if pmid.blank?

    #   url = "http://www.ebi.ac.uk/europepmc/webservices/rest/search/query=ext_id:#{pmid}&format=json"
    #   response = Maremma.get(url, options)

    #   metadata = response.body.fetch("data", {}).fetch("resultList", {}).fetch("result", []).first
    #   return { error: 'Resource not found.', status: 404 } if metadata.blank?

    #   metadata["issued"] = metadata.fetch("pubYear", nil)

    #   author_string = metadata.fetch("authorString", "").chomp(".")
    #   metadata["author"] = get_authors(author_string.split(", "))

    #   metadata["title"] = metadata.fetch("title", "").chomp(".")
    #   metadata["container-title"] = metadata.fetch("journalTitle", nil)
    #   metadata["volume"] = metadata.fetch("journalVolume", nil)
    #   metadata["page"] = metadata.fetch("pageInfo", nil)
    #   metadata["type"] = "article-journal"

    #   metadata
    # end

    def pmid_as_url(pmid)
      "http://www.ncbi.nlm.nih.gov/pubmed/#{pmid}" if pmid.present?
    end

    def pmcid_as_url(pmcid)
      "http://www.ncbi.nlm.nih.gov/pmc/articles/PMC#{pmcid}" if pmcid.present?
    end
  end
end
