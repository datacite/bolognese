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
          "url" => attributes.fetch("url", nil),
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

        alternate_identifiers = Array.wrap(meta.dig("alternateIdentifiers", "alternateIdentifier")).map do |r|
          { "type" => r["alternateIdentifierType"], "name" => r["__content__"] }
        end.unwrap
        description = Array.wrap(meta.dig("descriptions", "description")).select { |r| r["descriptionType"] != "SeriesInformation" }.map do |r|
          { "type" => r["descriptionType"], "text" => sanitize(r["__content__"]) }.compact
        end.unwrap
        rights = Array.wrap(meta.dig("rightsList", "rights")).map do |r|
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
        dates = Array.wrap(meta.dig("dates", "date")).map do |d|
          {
            "date" => parse_attributes(d),
            "date_type" => parse_attributes(d, content: "dateType")
          }
        end
        dates << { "date" => meta.fetch("publicationYear", nil), "date_type" => "Issued" } if meta.fetch("publicationYear", nil).present? && get_date(dates, "Issued").blank?
        sizes = Array.wrap(meta.dig("sizes", "size")).unwrap
        formats = Array.wrap(meta.dig("formats", "format")).unwrap
        funding_references = Array.wrap(meta.dig("fundingReferences", "fundingReference")).compact.map do |fr|
          {
            "funder_name" => fr["funderName"],
            "funder_identifier" => normalize_id(parse_attributes(fr["funderIdentifier"])),
            "funder_identifier_type" => parse_attributes(fr["funderIdentifier"], content: "funderIdentifierType"),
            "award_number" => parse_attributes(fr["awardNumber"]),
            "award_uri" => parse_attributes(fr["awardNumber"], content: "awardURI"),
            "award_title" => fr["awardTitle"] }.compact
        end
        related_identifiers = Array.wrap(meta.dig("relatedIdentifiers", "relatedIdentifier")).map do |ri|
          if ri["relatedIdentifierType"] == "DOI"
            rid = ri["__content__"].downcase
          else
            rid = ri["__content__"]
          end

          { 
            "id" => rid,
            "related_identifier_type" => ri["relatedIdentifierType"],
            "relation_type" => ri["relationType"],
            "resource_type_general" => ri["resourceTypeGeneral"]
          }.compact
        end
        geo_location = Array.wrap(meta.dig("geoLocations", "geoLocation")).map do |gl|
          if gl["geoLocationPoint"].is_a?(String) || gl["geoLocationBox"].is_a?(String)
            nil
          else
            {
              "geo_location_place" => gl["geoLocationPlace"],
              "geo_location_point" => {
                "point_latitude" => gl.dig("geoLocationPoint", "pointLatitude"),
                "point_longitude" => gl.dig("geoLocationPoint", "pointLongitude")
              }.compact.presence,
              "geo_location_box" => {
                "west_bound_longitude" => gl.dig("geoLocationBox", "westBoundLongitude"),
                "east_bound_longitude" => gl.dig("geoLocationBox", "eastBoundLongitude"),
                "south_bound_latitude" => gl.dig("geoLocationBox", "southBoundLatitude"),
                "north_bound_latitude" => gl.dig("geoLocationBox", "northBoundLatitude")
              }.compact.presence
            }.compact
          end
        end
        periodical = set_periodical(meta)
        state = doi.present? ? "findable" : "not_found"

        { "id" => id,
          "type" => type,
          "additional_type" => additional_type,
          "citeproc_type" => Bolognese::Utils::CR_TO_CP_TRANSLATIONS[additional_type.to_s.underscore.camelcase] || Bolognese::Utils::SO_TO_CP_TRANSLATIONS[type] || "article",
          "bibtex_type" => Bolognese::Utils::CR_TO_BIB_TRANSLATIONS[additional_type.to_s.underscore.camelcase] || Bolognese::Utils::SO_TO_BIB_TRANSLATIONS[type] || "misc",
          "ris_type" => Bolognese::Utils::CR_TO_RIS_TRANSLATIONS[additional_type.to_s.underscore.camelcase] || Bolognese::Utils::DC_TO_RIS_TRANSLATIONS[resource_type_general.to_s.dasherize] || "GEN",
          "resource_type_general" => resource_type_general,
          "doi" => doi,
          "alternate_identifiers" => alternate_identifiers,
          "url" => options.fetch(:url, nil),
          "title" => title,
          "creator" => get_authors(Array.wrap(meta.dig("creators", "creator"))),
          "periodical" => periodical,
          "publisher" => meta.fetch("publisher", "").strip.presence,
          "service_provider" => "DataCite",
          "funding_references" => funding_references,
          "dates" => dates,
          "publication_year" => meta.fetch("publicationYear", nil),
          "description" => description,
          "rights" => rights,
          "version" => meta.fetch("version", nil),
          "keywords" => keywords,
          "language" => meta.fetch("language", nil),
          "geo_location" => geo_location,
          "related_identifiers" => related_identifiers,
          "formats" => formats,
          "size" => sizes,
          "schema_version" => schema_version,
          "state" => state
        }
      end

      def set_periodical(meta)
        container_title = Array.wrap(meta.dig("descriptions", "description")).find { |r| r["descriptionType"] == "SeriesInformation" }.to_h.fetch("__content__", nil)
        is_part_of = Array.wrap(meta.dig("relatedIdentifiers", "relatedIdentifier")).find { |ri| ri["relationType"] == "IsPartOf" }.to_h

        if container_title.present? || is_part_of.present?
          {
            "type" => meta.dig("resourceType", "resourceTypeGeneral") == "Dataset" ? "DataCatalog" : "Periodical",
            "id" => is_part_of["relatedIdentifierType"] == "DOI" ? normalize_doi(is_part_of["__content__"]) : is_part_of["__content__"],
            "title" => container_title,
            "issn" => is_part_of["relatedIdentifierType"] == "ISSN" ? is_part_of["__content__"] : nil
          }.compact
        end
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
    end
  end
end
