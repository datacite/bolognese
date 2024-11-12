# frozen_string_literal: true

module Bolognese
  module Readers
    module CiteprocReader
      CP_TO_SO_TRANSLATIONS = {
        "song" => "AudioObject",
        "post-weblog" => "BlogPosting",
        "dataset" => "Dataset",
        "graphic" => "ImageObject",
        "motion_picture" => "Movie",
        "article-journal" => "ScholarlyArticle",
        "broadcast" => "VideoObject",
        "webpage" => "WebPage"
      }

      CP_TO_RIS_TRANSLATIONS = {
        "post-weblog" => "BLOG",
        "dataset" => "DATA",
        "graphic" => "FIGURE",
        "book" => "BOOK",
        "motion_picture" => "MPCT",
        "article-journal" => "JOUR",
        "broadcast" => "MPCT",
        "webpage" => "ELEC"
      }

      def read_citeproc(string: nil, **options)
        if string.present?
          errors = jsonlint(string)
          return { "errors" => errors } if errors.present?
        end

        read_options = ActiveSupport::HashWithIndifferentAccess.new(options.except(:doi, :id, :url, :sandbox, :validate, :ra))

        meta = string.present? ? Maremma.from_json(string) : {}

        citeproc_type = meta.fetch("type", nil)
        schema_org = CP_TO_SO_TRANSLATIONS[citeproc_type] || "CreativeWork"
        types = {
          "resourceTypeGeneral" => Bolognese::Utils::CP_TO_DC_TRANSLATIONS[citeproc_type],
          "reourceType" => meta.fetch("additionalType", nil),
          "schemaOrg" => schema_org,
          "citeproc" => citeproc_type,
          "bibtex" => Bolognese::Utils::SO_TO_BIB_TRANSLATIONS[schema_org] || "misc",
          "ris" => CP_TO_RIS_TRANSLATIONS[schema_org] || "GEN"
        }.compact

        creators = if meta.fetch("author", nil).present?
          get_authors(from_citeproc(Array.wrap(meta.fetch("author", nil))))
        else
          [{ "nameType" => "Organizational", "name" => ":(unav)" }]
        end
        contributors = get_authors(from_citeproc(Array.wrap(meta.fetch("editor", nil))))
        translators = get_authors(from_citeproc(Array.wrap(meta.fetch("translator", nil))))
        translators.each do |translator|
          translator["contributorType"] = "Translator"
        end
        contributors += translators

        dates = if date = get_date_from_date_parts(meta.fetch("issued", nil))
                  if Date.edtf(date).present?
                    [{ "date" => date,
                      "dateType" => "Issued" }]
                  end
                end
        publication_year = get_date_from_date_parts(meta.fetch("issued", nil)).to_s[0..3]
        rights_list = if meta.fetch("copyright", nil)
                        [hsh_to_spdx("rightsURI" => meta.fetch("copyright"))]
                      end
        related_identifiers = if meta.fetch("container-title", nil).present? && meta.fetch("ISSN", nil).present?
                                [{ "type" => "Periodical",
                                  "relationType" => "IsPartOf",
                                  "relatedIdentifierType" => "ISSN",
                                  "title" => meta.fetch("container-title", nil),
                                  "relatedIdentifier" => meta.fetch("ISSN", nil) }.compact]
                              end
        container = if meta.fetch("container-title", nil).present?
          first_page = meta.fetch("page", nil).present? ? meta.fetch("page").split("-").map(&:strip)[0] : nil
          last_page = meta.fetch("page", nil).present? ? meta.fetch("page").split("-").map(&:strip)[1] : nil

          { "type" => "Periodical",
            "title" => meta.fetch("container-title", nil),
            "identifier" => meta.fetch("ISSN", nil),
            "identifierType" => meta.fetch("ISSN", nil).present? ? "ISSN" : nil,
            "volume" => meta.fetch("volume", nil),
            "issue" => meta.fetch("issue", nil),
            "firstPage" => first_page,
            "lastPage" => last_page
           }.compact
        else
          nil
        end

        id = normalize_id(meta.fetch("id", nil) || meta.fetch("DOI", nil))

        state = id.present? || read_options.present? ? "findable" : "not_found"
        subjects = Array.wrap(meta.fetch("categories", nil)).reduce([]) do |sum, subject|
          sum += name_to_fos(subject)

          sum
        end

        { "id" => id,
          "types" => types,
          "doi" => doi_from_url(id),
          "url" => normalize_id(meta.fetch("URL", nil)),
          "titles" => [{ "title" => meta.fetch("title", nil) }],
          "creators" => creators,
          "contributors" => contributors,
          "container" => container,
          "publisher" => meta.fetch("publisher", nil),
          "related_identifiers" => related_identifiers,
          "dates" => dates,
          "publication_year" => publication_year,
          "descriptions" => meta.fetch("abstract", nil).present? ? [{ "description" => sanitize(meta.fetch("abstract"), new_line: true), "descriptionType" => "Abstract" }] : [],
          "rights_list" => rights_list,
          "version_info" => meta.fetch("version", nil),
          "subjects" => subjects,
          "state" => state
        }.merge(read_options)
      end
    end
  end
end
