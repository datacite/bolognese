require_relative 'base'
require_relative 'doi'
require_relative 'crossref'
require_relative 'datacite'
require_relative 'pubmed'
require_relative 'github'
require_relative 'orcid'
require_relative 'author_utils'
require_relative 'date_utils'

module Bolognese
  class Metadata
    include Bolognese::Base
    include Bolognese::Doi
    include Bolognese::Crossref
    include Bolognese::Datacite
    include Bolognese::Pubmed
    include Bolognese::Github
    include Bolognese::Orcid
    include Bolognese::AuthorUtils
    include Bolognese::DateUtils

    # CrossRef types from https://api.crossref.org/types
    CROSSREF_TYPE_TRANSLATIONS = {
      "proceedings" => nil,
      "reference-book" => nil,
      "journal-issue" => nil,
      "proceedings-article" => nil,
      "other" => nil,
      "dissertation" => nil,
      "dataset" => "Dataset",
      "edited-book" => "Book",
      "journal-article" => "ScholarlyArticle",
      "journal" => nil,
      "report" => "report",
      "book-series" => nil,
      "report-series" => nil,
      "book-track" => nil,
      "standard" => nil,
      "book-section" => nil,
      "book-part" => nil,
      "book" => "Book",
      "book-chapter" => nil,
      "standard-series" => nil,
      "monograph" => "book",
      "component" => nil,
      "reference-entry" => nil,
      "journal-volume" => nil,
      "book-set" => nil,
      "posted-content" => nil
    }

    def get_metadata(id:, service:, **options)
      metadata = case service
        when "crossref" then get_crossref_metadata(id, options = {})
        when "datacite" then get_datacite_metadata(id, options = {})
        when "pubmed" then get_pubmed_metadata(id, options = {})
        when "orcid" then get_orcid_metadata(id, options = {})
        when "github" then get_github_metadata(id, options = {})
        when "github_owner" then get_github_owner_metadata(id, options = {})
        when "github_release" then get_github_release_metadata(id, options = {})
      end

      # Default values if it was recognised but items were missing. This can happen with missing upstream metadata.
      if metadata

        if !metadata[:error]
          metadata["title"] = "(:unas)" if metadata["title"].blank?
          metadata["issued"] = "0000" if metadata["issued"].blank?
        end

        metadata
      else
        { error: 'Resource not found.', status: 404 }
      end
    end
  end
end
