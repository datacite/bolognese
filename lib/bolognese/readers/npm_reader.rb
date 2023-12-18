# frozen_string_literal: true

module Bolognese
  module Readers
    module NpmReader
      def get_npm(id: nil, **options)
        return { "string" => nil, "state" => "not_found" } unless id.present?
        id = normalize_id(id)
        response = Maremma.get(id, accept: "json", raw: true)
        string = response.body.fetch("data", nil)

        { "string" => string }
      end

      def read_npm(string: nil, **options)
        if string.present?
          errors = jsonlint(string)
          return { "errors" => errors } if errors.present?
        end

        read_options = ActiveSupport::HashWithIndifferentAccess.new(options.except(:doi, :id, :url, :sandbox, :validate, :ra))

        meta = string.present? ? Maremma.from_json(string) : {}

        types = {
          "resourceTypeGeneral" => "Software",
          "reourceType" => "NPM Package",
          "schemaOrg" => "SoftwareSourceCode",
          "citeproc" => "article",
          "bibtex" => "misc",
          "ris" => "GEN"
        }.compact

        creators = if meta.fetch("author", nil).present?
          get_authors(Array.wrap(meta.fetch("author", nil)))
        else
          [{ "nameType" => "Organizational", "name" => ":(unav)" }]
        end
        # contributors = get_authors(from_citeproc(Array.wrap(meta.fetch("editor", nil))))
        # dates = if date = get_date_from_date_parts(meta.fetch("issued", nil))
        #           if Date.edtf(date).present?
        #             [{ "date" => date,
        #               "dateType" => "Issued" }]
        #           end
        #         end
        # publication_year = get_date_from_date_parts(meta.fetch("issued", nil)).to_s[0..3]
        rights_list = if meta.fetch("license", nil)
                        [{ "rights" => meta.fetch("license") }.compact]
                      end
        # related_identifiers = if meta.fetch("container-title", nil).present? && meta.fetch("ISSN", nil).present?
        #                         [{ "type" => "Periodical",
        #                           "relationType" => "IsPartOf",
        #                           "relatedIdentifierType" => "ISSN",
        #                           "title" => meta.fetch("container-title", nil),
        #                           "relatedIdentifier" => meta.fetch("ISSN", nil) }.compact]
        #                       end
        # container = if meta.fetch("container-title", nil).present?
        #   first_page = meta.fetch("page", nil).present? ? meta.fetch("page").split("-").map(&:strip)[0] : nil
        #   last_page = meta.fetch("page", nil).present? ? meta.fetch("page").split("-").map(&:strip)[1] : nil

        #   { "type" => "Periodical",
        #     "title" => meta.fetch("container-title", nil),
        #     "identifier" => meta.fetch("ISSN", nil),
        #     "identifierType" => meta.fetch("ISSN", nil).present? ? "ISSN" : nil,
        #     "volume" => meta.fetch("volume", nil),
        #     "issue" => meta.fetch("issue", nil),
        #     "firstPage" => first_page,
        #     "lastPage" => last_page
        #    }.compact
        # else
        #   nil
        # end

        # identifiers = [normalize_id(meta.fetch("id", nil)), normalize_doi(meta.fetch("DOI", nil))].compact.map do |r|
        #   r = normalize_id(r)

        #   if r.start_with?("https://doi.org")
        #     { "identifierType" => "DOI", "identifier" => r }
        #   else
        #       { "identifierType" => "URL", "identifier" => r }
        #   end
        # end.uniq

        # id = Array.wrap(identifiers).first.to_h.fetch("identifier", nil)
        # doi = Array.wrap(identifiers).find { |r| r["identifierType"] == "DOI" }.to_h.fetch("identifier", nil)
          
        # state = id.present? || read_options.present? ? "findable" : "not_found"
        subjects = Array.wrap(meta.fetch("keywords", nil)).map do |s|
          { "subject" => s }
        end

        { 
          #"id" => id,
          #"identifiers" => identifiers,
          "types" => types,
          #"doi" => doi_from_url(doi),
          #"url" => normalize_id(meta.fetch("URL", nil)),
          "titles" => [{ "title" => meta.fetch("name", nil) }],
          "creators" => creators,
          #"contributors" => contributors,
          #"container" => container,
          #"publisher" => meta.fetch("publisher", nil),
          #"related_identifiers" => related_identifiers,
          #"dates" => dates,
          #"publication_year" => publication_year,
          "descriptions" => meta.fetch("description", nil).present? ? [{ "description" => sanitize(meta.fetch("description")), "descriptionType" => "Abstract" }] : [],
          "rights_list" => rights_list,
          "version_info" => meta.fetch("version", nil),
          "subjects" => subjects
          #"state" => state
        }.merge(read_options)
      end
    end
  end
end
