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
        read_options = ActiveSupport::HashWithIndifferentAccess.new(options.except(:string, :sandbox))

        meta = ris_meta(string: string)

        ris_type = meta.fetch("TY", nil) || "GEN"
        schema_org = RIS_TO_SO_TRANSLATIONS[ris_type] || "CreativeWork"
        types = {
          "resourceTypeGeneral" => Metadata::SO_TO_DC_TRANSLATIONS[schema_org],
          "schemaOrg" => schema_org,
          "citeproc" => RIS_TO_CP_TRANSLATIONS[schema_org] || "misc",
          "ris" => ris_type
        }.compact

        doi = validate_doi(meta.fetch("DO", nil))
        author = Array.wrap(meta.fetch("AU", nil)).map { |a| { "name" => a } }
        date_parts = meta.fetch("PY", nil).to_s.split("/")
        created_date_parts = meta.fetch("Y1", nil).to_s.split("/")
        dates = []
        dates << { "date" => get_date_from_parts(*date_parts), "dateType" => "Issued" } if meta.fetch("PY", nil).present?
        dates << { "date" => get_date_from_parts(*created_date_parts), "dateType" => "Created" } if meta.fetch("Y1", nil).present?
        publication_year = get_date_from_parts(*date_parts).to_s[0..3]
        related_identifiers = if meta.fetch("T2", nil).present? && meta.fetch("SN", nil).present?
          [{ "type" => "Periodical",
             "id" => meta.fetch("SN", nil),
             "relatedIdentifierType" => "ISSN",
             "relationType" => "IsPartOf",
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
        state = doi.present? || read_options.present? ? "findable" : "not_found"
        subjects = Array.wrap(meta.fetch("KW", nil)).map do |s|
          { "subject" => s }
        end

        { "id" => normalize_doi(doi),
          "types" => types,
          "doi" => doi,
          "url" => meta.fetch("UR", nil),
          "titles" => meta.fetch("T1", nil).present? ? [{ "title" => meta.fetch("T1", nil) }] : nil,
          "creator" => get_authors(author),
          "publisher" => meta.fetch("PB", "(:unav)"),
          "periodical" => periodical,
          "related_identifiers" => related_identifiers,
          "dates" => dates,
          "publication_year" => publication_year,
          "descriptions" => meta.fetch("AB", nil).present? ? [{ "description" => sanitize(meta.fetch("AB")), "descriptionType" => "Abstract" }] : nil,
          "volume" => meta.fetch("VL", nil),
          "issue" => meta.fetch("IS", nil),
          "first_page" => meta.fetch("SP", nil),
          "last_page" => meta.fetch("EP", nil),
          "subjects" => subjects,
          "language" => meta.fetch("LA", nil),
          "state" => state
        }.merge(read_options)
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
