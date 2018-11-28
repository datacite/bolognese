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

        read_options = ActiveSupport::HashWithIndifferentAccess.new(options.except(:string, :sandbox))

        meta = string.present? ? Maremma.from_json(string) : {}

        citeproc_type = meta.fetch("type", nil)
        schema_org = CP_TO_SO_TRANSLATIONS[citeproc_type] || "CreativeWork"
        types = {
          "resourceTypeGeneral" => Bolognese::Utils::SO_TO_DC_TRANSLATIONS[schema_org],
          "reourceType" => meta.fetch("additionalType", nil),
          "schemaOrg" => schema_org,
          "citeproc" => citeproc_type,
          "bibtex" => Bolognese::Utils::SO_TO_BIB_TRANSLATIONS[schema_org] || "misc",
          "ris" => CP_TO_RIS_TRANSLATIONS[schema_org] || "GEN"
        }.compact
        doi = normalize_doi(meta.fetch("DOI", nil))
        creator = get_authors(from_citeproc(Array.wrap(meta.fetch("author", nil))))
        contributor = get_authors(from_citeproc(Array.wrap(meta.fetch("editor", nil))))
        dates = if meta.fetch("issued", nil).present?
          [{ "date" => get_date_from_date_parts(meta.fetch("issued", nil)),
             "dateType" => "Issued" }]
        else
          nil
        end
        publication_year = get_date_from_date_parts(meta.fetch("issued", nil)).to_s[0..3]
        rights_list = if meta.fetch("copyright", nil)
          [{ "rightsUri" => normalize_url(meta.fetch("copyright")) }.compact]
        else
          nil
        end
        related_identifiers = if meta.fetch("container-title", nil).present? && meta.fetch("ISSN", nil).present?
          [{ "type" => "Periodical",
             "relationType" => "IsPartOf",
             "relatedIdentifierType" => "ISSN",
             "title" => meta.fetch("container-title", nil),
             "relatedIdentifier" => meta.fetch("ISSN", nil) }.compact]
        else
          nil
        end
        periodical = if meta.fetch("container-title", nil).present?
          { "type" => "Periodical",
            "title" => meta.fetch("container-title", nil),
            "issn" => meta.fetch("ISSN", nil) }.compact
        else
          nil
        end
        id = normalize_id(meta.fetch("id", nil))
        state = id.present? || read_options.present? ? "findable" : "not_found"
        subjects = Array.wrap(meta.fetch("categories", nil)).map do |s|
          { "subject" => s }
        end

        { "id" => id,
          "types" => types,
          "doi" => doi_from_url(doi),
          "url" => normalize_id(meta.fetch("URL", nil)),
          "titles" => [{ "title" => meta.fetch("title", nil) }],
          "creator" => creator,
          "contributor" => contributor,
          "periodical" => periodical,
          "publisher" => meta.fetch("publisher", nil),
          "related_identifiers" => related_identifiers,
          "dates" => dates,
          "publication_year" => publication_year,
          "volume" => meta.fetch("volume", nil),
          #{}"pagination" => meta.pages.to_s.presence,
          "descriptions" => meta.fetch("abstract", nil).present? ? [{ "description" => sanitize(meta.fetch("abstract")), "descriptionType" => "Abstract" }] : [],
          "rights_list" => rights_list,
          "version_info" => meta.fetch("version", nil),
          "subjects" => subjects,
          "state" => state
        }.merge(read_options)
      end
    end
  end
end
