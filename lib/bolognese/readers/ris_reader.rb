# frozen_string_literal: true

module Bolognese
  module Readers
    module RisReader
      RIS_TO_SO_TRANSLATIONS = {
        "BLOG" => "BlogPosting",
        "GEN" => "CreativeWork",
        "CTLG" => "DataCatalog",
        "DATA" => "Dataset",
        "FIGURE" => "ImageObject",
        "THES" => "Thesis",
        "MPCT" => "Movie",
        "JOUR" => "ScholarlyArticle",
        "COMP" => "SoftwareSourceCode",
        "VIDEO" => "VideoObject",
        "ELEC" => "WebPage"
      }

      RIS_TO_CP_TRANSLATIONS = {
        "JOUR" => "article-journal"
      }

      RIS_TO_BIB_TRANSLATIONS = {
        "JOUR" => "article",
        "BOOK" => "book",
        "CHAP" => "inbook",
        "CPAPER" => "inproceedings",
        "GEN" => "misc",
        "THES" => "phdthesis",
        "CONF" => "proceedings",
        "RPRT" => "techreport",
        "UNPD" => "unpublished"
      }

      def read_ris(string: nil, **options)
        meta = ris_meta(string: string)

        ris_type = meta.fetch("TY", nil) || "GEN"
        type = RIS_TO_SO_TRANSLATIONS[ris_type] || "CreativeWork"

        doi = validate_doi(meta.fetch("DO", nil))
        author = Array.wrap(meta.fetch("AU", nil)).map { |a| { "name" => a } }
        date_parts = meta.fetch("PY", nil).to_s.split("/")
        date_published = get_date_from_parts(*date_parts)
        related_identifiers = if meta.fetch("T2", nil).present? && meta.fetch("SN", nil).present?
          [{ "type" => "Periodical",
             "id" => meta.fetch("SN", nil),
             "related_identifier_type" => "ISSN",
             "relation_type" => "IsPartOf",
             "title" => meta.fetch("T2", nil), }.compact]
        else
          []
        end
        periodical = if meta.fetch("T2", nil).present?
          { "type" => "Periodical",
            "title" => meta.fetch("T2", nil), 
            "id" => meta.fetch("SN", nil) }.compact
        else
          nil
        end
        state = doi.present? ? "findable" : "not_found"

        { "id" => normalize_doi(doi),
          "type" => type,
          "citeproc_type" => RIS_TO_CP_TRANSLATIONS[type] || "misc",
          "ris_type" => ris_type,
          "resource_type_general" => Metadata::SO_TO_DC_TRANSLATIONS[type],
          "doi" => doi,
          "b_url" => meta.fetch("UR", nil),
          "title" => meta.fetch("T1", nil),
          "creator" => get_authors(author),
          "publisher" => meta.fetch("PB", "(:unav)"),
          "periodical" => periodical,
          "related_identifiers" => related_identifiers,
          "date_created" => meta.fetch("Y1", nil),
          "date_published" => date_published,
          "date_accessed" => meta.fetch("Y2", nil),
          "description" => meta.fetch("AB", nil).present? ? { "text" => sanitize(meta.fetch("AB")) } : nil,
          "volume" => meta.fetch("VL", nil),
          "issue" => meta.fetch("IS", nil),
          "first_page" => meta.fetch("SP", nil),
          "last_page" => meta.fetch("EP", nil),
          "keywords" => meta.fetch("KW", nil),
          "language" => meta.fetch("LA", nil),
          "state" => state
        }
      end

      def ris_meta(string: nil)
        h = Hash.new { |h,k| h[k] = [] }
        string.split("\n").reduce(h) do |sum, line|
          k, v = line.split("-")
          h[k.strip] << v.to_s.strip
          sum
        end.map { |k,v| [k, v.unwrap] }.to_h.compact
      end
    end
  end
end
