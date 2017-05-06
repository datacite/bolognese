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
        "computer_program" => "SoftwareSourceCode",
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
        "computer_program" => "COMP",
        "broadcast" => "MPCT",
        "webpage" => "ELEC"
      }

      def read_citeproc(string: nil)
        errors = jsonlint(string)
        return { "errors" => errors } if errors.present?

        meta = string.present? ? Maremma.from_json(string) : {}

        citeproc_type = meta.fetch("type", nil)
        type = CP_TO_SO_TRANSLATIONS[citeproc_type] || "CreativeWork"
        author = get_authors(from_citeproc(Array.wrap(meta.fetch("author", nil))))
        editor = get_authors(from_citeproc(Array.wrap(meta.fetch("editor", nil))))
        date_published = get_date_from_date_parts(meta.fetch("issued", nil))
        container_title = meta.fetch("container-title", nil)
        is_part_of = if container_title.present?
                       { "type" => "Periodical",
                         "name" => container_title,
                         "issn" => meta.fetch("ISSN", nil) }.compact
                     else
                       nil
                     end

        { "id" => normalize_id(meta.fetch("id", nil)),
          "type" => type,
          "additional_type" => meta.fetch("additionalType", nil),
          "citeproc_type" => citeproc_type,
          "bibtex_type" => Bolognese::Utils::SO_TO_BIB_TRANSLATIONS[type] || "misc",
          "ris_type" => CP_TO_RIS_TRANSLATIONS[type] || "GEN",
          "resource_type_general" => Bolognese::Utils::SO_TO_DC_TRANSLATIONS[type],
          "doi" => meta.fetch("DOI", nil),
          "url" => normalize_id(meta.fetch("URL", nil)),
          "title" => meta.fetch("title", nil),
          "author" => author,
          "container_title" => container_title,
          "publisher" => meta.fetch("publisher", nil),
          "is_part_of" => is_part_of,
          "date_published" => date_published,
          "volume" => meta.fetch("volume", nil),
          #{}"pagination" => meta.pages.to_s.presence,
          "description" => { "text" => meta.fetch("abstract", nil) },
          #{ }"license" => { "id" => meta.field?(:copyright) && meta.copyright.to_s.presence },
          "version" => meta.fetch("version", nil),
          "keywords" => meta.fetch("categories", nil)
        }
      end
    end
  end
end
