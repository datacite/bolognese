module Bolognese
  module Readers
    module BibtexReader
      BIB_TO_CP_TRANSLATIONS = {
        "article" => "article-journal",
        "phdthesis" => "thesis"
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
        "article" => "ScholarlyArticle",
        "phdthesis" => "Thesis"
      }

      def read_bibtex(string: nil, **options)
        meta = string.present? ? BibTeX.parse(string).first : OpenStruct.new

        type = BIB_TO_SO_TRANSLATIONS[meta.try(:type).to_s] || "ScholarlyArticle"
        doi = meta.try(:doi).to_s.presence

        author = Array(meta.try(:author)).map do |a|
                  { "type" => "Person",
                    "name" => [a.first, a.last].join(" "),
                    "givenName" => a.first,
                    "familyName" => a.last }.compact
                end

        is_part_of = if meta.try(:journal).present?
                  { "type" => "Periodical",
                    "title" => meta.journal.to_s,
                    "issn" => meta.try(:issn).to_s.presence }.compact
                else
                  nil
                end

        page_first, page_last = meta.try(:pages).to_s.split("-")
        state = doi.present? ? "findable" : "not_found"

        { "id" => normalize_doi(doi),
          "type" => type,
          "bibtex_type" => meta.type.to_s,
          "citeproc_type" => BIB_TO_CP_TRANSLATIONS[meta.try(:type).to_s] || "misc",
          "ris_type" => BIB_TO_RIS_TRANSLATIONS[meta.try(:type).to_s] || "GEN",
          "resource_type_general" => Metadata::SO_TO_DC_TRANSLATIONS[type],
          "additional_type" => Bolognese::Utils::BIB_TO_CR_TRANSLATIONS[meta.try(:type).to_s] || meta.try(:type).to_s,
          "doi" => doi,
          "b_url" => meta.try(:url).to_s,
          "title" => meta.try(:title).to_s,
          "author" => author,
          "publisher" => meta.try(:publisher).to_s.presence,
          "is_part_of" => is_part_of,
          "date_published" => meta.try(:date).to_s.presence,
          "volume" => meta.try(:volume).to_s.presence,
          "page_first" => page_first,
          "page_last" => page_last,
          "description" => { "text" => meta.try(:abstract) && sanitize(meta.abstract.to_s).presence },
          "license" => { "id" => meta.try(:copyright).to_s.presence },
          "state" => state
        }
      end
    end
  end
end
