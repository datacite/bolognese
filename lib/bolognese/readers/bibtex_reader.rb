module Bolognese
  module Readers
    module BibtexReader
      BIB_TO_CP_TRANSLATIONS = {
        "article" => "article-journal"
      }

      BIB_TO_RIS_TRANSLATIONS = {
        "article" => "JOUR",
        "book" => "BOOK",
        "inbook" => "CHAP",
        "inproceedings" => "CPAPER",
        "manual" => nil,
        "misc" => "GEN",
        "phdthesis" => "THES",
        "proceedings" => "CONF",
        "techreport" => "RPRT",
        "unpublished" => "UNPD"
      }

      BIB_TO_SO_TRANSLATIONS = {
        "article" => "ScholarlyArticle"
      }

      def read_bibtex(string: nil)
        meta = string.present? ? BibTeX.parse(string).first : OpenStruct.new

        type = BIB_TO_SO_TRANSLATIONS[meta.type.to_s] || "ScholarlyArticle"
        doi = meta.doi.to_s

        author = Array(meta.author).map do |a|
                  { "type" => "Person",
                    "name" => [a.first, a.last].join(" "),
                    "givenName" => a.first,
                    "familyName" => a.last }.compact
                end

        is_part_of = if meta.journal.present?
                  { "type" => "Periodical",
                    "title" => meta.journal.to_s,
                    "issn" => meta.issn.to_s.presence }.compact
                else
                  nil
                end

        { "id" => normalize_doi(doi),
          "type" => type,
          "citeproc_type" => BIB_TO_CP_TRANSLATIONS[meta.type.to_s] || "misc",
          "ris_type" => BIB_TO_RIS_TRANSLATIONS[meta.type.to_s] || "GEN",
          "resource_type_general" => Metadata::SO_TO_DC_TRANSLATIONS[type],
          "doi" => doi,
          "url" => meta.url.to_s,
          "title" => meta.title.to_s,
          "author" => author,
          "publisher" => meta.publisher.to_s.presence,
          "is_part_of" => is_part_of,
          "date_published" => meta.date.to_s.presence,
          "volume" => meta.volume.to_s.presence,
          "pagination" => meta.pages.to_s.presence,
          "description" => { "text" => meta.field?(:abstract) && meta.abstract.to_s.presence },
          "license" => { "id" => meta.field?(:copyright) && meta.copyright.to_s.presence }
        }
      end
    end
  end
end
