# frozen_string_literal: true

module Bolognese
  module Readers
    module CrossrefReader
      # CrossRef types from https://api.crossref.org/types

      CONTACT_EMAIL = "tech@datacite.org"

      def get_crossref(id: nil, **options)
        return { "string" => nil, "state" => "not_found" } unless id.present?

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

        # model should be one of book, conference, database, dissertation, journal, peer_review, posted_content,
        # report-paper, sa_component, standard
        model = meta.dig("crossref").to_h.keys.first

        resource_type = nil
        bibliographic_metadata = {}
        program_metadata = {}
        journal_metadata = nil
        journal_issue = {}
        publisher = "(:unav)"

        case model
        when "book"
          book_metadata = meta.dig("crossref", "book", "book_metadata")
          book_series_metadata = meta.dig("crossref", "book", "book_series_metadata")
          book_set_metadata = meta.dig("crossref", "book", "book_set_metadata")
          bibliographic_metadata = meta.dig("crossref", "book", "content_item").to_h
          resource_type = bibliographic_metadata.fetch("component_type", nil) ? "book-" + bibliographic_metadata.fetch("component_type") : "book"
          publisher = book_metadata.dig("publisher", "publisher_name")
        when "conference"
          event_metadata = meta.dig("crossref", "conference", "event_metadata") || {}
          bibliographic_metadata = meta.dig("crossref", "conference", "conference_paper").to_h
        when "journal"
          journal_metadata = meta.dig("crossref", "journal", "journal_metadata") || {}
          bibliographic_metadata = meta.dig("crossref", "journal", "journal_article").to_h
          program_metadata = bibliographic_metadata.dig("crossmark", "custom_metadata", "program") || bibliographic_metadata.dig("program")
          journal_issue = meta.dig("crossref", "journal", "journal_issue") || {}
          journal_article = meta.dig("crossref", "journal", "journal_article") || {}

          resource_type = if journal_article.present?
                              "journal_article"
                            elsif journal_issue.present?
                              "journal_issue"
                            else
                              "journal"
                            end
        when "posted_content"
          bibliographic_metadata = meta.dig("crossref", "posted_content").to_h
          publisher = bibliographic_metadata.dig("institution", "institution_name")
        when "sa_component"
          bibliographic_metadata = meta.dig("crossref", "sa_component", "component_list", "component").to_h
        end

        resource_type = (resource_type || model).to_s.underscore.camelize.presence
        schema_org = Bolognese::Utils::CR_TO_SO_TRANSLATIONS[resource_type] || "ScholarlyArticle"
        types = {
          "resourceTypeGeneral" => Bolognese::Utils::SO_TO_DC_TRANSLATIONS[schema_org],
          "resourceType" => resource_type,
          "schemaOrg" => schema_org,
          "citeproc" => Bolognese::Utils::CR_TO_CP_TRANSLATIONS[resource_type] || "article-journal",
          "bibtex" => Bolognese::Utils::CR_TO_BIB_TRANSLATIONS[resource_type] || "misc",
          "ris" => Bolognese::Utils::CR_TO_RIS_TRANSLATIONS[resource_type] || "JOUR"
        }.compact
        doi = bibliographic_metadata.dig("doi_data", "doi").to_s.downcase.presence #|| doi_from_url(options[:id])

        # Crossref servers run on Eastern Time
        Time.zone = 'Eastern Time (US & Canada)'
        dates = [
          { "date" => crossref_date_published(bibliographic_metadata),
            "dateType" => "Issued" },
          { "date" => Time.zone.parse(meta.fetch("timestamp", "2018-01-01")).utc.iso8601,
            "dateType" => "Updated" }
        ]
        publication_year = crossref_date_published(bibliographic_metadata).present? ? crossref_date_published(bibliographic_metadata)[0..3] : nil
        state = meta.present? ? "findable" : "not_found"

        related_identifiers = Array.wrap(crossref_is_part_of(journal_metadata)) + Array.wrap(crossref_references(bibliographic_metadata))
        periodical = if journal_metadata.present?
            { "type" => "Periodical",
              "issn" => parse_attributes(journal_metadata.fetch("issn", nil), first: true),
              "title" => journal_metadata["full_title"] }.compact
        else
          nil
        end

        { "id" => normalize_doi(doi),
          "types" => types,
          "doi" => doi,
          "url" => bibliographic_metadata.dig("doi_data", "resource"),
          "titles" => [{ "title" => parse_attributes(bibliographic_metadata.dig("titles", "title")) }],
          "alternate_identifiers" => crossref_alternate_identifiers(bibliographic_metadata),
          "creator" => crossref_people(bibliographic_metadata, "author"),
          "contributor" => crossref_people(bibliographic_metadata, "editor"),
          "funding_references" => crossref_funding_reference(program_metadata),
          "publisher" => publisher,
          "periodical" => periodical,
          "source" => "Crossref",
          "related_identifiers" => related_identifiers,
          "dates" => dates,
          "publication_year" => publication_year,
          "volume" => journal_issue.dig("journal_volume", "volume"),
          "issue" => journal_issue.dig("issue"),
          "first_page" => bibliographic_metadata.dig("pages", "first_page"),
          "last_page" => bibliographic_metadata.dig("pages", "last_page"),
          "descriptions" => crossref_description(bibliographic_metadata),
          "rights_list" => crossref_license(program_metadata),
          "version" => nil,
          "subjects" => nil,
          "language" => nil,
          "sizes" => nil,
          "schema_version" => nil,
          "state" => state
        }
      end

      def crossref_alternate_identifiers(bibliographic_metadata)
        if bibliographic_metadata.fetch("publisher_item", nil).present?
          { "alternateIdentifier" => parse_attributes(bibliographic_metadata.dig("publisher_item", "item_number")),
            "alternateIdentifierType" => "Publisher ID" }
        else
          { "alternateIdentifier" => parse_attributes(bibliographic_metadata.fetch("item_number", nil)),
            "alternateIdentifierType" => "Publisher ID" }
        end
      end

      def crossref_description(bibliographic_metadata)
        abstract = Array.wrap(bibliographic_metadata.dig("abstract")).map do |r|
          { "descriptionType" => "Abstract", "description" => sanitize(parse_attributes(r, content: 'p')) }.compact
        end

        description = Array.wrap(bibliographic_metadata.dig("description")).map do |r|
          { "descriptionType" => "Other", "description" => sanitize(parse_attributes(r)) }.compact
        end

        (abstract + description)
      end

      def crossref_license(program_metadata)
        access_indicator = Array.wrap(program_metadata).find { |m| m["name"] == "AccessIndicators" }
        if access_indicator.present?
          Array.wrap(access_indicator["license_ref"]).map do |license|
            { "rightsUri" => normalize_url(parse_attributes(license)) }
          end.uniq
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
            "familyName" => a["surname"],
            "contributorType" => contributor_role == "editor" ? "Editor" : nil }.compact
        end.unwrap
      end

      def crossref_funding_reference(program_metadata)
        fundref = Array.wrap(program_metadata).find { |a| a["name"] == "fundref" } || {}
        Array.wrap(fundref.fetch("assertion", [])).select { |a| a["name"] == "fundgroup" }.map do |f|
          f = Array.wrap(f.fetch("assertion", nil)).first
          funder_identifier = normalize_id(f.dig("assertion", "__content__"))
          funder_identifier_type = funder_identifier.present? ?  "Crossref Funder ID" : nil
          award_title = f.fetch("awardTitle", nil).present? ? f.fetch("awardTitle") : nil

          { "funderIdentifier" => funder_identifier,
            "funderIdentifierType" => funder_identifier_type,
            "funderName" => f.fetch("__content__", nil).to_s.strip.presence,
            "awardTitle" => award_title,
            "awardNumber" => f.dig("awardNumber", "__content__"),
            "awardUri" => f.dig("awardNumber", "awardURI") }.compact
        end
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

      def crossref_is_part_of(model_metadata)
        if model_metadata.present? && model_metadata.fetch("issn", nil).present?
          { "relatedIdentifier" => parse_attributes(model_metadata.fetch("issn", nil), first: true),
            "relationType" => "IsPartOf",
            "relatedIdentifierType" => "ISSN",
            "resourceTypeGeneral" => "Collection" }.compact
        else
          nil
        end
      end

      def crossref_references(bibliographic_metadata)
        refs = bibliographic_metadata.dig("citation_list", "citation")
        Array.wrap(refs).select { |a| a["doi"].present? }.map do |c|
          if c["doi"].present?
            { "relatedIdentifier" => parse_attributes(c["doi"]).downcase,
              "relationType" => "References",
              "relatedIdentifierType" => "DOI" }.compact
          else
            nil
          end
        end.compact.unwrap
      end
    end
  end
end
