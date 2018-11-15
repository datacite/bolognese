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
        
        titles = Array.wrap(meta.dig("titles", "title")).map do |r|
          if r.is_a?(String)
            { "title" => sanitize(r) }
          else
            { "title" => sanitize(r["__content__"]), "titleType" => r["titleType"], "lang" => r["lang"] }.compact
          end
        end

        alternate_identifiers = Array.wrap(meta.dig("alternateIdentifiers", "alternateIdentifier")).map do |r|
          { "alternateIdentifierType" => r["alternateIdentifierType"], "alternateIdentifier" => r["__content__"] }
        end
        descriptions = Array.wrap(meta.dig("descriptions", "description")).select { |r| r["descriptionType"] != "SeriesInformation" }.map do |r|
          { "description" => sanitize(r["__content__"]), "descriptionType" => r["descriptionType"], "lang" => r["lang"] }.compact
        end
        rights_list = Array.wrap(meta.dig("rightsList", "rights")).map do |r|
          { "rights" => r["__content__"], "rightsUri" => normalize_url(r["rightsURI"]), "lang" => r["lang"] }.compact
        end
        subjects = Array.wrap(meta.dig("subjects", "subject")).map do |k|
          if k.nil?
            nil
          elsif k.is_a?(String)
            { "subject" => sanitize(k) }
          else
            { "subject" => sanitize(k["__content__"]), "subjectScheme" => k["subjectScheme"], "schemeUri" => k["schemeURI"], "valueUri" => k["valueURI"], "lang" => k["lang"] }.compact
          end
        end.compact
        dates = Array.wrap(meta.dig("dates", "date")).map do |d|
          {
            "date" => parse_attributes(d),
            "dateType" => parse_attributes(d, content: "dateType"),
            "dateInformation" => parse_attributes(d, content: "dateInformation")
          }.compact
        end
        dates << { "date" => meta.fetch("publicationYear", nil), "dateType" => "Issued" } if meta.fetch("publicationYear", nil).present? && get_date(dates, "Issued").blank?
        sizes = Array.wrap(meta.dig("sizes", "size"))
        formats = Array.wrap(meta.dig("formats", "format"))
        funding_references = Array.wrap(meta.dig("fundingReferences", "fundingReference")).compact.map do |fr|
          {
            "funderName" => fr["funderName"],
            "funderIdentifier" => normalize_id(parse_attributes(fr["funderIdentifier"])),
            "funderIdentifierType" => parse_attributes(fr["funderIdentifier"], content: "funderIdentifierType"),
            "awardNumber" => parse_attributes(fr["awardNumber"]),
            "awardUri" => parse_attributes(fr["awardNumber"], content: "awardURI"),
            "awardTitle" => fr["awardTitle"] }.compact
        end
        related_identifiers = Array.wrap(meta.dig("relatedIdentifiers", "relatedIdentifier")).map do |ri|
          if ri["relatedIdentifierType"] == "DOI"
            rid = ri["__content__"].to_s.downcase
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
        geo_locations = Array.wrap(meta.dig("geoLocations", "geoLocation")).map do |gl|
          if gl["geoLocationPoint"].is_a?(String) || gl["geoLocationBox"].is_a?(String)
            nil
          else
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
              "geoLocationPlace" => gl["geoLocationPlace"],
            }.compact
          end
        end
        periodical = set_periodical(meta)
        state = doi.present? ? "findable" : "not_found"

        { "id" => id,
          "types" => types,
          "doi" => doi,
          "alternate_identifiers" => alternate_identifiers,
          "url" => options.fetch(:url, nil),
          "titles" => titles,
          "creator" => get_authors(Array.wrap(meta.dig("creators", "creator"))),
          "contributor" => get_authors(Array.wrap(meta.dig("contributors", "contributor"))),
          "periodical" => periodical,
          "publisher" => meta.fetch("publisher", nil).to_s.strip.presence,
          "source" => "DataCite",
          "funding_references" => funding_references,
          "dates" => dates,
          "publication_year" => meta.fetch("publicationYear", nil),
          "descriptions" => descriptions,
          "rights_list" => rights_list,
          "version" => meta.fetch("version", nil),
          "subjects" => subjects,
          "language" => meta.fetch("language", nil),
          "geo_locations" => geo_locations,
          "related_identifiers" => related_identifiers,
          "formats" => formats,
          "sizes" => sizes,
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
    end
  end
end
