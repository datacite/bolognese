module Bolognese
  module Readers
    module RisReader
      RIS_TO_SO_TRANSLATIONS = {
        "BLOG" => "BlogPosting",
        "GEN" => "CreativeWork",
        "CTLG" => "DataCatalog",
        "DATA" => "Dataset",
        "FIGURE" => "ImageObject",
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

      def read_ris(string: nil)
        meta = ris_meta(string: string)

        ris_type = meta.fetch("TY", nil) || "GEN"
        type = RIS_TO_SO_TRANSLATIONS[ris_type] || "CreativeWork"

        doi = meta.fetch("DO", nil)
        author = Array.wrap(meta.fetch("AU", nil)).map { |a| { "name" => a } }
        container_title = meta.fetch("T2", nil)
        is_part_of = if container_title.present?
                       { "type" => "Periodical",
                         "title" => container_title,
                         "issn" => meta.fetch("SN", nil) }.compact
                     else
                       nil
                     end

        { "id" => normalize_doi(doi),
          "type" => type,
          "citeproc_type" => RIS_TO_CP_TRANSLATIONS[type] || "misc",
          "ris_type" => ris_type,
          "resource_type_general" => Metadata::SO_TO_DC_TRANSLATIONS[type],
          "doi" => doi,
          "url" => meta.fetch("UR", nil),
          "title" => meta.fetch("T1", nil),
          "alternate_name" => meta.fetch("AN", nil),
          "author" => get_authors(author),
          "publisher" => meta.fetch("PB", nil),
          "is_part_of" => is_part_of,
          "date_created" => meta.fetch("Y1", nil),
          "date_published" => meta.fetch("PY", nil),
          "date_accessed" => meta.fetch("Y2", nil),
          "description" => meta.fetch("AB", nil).present? ? { "text" => sanitize(meta.fetch("AB")) } : nil,
          "volume" => meta.fetch("VL", nil),
          "issue" => meta.fetch("IS", nil),
          "pagination" => [meta.fetch("SP", nil), meta.fetch("EP", nil)].compact.join("-").presence,
          "keywords" => meta.fetch("KW", nil),
          "language" => meta.fetch("LA", nil)
        }
      end

      def ris_meta(string: nil)
        h = Hash.new { |h,k| h[k] = [] }
        string.split("\n").reduce(h) do |sum, line|
          k, v = line.split(" - ")
          h[k] << v
          sum
        end.map { |k,v| [k, v.unwrap] }.to_h.compact
      end
    end
  end
end
