module Bolognese
  module Readers
    module CrossrefReader
      # CrossRef types from https://api.crossref.org/types
      CR_TO_SO_TRANSLATIONS = {
        "Proceedings" => nil,
        "ReferenceBook" => "Book",
        "JournalIssue" => "PublicationIssue",
        "ProceedingsArticle" => nil,
        "Other" => "CreativeWork",
        "Dissertation" => "Thesis",
        "Dataset" => "Dataset",
        "EditedBook" => "Book",
        "JournalArticle" => "ScholarlyArticle",
        "Journal" => nil,
        "Report" => nil,
        "BookSeries" => nil,
        "ReportSeries" => nil,
        "BookTrack" => nil,
        "Standard" => nil,
        "BookSection" => nil,
        "BookPart" => nil,
        "Book" => "Book",
        "BookChapter" => "Chapter",
        "StandardSeries" => nil,
        "Monograph" => "Book",
        "Component" => "CreativeWork",
        "ReferenceEntry" => nil,
        "JournalVolume" => "PublicationVolume",
        "BookSet" => nil,
        "PostedContent" => "ScholarlyArticle"
      }

      CR_TO_BIB_TRANSLATIONS = {
        "Proceedings" => "proceedings",
        "ReferenceBook" => "book",
        "JournalIssue" => nil,
        "ProceedingsArticle" => nil,
        "Other" => nil,
        "Dissertation" => "phdthesis",
        "Dataset" => nil,
        "EditedBook" => "book",
        "JournalArticle" => "article",
        "Journal" => nil,
        "Report" => nil,
        "BookSeries" => nil,
        "ReportSeries" => nil,
        "BookTrack" => nil,
        "Standard" => nil,
        "BookSection" => "inbook",
        "BookPart" => nil,
        "Book" => "book",
        "BookChapter" => "inbook",
        "StandardSeries" => nil,
        "Monograph" => "book",
        "Component" => nil,
        "ReferenceEntry" => nil,
        "JournalVolume" => nil,
        "BookSet" => nil,
        "PostedContent" => "article"
      }

      CONTACT_EMAIL = "tech@datacite.org"

      def get_crossref(id: nil)
        return nil unless id.present?

        doi = doi_from_url(id)
        url = "http://www.crossref.org/openurl/?id=doi:#{doi}&noredirect=true&pid=#{CONTACT_EMAIL}&format=unixref"
        response = Maremma.get(url, accept: "text/xml", raw: true)
        string = response.body.fetch("data", nil)
        Nokogiri::XML(string, nil, 'UTF-8', &:noblanks).to_s if string.present?
      end

      def read_crossref(string: nil)
        if string.present?
          m = Maremma.from_xml(string).dig("doi_records", "doi_record") || {}
          meta = m.dig("crossref", "error").nil? ? m : {}
        else
          meta = {}
        end

        return meta unless meta["crossref"].present?

        journal_metadata = meta.dig("crossref", "journal", "journal_metadata").presence || {}
        bibliographic_metadata = meta.dig("crossref", "journal", "journal_article").presence ||
                                 meta.dig("crossref", "conference", "conference_paper").presence ||
                                 meta.dig("crossref", meta.fetch("crossref", {}).keys.last).presence || {}
        program_metadata = bibliographic_metadata.dig("program") ||
                           bibliographic_metadata.dig("crossmark", "custom_metadata", "program") || {}
        journal_issue = meta.dig("crossref", "journal", "journal_issue").presence || {}

        additional_type = if meta.dig("crossref", "journal").present?
                            meta.dig("crossref", "journal").keys.last.camelize
                          else
                            meta.dig("crossref").keys.last.camelize
                          end
        type = CR_TO_SO_TRANSLATIONS[additional_type] || "ScholarlyArticle"
        doi = bibliographic_metadata.dig("doi_data", "doi")

        { "id" => normalize_doi(doi),
          "type" => type,
          "additional_type" => additional_type,
          "citeproc_type" => Bolognese::Utils::CR_TO_CP_TRANSLATIONS[additional_type] || "article-journal",
          "bibtex_type" => CR_TO_BIB_TRANSLATIONS[additional_type] || "misc",
          "ris_type" => Bolognese::Utils::CR_TO_RIS_TRANSLATIONS[additional_type] || "JOUR",
          "resource_type_general" => Bolognese::Utils::SO_TO_DC_TRANSLATIONS[type],
          "doi" => doi,
          "url" => bibliographic_metadata.dig("doi_data", "resource"),
          "title" => parse_attributes(bibliographic_metadata.dig("titles", "title")),
          "alternate_name" => crossref_alternate_name(bibliographic_metadata),
          "author" => crossref_people(bibliographic_metadata, "author"),
          "editor" => crossref_people(bibliographic_metadata, "editor"),
          "funder" => crossref_funder(program_metadata),
          "publisher" => nil,
          "provider" => "Crossref",
          "is_part_of" => crossref_is_part_of(journal_metadata),
          "references" => crossref_references(bibliographic_metadata),
          "date_published" => crossref_date_published(bibliographic_metadata),
          "date_modified" => Time.parse(meta.fetch("timestamp", "")).utc.iso8601,
          "volume" => journal_issue.dig("journal_volume", "volume"),
          "issue" => journal_issue.dig("issue"),
          "pagination" => [bibliographic_metadata.dig("pages", "first_page"), bibliographic_metadata.dig("pages", "last_page")].compact.join("-").presence,
          "description" => crossref_description(bibliographic_metadata),
          "license" => crossref_license(program_metadata),
          "version" => nil,
          "keywords" => nil,
          "language" => nil,
          "content_size" => nil,
          "schema_version" => nil
        }
      end

      def crossref_alternate_name(bibliographic_metadata)
        if bibliographic_metadata.fetch("publisher_item", nil).present?
          parse_attributes(bibliographic_metadata.dig("publisher_item", "item_number"))
        else
          parse_attributes(bibliographic_metadata.fetch("item_number", nil))
        end
      end

      def crossref_description(bibliographic_metadata)
        des = bibliographic_metadata.fetch("abstract", {}).values.first
        if des.is_a?(Hash)
          des.to_xml
        elsif des.is_a?(String)
          des
        end
      end

      def crossref_license(program_metadata)
        access_indicator = Array.wrap(program_metadata).find { |m| m["name"] == "AccessIndicators" }
        if access_indicator.present?
          { "id" => normalize_url(parse_attributes(access_indicator["license_ref"])) }
        else
          nil
        end
      end

      def crossref_people(bibliographic_metadata, contributor_role)
        person = bibliographic_metadata.dig("contributors", "person_name")
        Array.wrap(person).select { |a| a["contributor_role"] == contributor_role }.map do |a|
          { "type" => "Person",
            "id" => parse_attributes(a["ORCID"]),
            "name" => [a["given_name"], a["surname"]].join(" "),
            "givenName" => a["given_name"],
            "familyName" => a["surname"] }.compact
        end.unwrap
      end

      def crossref_funder(program_metadata)
        fundref = Array.wrap(program_metadata).find { |a| a["name"] == "fundref" } || {}
        Array.wrap(fundref.fetch("assertion", [])).select { |a| a["name"] == "fundgroup" }.map do |f|
          f = Array.wrap(f.fetch("assertion", nil)).first
          { "id" => normalize_id(f.dig("assertion", "__content__")),
            "name" => f.dig("__content__").strip }.compact
        end.unwrap
      end

      def crossref_date_published(bibliographic_metadata)
        pub_date = Array.wrap(bibliographic_metadata.fetch("publication_date", nil)).presence ||
          Array.wrap(bibliographic_metadata.fetch("acceptance_date", nil))
        if pub_date.present?
          get_date_from_parts(pub_date.first["year"], pub_date.first["month"], pub_date.first["day"])
        else
          nil
        end
      end

      def crossref_is_part_of(journal_metadata)
        if journal_metadata.present?
          { "type" => "Periodical",
            "name" => journal_metadata["full_title"],
            "issn" => parse_attributes(journal_metadata.fetch("issn", nil)) }.compact
        else
          nil
        end
      end

      def crossref_references(bibliographic_metadata)
         refs = bibliographic_metadata.dig("citation_list", "citation")
         Array.wrap(refs).select { |a| a["doi"].present? }.map do |c|
           { "id" => normalize_id(c["doi"]),
             "type" => "CreativeWork" }.compact
         end.unwrap
      end
    end
  end
end
