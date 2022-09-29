# frozen_string_literal: true

module Bolognese
  module Readers
    module DataciteReader
      def get_datacite(id: nil, **options)
        return { "string" => nil, "state" => "not_found" } unless id.present?

        api_url = doi_api_url(id, options)
        response = Maremma.get(api_url)
        attributes = response.body.dig("data", "attributes")
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

        client = Array.wrap(response.body.fetch("included", nil)).find { |m| m["type"] == "clients" }
        client_id = client.to_h.fetch("id", nil)
        provider_id = Array.wrap(client.to_h.fetch("relationships", nil)).find { |m| m["provider"].present? }.to_h.dig("provider", "data", "id")

        content_url = attributes.fetch("contentUrl", nil) || Array.wrap(response.body.fetch("included", nil)).select { |m| m["type"] == "media" }.map do |m|
          m.dig("attributes", "url")
        end.compact

        { "string" => string,
          "url" => attributes.fetch("url", nil),
          "state" => attributes.fetch("state", nil),
          "date_registered" => attributes.fetch("registered", nil),
          "date_updated" => attributes.fetch("updated", nil),
          "provider_id" => provider_id,
          "client_id" => client_id,
          "content_url" => content_url }
      end

      def read_datacite(string: nil, **options)
        read_options = ActiveSupport::HashWithIndifferentAccess.new(options.except(:doi, :id, :url, :sandbox, :validate, :ra))

        doc = Nokogiri::XML(string, nil, 'UTF-8', &:noblanks)
        if read_options.present?
          schema_version = "http://datacite.org/schema/kernel-4"
        else
          ns = doc.collect_namespaces.find { |k, v| v.start_with?("http://datacite.org/schema/kernel") }
          schema_version = Array.wrap(ns).last || "http://datacite.org/schema/kernel-4"
        end
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

        identifiers = Array.wrap(meta.dig("alternateIdentifiers", "alternateIdentifier")).map do |r|
          if r["__content__"].present?
            { "identifierType" => get_identifier_type(r["alternateIdentifierType"]), "identifier" => r["__content__"] }
          end
        end.compact

        resource_type_general = meta.dig("resourceType", "resourceTypeGeneral")
        resource_type = meta.dig("resourceType", "__content__")
        schema_org = Bolognese::Utils::CR_TO_SO_TRANSLATIONS[resource_type.to_s.underscore.camelcase] || Bolognese::Utils::DC_TO_SO_TRANSLATIONS[resource_type_general.to_s.dasherize] || "CreativeWork"
        types = {
          "resourceTypeGeneral" => resource_type_general,
          "resourceType" => resource_type,
          "schemaOrg" => schema_org,
          "citeproc" => Bolognese::Utils::CR_TO_CP_TRANSLATIONS[resource_type.to_s.underscore.camelcase] || Bolognese::Utils::SO_TO_CP_TRANSLATIONS[schema_org] || "article",
          "bibtex" => Bolognese::Utils::CR_TO_BIB_TRANSLATIONS[resource_type.to_s.underscore.camelcase] || Bolognese::Utils::SO_TO_BIB_TRANSLATIONS[schema_org] || "misc",
          "ris" => Bolognese::Utils::CR_TO_RIS_TRANSLATIONS[resource_type.to_s.underscore.camelcase] || Bolognese::Utils::DC_TO_RIS_TRANSLATIONS[resource_type_general.to_s.dasherize] || "GEN"
        }.compact

        titles = get_titles(meta)

        descriptions = Array.wrap(meta.dig("descriptions", "description")).map do |r|
          if r.blank?
            nil
          elsif r.is_a?(String)
            { "description" => sanitize(r), "descriptionType" => "Abstract" }
          elsif r.is_a?(Hash)
            { "description" => sanitize(r["__content__"]), "descriptionType" => r["descriptionType"], "lang" => r["lang"] }.compact
          end
        end.compact
        rights_list = Array.wrap(meta.dig("rightsList", "rights")).map do |r|
          if r.blank?
            nil
          elsif r.is_a?(String)
            name_to_spdx(r)
          elsif r.is_a?(Hash)
            hsh_to_spdx(r)
          end
        end.compact

        subjects = Array.wrap(meta.dig("subjects", "subject")).reduce([]) do |sum, subject|
          if subject.is_a?(String)
            sum += name_to_fos(subject)
          elsif subject.is_a?(Hash)
            sum += hsh_to_fos(subject)
          end

          sum
        end.uniq

        dates = Array.wrap(meta.dig("dates", "date")).map do |r|
          if r.is_a?(Hash) && date = sanitize(r["__content__"]).presence
            if Date.edtf(date).present? || Bolognese::Utils::UNKNOWN_INFORMATION.key?(date)
              { "date" => date,
                "dateType" => parse_attributes(r, content: "dateType"),
                "dateInformation" => parse_attributes(r, content: "dateInformation")
              }.compact
            end
          end
        end.compact
        dates << { "date" => meta.fetch("publicationYear", nil), "dateType" => "Issued" } if meta.fetch("publicationYear", nil).present? && get_date(dates, "Issued").blank?
        sizes = Array.wrap(meta.dig("sizes", "size")).map do |k|
          if k.blank?
            nil
          elsif k.is_a?(String)
            sanitize(k).presence
          elsif k.is_a?(Hash)
            sanitize(k["__content__"]).presence
          end
        end.compact
        formats = Array.wrap(meta.dig("formats", "format")).map do |k|
          if k.blank?
            nil
          elsif k.is_a?(String)
            sanitize(k).presence
          elsif k.is_a?(Hash)
            sanitize(k["__content__"]).presence
          end
        end.compact
        .map { |s| s.to_s.squish.presence }.compact
        funding_references = Array.wrap(meta.dig("fundingReferences", "fundingReference")).compact.map do |fr|
          scheme_uri = parse_attributes(fr["funderIdentifier"], content: "schemeURI")
          funder_identifier = parse_attributes(fr["funderIdentifier"])
          funder_identifier_type = parse_attributes(fr["funderIdentifier"], content: "funderIdentifierType")

          if funder_identifier_type == "Crossref Funder ID"
            funder_identifier = validate_funder_doi(funder_identifier)
          elsif funder_identifier_type == "ROR"
            funder_identifier =  normalize_ror(funder_identifier)
            scheme_uri = "https://ror.org"
          end

          {
            "funderName" => fr["funderName"],
            "funderIdentifier" => funder_identifier,
            "funderIdentifierType" => funder_identifier_type,
            "schemeUri" => scheme_uri,
            "awardNumber" => parse_attributes(fr["awardNumber"]),
            "awardUri" => parse_attributes(fr["awardNumber"], content: "awardURI"),
            "awardTitle" => fr["awardTitle"] }.compact
        end
        related_identifiers = Array.wrap(meta.dig("relatedIdentifiers", "relatedIdentifier")).map do |ri|
          if ri["relatedIdentifierType"] == "DOI"
            rid = validate_doi(ri["__content__"].to_s.downcase)
          else
            rid = ri["__content__"]
          end

          {
            "relatedIdentifier" => rid,
            "relatedIdentifierType" => ri["relatedIdentifierType"],
            "relationType" => ri["relationType"],
            "resourceTypeGeneral" => ri["resourceTypeGeneral"],
            "relatedMetadataScheme" => ri["relatedMetadataScheme"],
            "schemeUri" => ri["schemeURI"],
            "schemeType" => ri["schemeType"]
          }.compact
        end

        related_items = Array.wrap(meta.dig("relatedItems", "relatedItem")).map do |ri|

          rii = ri["relatedItemIdentifier"]
          relatedItemIdentifier = nil
          if rii
            if rii["relatedItemIdentifierType"] == "DOI"
              rid = validate_doi(rii["__content__"].to_s.downcase)
            else
              rid = rii["__content__"]
            end

            relatedItemIdentifier = {
              "relatedItemIdentifier" => rid,
              "relatedItemIdentifierType" => rii["relatedItemIdentifierType"],
              "relatedMetadataScheme" => rii["relatedMetadataScheme"],
              "schemeURI" => rii["schemeURI"],
              "schemeType" => rii["schemeType"]
            }.compact
          end

          number = ri["number"]
          if number.is_a?(String)
            number = number
            numberType = nil
          else
            number = ri.dig("number", "__content__")
            numberType = ri.dig("number", "numberType")
          end

          a = {
            "relationType" => ri["relationType"],
            "relatedItemType" => ri["relatedItemType"],
            "relatedItemIdentifier" => relatedItemIdentifier,
            "creators" => get_authors(Array.wrap(ri.dig("creators", "creator"))),
            "titles" => get_titles(ri),
            "publicationYear" => ri["publicationYear"],
            "volume" => ri["volume"],
            "issue" => ri["issue"],
            "number" => number,
            "numberType" => numberType,
            "firstPage" => ri["firstPage"],
            "lastPage" => ri["lastPage"],
            "publisher" => ri["publisher"],
            "edition" => ri["edition"],
            "contributors" => get_authors(Array.wrap(ri.dig("contributors", "contributor"))),
          }.compact
        end

        geo_locations = Array.wrap(meta.dig("geoLocations", "geoLocation")).map do |gl|
          if !gl.is_a?(Hash) || gl["geoLocationPoint"].is_a?(String) || gl["geoLocationBox"].is_a?(String) || gl["geoLocationPolygon"].is_a?(String)
            nil
          else

            # Handle scenario where multiple geoLocationPolygons are allowed within a single geoLocation
            # we want to return an array if it's already an array (i.e. multiple geoLocationPolygons)
            # vs if it's singular just return the object
            # This is for backwards compatability to allow both scenarios.
            if gl.dig("geoLocationPolygon").kind_of?(Array)
              geoLocationPolygon = gl.dig("geoLocationPolygon").map do |glp|
                Array.wrap(glp.dig("polygonPoint")).map { |glpp| { "polygonPoint" => glpp } }.compact.presence
              end.compact.presence
            else
              geoLocationPolygon = Array.wrap(gl.dig("geoLocationPolygon", "polygonPoint")).map { |glp| { "polygonPoint" => glp } }.compact.presence
            end

            {
              "geoLocationPoint" => {
                "pointLatitude" => gl.dig("geoLocationPoint", "pointLatitude"),
                "pointLongitude" => gl.dig("geoLocationPoint", "pointLongitude")
              }.compact.presence,
              "geoLocationBox" => {
                "westBoundLongitude" => gl.dig("geoLocationBox", "westBoundLongitude"),
                "eastBoundLongitude" => gl.dig("geoLocationBox", "eastBoundLongitude"),
                "southBoundLatitude" => gl.dig("geoLocationBox", "southBoundLatitude"),
                "northBoundLatitude" => gl.dig("geoLocationBox", "northBoundLatitude")
              }.compact.presence,
              "geoLocationPolygon" => geoLocationPolygon,
              "geoLocationPlace" => parse_attributes(gl["geoLocationPlace"], first: true).to_s.strip.presence
            }.compact
          end
        end.compact

        state = id.present? || read_options.present? ? "findable" : "not_found"

        { "id" => id,
          "types" => types,
          "doi" => doi_from_url(id),
          "identifiers" => identifiers,
          "url" => options.fetch(:url, nil).to_s.strip.presence,
          "titles" => titles,
          "creators" => get_authors(Array.wrap(meta.dig("creators", "creator"))),
          "contributors" => get_authors(Array.wrap(meta.dig("contributors", "contributor"))),
          "container" => set_container(meta),
          "publisher" => parse_attributes(meta.fetch("publisher", nil), first: true).to_s.strip.presence,
          "agency" => "datacite",
          "funding_references" => funding_references,
          "dates" => dates,
          "publication_year" => parse_attributes(meta.fetch("publicationYear", nil), first: true).to_s.strip.presence,
          "descriptions" => descriptions,
          "rights_list" => Array.wrap(rights_list),
          "version_info" => meta.fetch("version", nil).to_s.presence,
          "subjects" => subjects,
          "language" => parse_attributes(meta.fetch("language", nil), first: true).to_s.strip.presence,
          "geo_locations" => geo_locations,
          "related_identifiers" => related_identifiers,
          "related_items" => related_items,
          "formats" => formats,
          "sizes" => sizes,
          "schema_version" => schema_version,
          "state" => state
        }.merge(read_options)
      end

      def set_container(meta)
        series_information = Array.wrap(meta.dig("descriptions", "description")).find { |r| r["descriptionType"] == "SeriesInformation" }.to_h.fetch("__content__", nil)
        si = get_series_information(series_information)

        is_part_of = Array.wrap(meta.dig("relatedIdentifiers", "relatedIdentifier")).find { |ri| ri["relationType"] == "IsPartOf" }.to_h

        if si["title"].present? || is_part_of.present?
          {
            "type" => meta.dig("resourceType", "resourceTypeGeneral") == "Dataset" ? "DataRepository" : "Series",
            "identifier" => is_part_of["__content__"],
            "identifierType" => is_part_of["relatedIdentifierType"],
            "title" => si["title"],
            "volume" => si["volume"],
            "issue" => si["issue"],
            "firstPage" => si["firstPage"],
            "lastPage" => si["lastPage"]
          }.compact
        else
          {}
        end
      end

      def get_titles(meta)
        titles = Array.wrap(meta.dig("titles", "title")).map do |r|
          if r.blank?
            nil
          elsif r.is_a?(String)
            { "title" => sanitize(r) }
          else
            { "title" => sanitize(r["__content__"]), "titleType" => r["titleType"], "lang" => r["lang"] }.compact
          end
        end.compact

        titles
      end

    end
  end
end
