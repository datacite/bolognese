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

      def get_crossref(id: nil, **options)
        return nil unless id.present?

        doi = doi_from_url(id)
        url = "http://www.crossref.org/openurl/?id=doi:#{doi}&noredirect=true&pid=#{CONTACT_EMAIL}&format=unixref"
        response = Maremma.get(url, accept: "text/xml", raw: true)
        string = response.body.fetch("data", nil)
        string = Nokogiri::XML(string, nil, 'UTF-8', &:noblanks).to_s if string.present?

        { "string" => string }
      end

      def read_crossref(string: nil, **options)
        if string.present?
          m = Maremma.from_xml(string).dig("doi_records", "doi_record") || {}
          meta = m.dig("crossref", "error").nil? ? m : {}
        else
          meta = {}
        end

        return meta unless meta["crossref"].present?

        # model should be one of book, conference, database, dissertation, journal, peer_review, posted_content,
        # report-paper, sa_component, standard
        model = meta.dig("crossref").keys.first

        additional_type = nil
        program_metadata = {}
        journal_metadata = nil
        journal_issue = {}
        publisher = nil

        case model
        when "book"
          book_metadata = meta.dig("crossref", "book", "book_metadata")
          book_series_metadata = meta.dig("crossref", "book", "book_series_metadata")
          book_set_metadata = meta.dig("crossref", "book", "book_set_metadata")
          bibliographic_metadata = meta.dig("crossref", "book", "content_item") || {}
          additional_type = bibliographic_metadata.fetch("component_type", nil) ? "book-" + bibliographic_metadata.fetch("component_type") : "book"
          publisher = book_metadata.dig("publisher", "publisher_name")
        when "conference"
          event_metadata = meta.dig("crossref", "conference", "event_metadata") || {}
          bibliographic_metadata = meta.dig("crossref", "conference", "conference_paper") || {}
        when "journal"
          journal_metadata = meta.dig("crossref", "journal", "journal_metadata") || {}
          bibliographic_metadata = meta.dig("crossref", "journal", "journal_article") || {}
          program_metadata = bibliographic_metadata.dig("crossmark", "custom_metadata", "program") || bibliographic_metadata.dig("program")
          journal_issue = meta.dig("crossref", "journal", "journal_issue") || {}
          journal_article = meta.dig("crossref", "journal", "journal_article") || {}

          additional_type = if journal_article.present?
                              "journal_article"
                            elsif journal_issue.present?
                              "journal_issue"
                            else
                              "journal"
                            end
        when "posted_content"
          bibliographic_metadata = meta.dig("crossref", "posted_content") || {}
        when "sa_component"
          bibliographic_metadata = meta.dig("crossref", "sa_component", "component_list", "component") || {}
        end

        additional_type = (additional_type || model).underscore.camelize
        type = CR_TO_SO_TRANSLATIONS[additional_type] || "ScholarlyArticle"
        doi = bibliographic_metadata.dig("doi_data", "doi").to_s.downcase

        # Crossref servers run on Eastern Time
        Time.zone = 'Eastern Time (US & Canada)'
        date_modified = Time.zone.parse(meta.fetch("timestamp", "")).utc.iso8601

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
          "funding" => crossref_funding_reference(program_metadata),
          "publisher" => publisher,
          "provider" => "Crossref",
          "is_part_of" => crossref_is_part_of(journal_metadata),
          "references" => crossref_references(bibliographic_metadata),
          "date_published" => crossref_date_published(bibliographic_metadata),
          "date_modified" => date_modified,
          "volume" => journal_issue.dig("journal_volume", "volume"),
          "issue" => journal_issue.dig("issue"),
          "first_page" => bibliographic_metadata.dig("pages", "first_page"),
          "last_page" => bibliographic_metadata.dig("pages", "last_page"),
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
        abstract = Array.wrap(bibliographic_metadata.dig("abstract")).map do |r|
          { "type" => "Abstract", "text" => sanitize(parse_attributes(r, content: 'p')) }.compact
        end

        description = Array.wrap(bibliographic_metadata.dig("description")).map do |r|
          if abstract.present?
            { "text" => sanitize(parse_attributes(r)) }.compact
          else
            sanitize(parse_attributes(r))
          end
        end

        (abstract + description).unwrap
      end

      def crossref_license(program_metadata)
        access_indicator = Array.wrap(program_metadata).find { |m| m["name"] == "AccessIndicators" }
        if access_indicator.present?
          Array.wrap(access_indicator["license_ref"]).map do |license|
            { "id" => normalize_url(parse_attributes(license)) }
          end.uniq.unwrap
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

      def crossref_funding_reference(program_metadata)
        fundref = Array.wrap(program_metadata).find { |a| a["name"] == "fundref" } || {}
        Array.wrap(fundref.fetch("assertion", [])).select { |a| a["name"] == "fundgroup" }.map do |f|
          f = Array.wrap(f.fetch("assertion", nil)).first
          funder = { "type" => "Organization",
                     "id" => normalize_id(f.dig("assertion", "__content__")),
                     "name" => f.dig("__content__").strip }.compact
           if f["awardNumber"].present? || f["awardTitle"].present?
             { "type" => "Award",
               "name" => f.fetch("awardTitle", nil),
               "identifier" => f.dig("awardNumber", "__content__"),
               "url" => f.dig("awardNumber", "awardURI"),
               "funder" => funder }
           else
             funder
           end
        end.unwrap
      end

      # def datacite_funding_reference(meta)
      #   Array.wrap(meta.dig("fundingReferences", "fundingReference")).map do |f|
      #     funder_id = parse_attributes(f["funderIdentifier"])
      #     funder = { "type" => "Organization",
      #                "id" => normalize_id(funder_id),
      #                "name" => f["funderName"] }.compact
      #     if f["awardNumber"].present? || f["awardTitle"].present?
      #       { "type" => "Award",
      #         "name" => f.fetch("awardTitle", nil),
      #         "identifier" => f.dig("awardNumber", "__content__"),
      #         "url" => f.dig("awardNumber", "awardURI"),
      #         "funder" => funder }
      #     else
      #       funder
      #     end
      #   end.uniq
      # end

      def crossref_date_published(bibliographic_metadata)
        pub_date = Array.wrap(bibliographic_metadata.fetch("publication_date", nil)).presence ||
          Array.wrap(bibliographic_metadata.fetch("acceptance_date", nil))
        if pub_date.present?
          get_date_from_parts(pub_date.first["year"], pub_date.first["month"], pub_date.first["day"])
        else
          nil
        end
      end

      def crossref_is_part_of(model_metadata)
        if model_metadata.present?
          { "type" => "Periodical",
            "title" => model_metadata["full_title"],
            "issn" => parse_attributes(model_metadata.fetch("issn", nil), first: true) }.compact
        else
          nil
        end
      end

      def crossref_references(bibliographic_metadata)
         refs = bibliographic_metadata.dig("citation_list", "citation")
         Array.wrap(refs).select { |a| a["doi"].present? }.map do |c|
           { "type" => "CreativeWork",
             "id" => normalize_id(parse_attributes(c["doi"])),
             "title" => c["article_title"] }.compact
         end.unwrap
      end
    end
  end
end
