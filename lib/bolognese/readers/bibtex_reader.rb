# frozen_string_literal: true

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
        read_options = ActiveSupport::HashWithIndifferentAccess.new(options.except(:doi, :id, :url, :sandbox, :validate, :ra))

        meta = string.present? ? BibTeX.parse(string).first : OpenStruct.new

        schema_org = BIB_TO_SO_TRANSLATIONS[meta.try(:type).to_s] || "ScholarlyArticle"
        types = {
          "resourceTypeGeneral" => Metadata::SO_TO_DC_TRANSLATIONS[schema_org],
          "resourceType" => Bolognese::Utils::BIB_TO_CR_TRANSLATIONS[meta.try(:type).to_s] || meta.try(:type).to_s,
          "schemaOrg" => schema_org,
          "bibtex" => meta.type.to_s,
          "citeproc" => BIB_TO_CP_TRANSLATIONS[meta.try(:type).to_s] || "misc",
          "ris" => BIB_TO_RIS_TRANSLATIONS[meta.try(:type).to_s] || "GEN"
        }.compact
        doi = meta.try(:doi).to_s.presence || options[:doi]

        creators = Array(meta.try(:author)).map do |a|
          { "nameType" => "Personal",
            "name" => [a.last, a.first].join(", "),
            "givenName" => a.first,
            "familyName" => a.last }.compact
        end

        related_identifiers = if meta.try(:journal).present? && meta.try(:issn).to_s.presence
                                [{ "type" => "Periodical",
                                  "relationType" => "IsPartOf",
                                  "relatedIdentifierType" => "ISSN",
                                  "title" => meta.journal.to_s,
                                  "relatedIdentifier" => meta.try(:issn).to_s.presence }.compact]
                              end

        container = if meta.try(:journal).present?
                      first_page = meta.try(:pages).present? ? meta.try(:pages).split("-").map(&:strip)[0] : nil
                      last_page = meta.try(:pages).present? ? meta.try(:pages).split("-").map(&:strip)[1] : nil
                      
                      { "type" => "Journal",
                        "title" => meta.journal.to_s,
                        "identifier" => meta.try(:issn).to_s.presence,
                        "identifierType" => meta.try(:issn).present? ? "ISSN" : nil,
                        "volume" => meta.try(:volume).to_s.presence,
                        "firstPage" => first_page,
                        "lastPage" => last_page }.compact
                    end

        state = meta.try(:doi).to_s.present? || read_options.present? ? "findable" : "not_found"
        dates = if meta.try(:date).present? && Date.edtf(meta.date.to_s).present?
                  [{ "date" => meta.date.to_s,
                    "dateType" => "Issued" }]
                end
        publication_year =  meta.try(:date).present? ? meta.date.to_s[0..3] : nil

        { "id" => normalize_doi(doi),
          "types" => types,
          "identifiers" => [{ "identifier" => normalize_doi(doi), "identifierType" => "DOI" }],
          "doi" => doi,
          "url" => meta.try(:url).to_s.presence,
          "titles" => meta.try(:title).present? ? [{ "title" => meta.try(:title).to_s }] : [],
          "creators" => creators,
          "container" => container,
          "publisher" => meta.try(:publisher).to_s.presence,
          "related_identifiers" => related_identifiers,
          "dates" => dates,
          "publication_year" => publication_year,
          "descriptions" => meta.try(:abstract).present? ? [{ "description" => meta.try(:abstract) && sanitize(meta.abstract.to_s).presence, "descriptionType" => "Abstract" }] : [],
          "rights_list" =>  meta.try(:copyright).present? ? [{ "rightsUri" => meta.try(:copyright).to_s.presence }.compact] : [],
          "state" => state
        }.merge(read_options)
      end
    end
  end
end
