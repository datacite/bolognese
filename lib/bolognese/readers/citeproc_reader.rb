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

        meta = string.present? ? Maremma.from_json(string) : {}

        citeproc_type = meta.fetch("type", nil)
        type = CP_TO_SO_TRANSLATIONS[citeproc_type] || "CreativeWork"
        types = {
          "type" => type,
          "resource_type_general" => Bolognese::Utils::SO_TO_DC_TRANSLATIONS[type],
          "reource_type" => meta.fetch("additionalType", nil),
          "citeproc" => citeproc_type,
          "bibtex" => Bolognese::Utils::SO_TO_BIB_TRANSLATIONS[type] || "misc",
          "ris" => CP_TO_RIS_TRANSLATIONS[type] || "GEN"
        }.compact
        doi = normalize_doi(meta.fetch("DOI", nil))
        creator = get_authors(from_citeproc(Array.wrap(meta.fetch("author", nil))))
        editor = get_authors(from_citeproc(Array.wrap(meta.fetch("editor", nil))))
        dates = if meta.fetch("issued", nil).present?
          [{ "date" => get_date_from_date_parts(meta.fetch("issued", nil)),
             "date_type" => "Issued" }]
        else
          nil
        end
        publication_year = get_date_from_date_parts(meta.fetch("issued", nil)).to_s[0..3]
        rights = if meta.fetch("copyright", nil)
          { "id" => normalize_url(meta.fetch("copyright")) }.compact
        else
          nil
        end
        related_identifiers = if meta.fetch("container-title", nil).present? && meta.fetch("ISSN", nil).present?
          [{ "type" => "Periodical",
             "relation_type" => "IsPartOf",
             "related_identifier_type" => "ISSN",
             "title" => meta.fetch("container-title", nil),
             "id" => meta.fetch("ISSN", nil) }.compact]
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
        state = id.present? ? "findable" : "not_found"

        { "id" => id,
          "types" => types,
          "doi" => doi_from_url(doi),
          "url" => normalize_id(meta.fetch("URL", nil)),
          "title" => meta.fetch("title", nil),
          "creator" => creator,
          "periodical" => periodical,
          "publisher" => meta.fetch("publisher", nil),
          "related_identifiers" => related_identifiers,
          "dates" => dates,
          "publication_year" => publication_year,
          "volume" => meta.fetch("volume", nil),
          #{}"pagination" => meta.pages.to_s.presence,
          "description" => meta.fetch("abstract", nil).present? ? { "text" => sanitize(meta.fetch("abstract")) } : nil,
          "rights" => rights,
          "version" => meta.fetch("version", nil),
          "keywords" => meta.fetch("categories", nil),
          "state" => state
        }
      end
    end
  end
end
