# frozen_string_literal: true

module Bolognese
  module Readers
    module DataciteReader
      def get_datacite(id: nil, **options)
        return { "string" => nil, "state" => "not_found" } unless id.present?

        search_url = doi_search(id, options)
        doi = doi_from_url(id)
        params = { q: "doi:#{doi}",
                   fl: "doi,url,xml,state,allocator_symbol,datacentre_symbol,media,minted,updated",
                   wt: "json" }
        search_url += "?" + URI.encode_www_form(params)

        response = Maremma.get search_url
        attributes = response.body.dig("data", "response", "docs").first
        return { "string" => nil, "state" => "not_found" } unless attributes.present?

        string = attributes.fetch('xml', nil)
        string = Base64.decode64(string) if string.present?

        if string.present?
          doc = Nokogiri::XML(string, nil, 'UTF-8', &:noblanks)

          # remove leading and trailing whitespace in text nodes
          doc.xpath("//text()").each do |node|
            if node.content =~ /\S/
              node.content = node.content.strip
            else
              node.remove
            end
          end
          string = doc.to_xml(:indent => 2)
        end

        content_url = Array.wrap(attributes.fetch("media", nil)).map do |media|
          media.split(":", 2).last
        end.compact

        { "string" => string,
          "b_url" => attributes.fetch("url", nil),
          "state" => attributes.fetch("state", nil),
          "date_registered" => attributes.fetch("minted", nil),
          "date_updated" => attributes.fetch("updated", nil),
          "provider_id" => attributes.fetch("allocator_symbol", nil),
          "client_id" => attributes.fetch("datacentre_symbol", nil),
          "content_url" => content_url }
      end

      def read_datacite(string: nil, **options)
        doc = Nokogiri::XML(string, nil, 'UTF-8', &:noblanks)
        ns = doc.collect_namespaces.find { |k, v| v.start_with?("http://datacite.org/schema/kernel") }
        schema_version = Array.wrap(ns).last || "http://datacite.org/schema/kernel-4"
        doc.remove_namespaces!
        string = doc.to_xml(:indent => 2)
        
        meta = Maremma.from_xml(string).to_h.fetch("resource", {})

        # validate only when option is set, as this step is expensive and
        # not needed if XML comes from DataCite MDS
        if options[:validate]
          errors = datacite_errors(xml: string, schema_version: schema_version)
          return { "errors" => errors } if errors.present?
        end

        if options[:doi]
          id = normalize_doi(options[:doi], sandbox: options[:sandbox])
        else
          id = normalize_doi(meta.dig("identifier", "__content__") || options[:id], sandbox: options[:sandbox])
        end

        doi = doi_from_url(id)
        resource_type_general = meta.dig("resourceType", "resourceTypeGeneral")
        additional_type = meta.fetch("resourceType", {}).fetch("__content__", nil)
        type = Bolognese::Utils::CR_TO_SO_TRANSLATIONS[additional_type.to_s.underscore.camelcase] || Bolognese::Utils::DC_TO_SO_TRANSLATIONS[resource_type_general.to_s.dasherize] || "CreativeWork"
        title = Array.wrap(meta.dig("titles", "title")).map do |r|
          if r.is_a?(String)
            sanitize(r)
          else
            { "title_type" => r["titleType"], "lang" => r["lang"], "text" => sanitize(r["__content__"]) }.compact
          end
        end.unwrap

        container_title = Array.wrap(meta.dig("descriptions", "description")).find { |r| r["descriptionType"] == "SeriesInformation" }.to_h.fetch("__content__", nil)

        alternate_identifier = Array.wrap(meta.dig("alternateIdentifiers", "alternateIdentifier")).map do |r|
          { "type" => r["alternateIdentifierType"], "name" => r["__content__"] }
        end.unwrap
        description = Array.wrap(meta.dig("descriptions", "description")).select { |r| r["descriptionType"] != "SeriesInformation" }.map do |r|
          { "type" => r["descriptionType"], "text" => sanitize(r["__content__"]) }.compact
        end.unwrap
        license = Array.wrap(meta.dig("rightsList", "rights")).map do |r|
          { "id" => normalize_url(r["rightsURI"]), "name" => r["__content__"] }.compact
        end.unwrap
        keywords = Array.wrap(meta.dig("subjects", "subject")).map do |k|
          if k.nil?
            nil
          elsif k.is_a?(String)
            sanitize(k)
          else
            { "subject_scheme" => k["subjectScheme"], "scheme_uri" => k["schemeURI"], "text" => sanitize(k["__content__"]) }.compact
          end
        end.compact
        dates = Array.wrap(meta.dig("dates", "date"))
        sizes = Array.wrap(meta.dig("sizes", "size")).unwrap
        formats = Array.wrap(meta.dig("formats", "format")).unwrap
        funding = begin
          f = datacite_funder_contributor(meta) + datacite_funding_reference(meta)
          f.length > 1 ? f : f.first
        end
        state = doi.present? ? "findable" : "not_found"

        { "id" => id,
          "type" => type,
          "additional_type" => additional_type,
          "citeproc_type" => Bolognese::Utils::CR_TO_CP_TRANSLATIONS[additional_type.to_s.underscore.camelcase] || Bolognese::Utils::SO_TO_CP_TRANSLATIONS[type] || "article",
          "bibtex_type" => Bolognese::Utils::CR_TO_BIB_TRANSLATIONS[additional_type.to_s.underscore.camelcase] || Bolognese::Utils::SO_TO_BIB_TRANSLATIONS[type] || "misc",
          "ris_type" => Bolognese::Utils::CR_TO_RIS_TRANSLATIONS[additional_type.to_s.underscore.camelcase] || Bolognese::Utils::DC_TO_RIS_TRANSLATIONS[resource_type_general.to_s.dasherize] || "GEN",
          "resource_type_general" => resource_type_general,
          "doi" => doi,
          "alternate_identifier" => alternate_identifier,
          "url" => options.fetch(:url, nil),
          "title" => title,
          "author" => get_authors(Array.wrap(meta.dig("creators", "creator"))),
          "editor" => get_authors(Array.wrap(meta.dig("contributors", "contributor")).select { |r| r["contributorType"] == "Editor" }),
          "container_title" => container_title,
          "publisher" => meta.fetch("publisher", nil),
          "service_provider" => "DataCite",
          "funding" => funding,
          "is_identical_to" => datacite_is_identical_to(meta),
          "is_part_of" => datacite_is_part_of(meta),
          "has_part" => datacite_has_part(meta),
          "references" => datacite_references(meta),
          "is_referenced_by" => datacite_is_referenced_by(meta),
          "is_supplement_to" => datacite_is_supplement_to(meta),
          "is_supplemented_by" => datacite_is_supplemented_by(meta),
          "date_created" => datacite_date(dates, "Created"),
          "date_accepted" => datacite_date(dates, "Accepted"),
          "date_available" => datacite_date(dates, "Available"),
          "date_copyrighted" => datacite_date(dates, "Copyrights"),
          "date_collected" => datacite_date(dates, "Collected"),
          "date_submitted" => datacite_date(dates, "Submitted"),
          "date_valid" => datacite_date(dates, "Valid"),
          "date_published" => datacite_date(dates, "Issued") || meta.fetch("publicationYear", nil),
          "date_modified" => datacite_date(dates, "Updated"),
          "description" => description,
          "license" => license,
          "b_version" => meta.fetch("version", nil),
          "keywords" => keywords,
          "language" => meta.fetch("language", nil),
          "content_format" => formats,
          "content_size" => sizes,
          "schema_version" => schema_version,
          "state" => state
        }
      end

      def datacite_date(dates, date_type)
        dd = dates.find { |d| d["dateType"] == date_type } || {}
        dd.fetch("__content__", nil)
      end

      def datacite_funding_reference(meta)
        Array.wrap(meta.dig("fundingReferences", "fundingReference")).compact.map do |f|
          funder_id = parse_attributes(f["funderIdentifier"])
          funder = { "type" => "Organization",
                     "id" => normalize_id(funder_id),
                     "name" => f["funderName"] }.compact
          if f["awardNumber"].present? || f["awardTitle"].present?
            { "type" => "Award",
              "name" => f.fetch("awardTitle", nil),
              "identifier" => f["awardNumber"].is_a?(Hash) ? f.dig("awardNumber", "__content__") : f["awardNumber"],
              "url" => f["awardNumber"].is_a?(Hash) ? f.dig("awardNumber", "awardURI") : nil,
              "funder" => funder }.compact
          else
            funder
          end
        end.uniq
      end

      def datacite_funder_contributor(meta)
        Array.wrap(meta.dig("contributors", "contributor")).reduce([]) do |sum, f|
          if f["contributorType"] == "Funder"
            # handle special case of OpenAIRE metadata
            id = f.dig("nameIdentifier", "__content__").to_s.start_with?("info:eu-repo/grantAgreement/EC") ? "https://doi.org/10.13039/501100000780" : nil

            funder = { "type" => "Organization",
                       "id" => id,
                       "name" => f["contributorName"] }.compact
            if f.dig("nameIdentifier", "nameIdentifierScheme") == "info"
              sum << { "type" => "Award",
                       "identifier" => f.dig("nameIdentifier", "__content__").split("/").last,
                       "funder" => funder }
            else
              sum << funder
            end
          else
            sum
          end
        end
      end

      def datacite_related_identifier(meta, relation_type: nil)
        arr = Array.wrap(meta.dig("relatedIdentifiers", "relatedIdentifier")).select { |r| %w(DOI URL).include?(r["relatedIdentifierType"]) }
        arr = arr.select { |r| relation_type.split(" ").include?(r["relationType"]) } if relation_type.present?

        arr.map { |work| { "type" => "CreativeWork", "id" => normalize_id(work["__content__"]) } }.unwrap
      end

      def datacite_is_identical_to(meta)
        datacite_related_identifier(meta, relation_type: "IsIdenticalTo")
      end

      def datacite_is_part_of(meta)
        datacite_related_identifier(meta, relation_type: "IsPartOf")
      end

      def datacite_has_part(meta)
        datacite_related_identifier(meta, relation_type: "HasPart")
      end

      def datacite_is_previous_version_of(meta)
        datacite_related_identifier(meta, relation_type: "IsPreviousVersionOf")
      end

      def datacite_is_new_version_of(meta)
        datacite_related_identifier(meta, relation_type: "IsNewVersionOf")
      end

      def datacite_is_variant_form_of(meta)
        datacite_related_identifier(meta, relation_type: "IsVariantFormOf")
      end

      def datacite_is_original_form_of(meta)
        datacite_related_identifier(meta, relation_type: "IsOriginalFormOf")
      end

      def datacite_references(meta)
        datacite_related_identifier(meta, relation_type: "References Cites").presence
      end

      def datacite_is_referenced_by(meta)
        datacite_related_identifier(meta, relation_type: "IsCitedBy IsReferencedBy").presence
      end

      def datacite_is_supplement_to(meta)
        datacite_related_identifier(meta, relation_type: "IsSupplementTo")
      end

      def datacite_is_supplemented_by(meta)
        datacite_related_identifier(meta, relation_type: "isSupplementedBy")
      end

      def datacite_reviews(meta)
        datacite_related_identifier(meta, relation_type: "Reviews").presence
      end

      def datacite_is_reviewed_by(meta)
        datacite_related_identifier(meta, relation_type: "IsReviewedBy").presence
      end
    end
  end
end
