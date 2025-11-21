# frozen_string_literal: true

module Bolognese
  module DataciteUtils
    def datacite_xml
      @datacite_xml ||= Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
        xml.resource(root_attributes) do
          insert_work(xml)
        end
      end.to_xml
    end

    def datacite_errors(xml: nil, schema_version: nil)
      if xml.present?
        namespaces = Nokogiri::XML(xml, nil, 'UTF-8').root.namespaces
        schema_version = namespaces.fetch('xmlns',nil).presence || namespaces.fetch('xmlns:ns0',nil).presence
      else
        schema_version = schema_version.to_s.start_with?("http://datacite.org/schema/kernel") ? schema_version : "http://datacite.org/schema/kernel-4"
      end

      kernel = schema_version.to_s.split("/").last
      filepath = File.expand_path("../../../resources/#{kernel}/metadata.xsd", __FILE__)
      schema = Nokogiri::XML::Schema(open(filepath))

      schema.validate(Nokogiri::XML(xml, nil, 'UTF-8')).map { |error| error.to_s }.unwrap
    rescue Nokogiri::XML::SyntaxError => e
      e.message
    end

    def insert_work(xml)
      insert_identifier(xml)
      insert_creators(xml)
      insert_titles(xml)
      insert_publisher(xml)
      insert_publication_year(xml)
      insert_resource_type(xml)
      insert_subjects(xml)
      insert_contributors(xml)
      insert_dates(xml)
      insert_language(xml)
      insert_alternate_identifiers(xml)
      insert_related_identifiers(xml)
      insert_related_items(xml)
      insert_sizes(xml)
      insert_formats(xml)
      insert_version(xml)
      insert_rights_list(xml)
      insert_descriptions(xml)
      insert_geo_locations(xml)
      insert_funding_references(xml)
    end

    def insert_identifier(xml)
      xml.identifier(doi, 'identifierType' => "DOI")
    end

    def insert_creators(xml)
      xml.creators do
        Array.wrap(creators).each do |au|
          xml.creator do
            insert_person(xml, au, "creator")
          end
        end
      end
    end

    def insert_contributors(xml)
      return xml unless contributors.present?

      xml.contributors do
        Array.wrap(contributors).each do |con|
          xml.contributor("contributorType" => con["contributorType"]) do
            insert_person(xml, con, "contributor")
          end
        end
      end
    end

    def insert_person(xml, person, type)
      person_name = person["familyName"].present? ? [person["familyName"], person["givenName"]].compact.join(", ") : person["name"]
      attributes = { "nameType" => person["nameType"] }.compact
      xml.send(type + "Name", person_name, attributes)
      xml.givenName(person["givenName"]) if person["givenName"].present?
      xml.familyName(person["familyName"]) if person["familyName"].present?
      Array.wrap(person["nameIdentifiers"]).each do |ni|
        xml.nameIdentifier(ni["nameIdentifier"], 'nameIdentifierScheme' => ni["nameIdentifierScheme"], 'schemeURI' => ni["schemeUri"])
      end
      Array.wrap(person["affiliation"]).each do |affiliation|
        attributes = { "affiliationIdentifier" => affiliation["affiliationIdentifier"], "affiliationIdentifierScheme" => affiliation["affiliationIdentifierScheme"], "schemeURI" => affiliation["schemeUri"] }.compact
        xml.affiliation(affiliation["name"], attributes)
      end
    end

    def insert_titles(xml)
      xml.titles do
        Array.wrap(titles).each do |title|
          if title.is_a?(Hash)
            t = title
          else
            t = {}
            t["title"] = title
          end

          attributes = { 'titleType' => t["titleType"], 'xml:lang' => t["lang"] }.compact
          xml.title(t["title"], attributes)
        end
      end
    end
    
    def insert_publisher(xml)
      if publisher.is_a?(Hash)
        attributes = {
          'publisherIdentifier' => publisher["publisherIdentifier"],
          'publisherIdentifierScheme' => publisher["publisherIdentifierScheme"],
          'schemeURI' => publisher["schemeUri"],
          "xml:lang" => publisher["lang"]
        }.compact
        xml.publisher(publisher["name"] || container && container["title"], attributes)
      else
        xml.publisher(publisher || container && container["title"])
      end
    end

    def insert_publication_year(xml)
      xml.publicationYear(publication_year)
    end

    def insert_resource_type(xml)
      return xml unless types.is_a?(Hash) && (types["schemaOrg"].present? || types["resourceTypeGeneral"])

      xml.resourceType(types["resourceType"],
        'resourceTypeGeneral' => types["resourceTypeGeneral"] || Metadata::SO_TO_DC_TRANSLATIONS[types["schemaOrg"]] || "Other")
    end

    def insert_alternate_identifiers(xml)
      alternate_identifiers = Array.wrap(identifiers).select { |r| r["identifierType"] != "DOI" }
      return xml unless alternate_identifiers.present?

      xml.alternateIdentifiers do
        Array.wrap(alternate_identifiers).each do |alternate_identifier|
          xml.alternateIdentifier(alternate_identifier["identifier"], 'alternateIdentifierType' => alternate_identifier["identifierType"])
        end
      end
    end

    def insert_dates(xml)
      return xml unless Array.wrap(dates).present?

      xml.dates do
        Array.wrap(dates).each do |date|
          attributes = { 'dateType' => date["dateType"] || "Issued", 'dateInformation' => date["dateInformation"] }.compact
          xml.date(date["date"], attributes)
        end
      end
    end

    def insert_funding_references(xml)
      return xml unless Array.wrap(funding_references).present?

      xml.fundingReferences do
        Array.wrap(funding_references).each do |funding_reference|
          xml.fundingReference do
            xml.funderName(funding_reference["funderName"])
            xml.funderIdentifier(funding_reference["funderIdentifier"], { "funderIdentifierType" => funding_reference["funderIdentifierType"] }.compact) if funding_reference["funderIdentifier"].present?
            xml.awardNumber(funding_reference["awardNumber"], { "awardURI" => funding_reference["awardUri"] }.compact) if funding_reference["awardNumber"].present? || funding_reference["awardUri"].present?
            xml.awardTitle(funding_reference["awardTitle"]) if funding_reference["awardTitle"].present?
          end
        end
      end
    end

    def insert_subjects(xml)
      return xml unless subjects.present?

      xml.subjects do
        subjects.each do |subject|
          if subject.is_a?(Hash)
            s = subject
          else
            s = {}
            s["subject"] = subject
          end

          attributes = { "subjectScheme" => s["subjectScheme"], "schemeURI" => s["schemeUri"], "valueURI" => s["valueUri"], "classificationCode" => s["classificationCode"], "xml:lang" => s["lang"] }.compact

          xml.subject(s["subject"], attributes)
        end
      end
    end

    def insert_version(xml)
      return xml unless version_info.present?

      xml.version(version_info)
    end


    def insert_language(xml)
      return xml unless language.present?

      xml.language(language)
    end

    def insert_related_identifiers(xml)
      return xml unless related_identifiers.present?

      xml.relatedIdentifiers do
        related_identifiers.each do |related_identifier|
          attributes = {
            'relatedIdentifierType' => related_identifier["relatedIdentifierType"],
            'relationType' => related_identifier["relationType"],
            'resourceTypeGeneral' => related_identifier["resourceTypeGeneral"] }.compact

          attributes.merge({ 'relatedMetadataScheme' => related_identifier["relatedMetadataSchema"],
            'schemeURI' => related_identifier["schemeUri"],
            'schemeType' => related_identifier["schemeType"]}.compact) if %w(HasMetadata IsMetadataFor).include?(related_identifier["relationType"])

          xml.relatedIdentifier(related_identifier["relatedIdentifier"], attributes)
        end
      end
    end

    def insert_related_items(xml)
      return xml unless related_items.present?

      xml.relatedItems do
        related_items.each do |related_item|
          attributes = {
            'relatedItemType' => related_item["relatedItemType"],
            'relationType' => related_item["relationType"],
          }.compact

          xml.relatedItem(related_item["relatedItem"], attributes) do

            if related_item["relatedItemIdentifier"].present?
              xml.relatedItemIdentifier(related_item["relatedItemIdentifier"]['relatedItemIdentifier'],
                {
                  'relatedItemIdentifierType' => related_item["relatedItemIdentifier"]["relatedItemIdentifierType"],
                  'relatedMetadataScheme' => related_item["relatedItemIdentifier"]["relatedMetadataScheme"],
                  'schemeURI' => related_item["relatedItemIdentifier"]["schemeURI"],
                  'schemeType' => related_item["relatedItemIdentifier"]["schemeType"],
                }.compact
              )
            end

            if related_item["creators"].present?
              xml.creators do
                Array.wrap(related_item['creators']).each do |au|
                  xml.creator do
                    insert_person(xml, au, "creator")
                  end
                end
              end
            end

            xml.titles do
              Array.wrap(related_item['titles']).each do |title|
                if title.is_a?(Hash)
                  t = title
                else
                  t = {}
                  t["title"] = title
                end

                attributes = { 'titleType' => t["titleType"], 'xml:lang' => t["lang"] }.compact
                xml.title(t["title"], attributes)
              end
            end

            xml.publicationYear(related_item['publicationYear']) if related_item["publicationYear"].present?
            xml.volume(related_item['volume']) if related_item["volume"].present?
            xml.issue(related_item['issue']) if related_item["issue"].present?
            xml.number(related_item['number'], {'numberType' => related_item['numberType']}.compact) if related_item["number"].present?
            xml.firstPage(related_item['firstPage']) if related_item["firstPage"].present?
            xml.lastPage(related_item['lastPage']) if related_item["lastPage"].present?
            xml.publisher(related_item['publisher']) if related_item["publisher"].present?
            xml.edition(related_item['edition']) if related_item["edition"].present?

            if related_item["contributors"].present?
              xml.contributors do
                Array.wrap(related_item["contributors"]).each do |con|
                  xml.contributor("contributorType" => con["contributorType"] || "Other") do
                    insert_person(xml, con, "contributor")
                  end
                end
              end
            end

          end
        end
      end
    end

    def insert_sizes(xml)
      xml.sizes do
        Array.wrap(sizes).each do |s|
          xml.size(s)
        end
      end
    end

    def insert_formats(xml)
      xml.formats do
        Array.wrap(formats).each do |f|
          xml.format(f)
        end
      end
    end

    def insert_rights_list(xml)
      return xml unless rights_list.present?

      xml.rightsList do
        Array.wrap(rights_list).each do |rights|
          if rights.is_a?(Hash)
            r = rights
          else
            r = {}
            r["rights"] = rights
            r["rightsUri"] = normalize_id(rights)
          end

          attributes = {
            "rightsURI" => r["rightsUri"],
            "rightsIdentifier" => r["rightsIdentifier"],
            "rightsIdentifierScheme" => r["rightsIdentifierScheme"],
            "schemeURI" => r["schemeUri"],
            "xml:lang" => r["lang"]
          }.compact

          xml.rights(r["rights"], attributes)
        end
      end
    end

    def insert_descriptions(xml)
      return xml unless descriptions.present? || container && container["title"].present?

      xml.descriptions do
        if !from.to_s.include?("datacite") && container && container["title"].present?
          issue = container["issue"].present? ? "(#{container["issue"]})" : nil
          volume_issue = container["volume"].present? ? [container["volume"], issue].join("") : nil
          pages = [container["firstPage"], container["lastPage"]].compact.join("-") if container["firstPage"].present?
          series_information = [container["title"], volume_issue, pages].compact.join(", ")
          xml.description(series_information, 'descriptionType' => "SeriesInformation")
        end

        Array.wrap(descriptions).each do |description|
          if description.is_a?(Hash)
            d = description
          else
            d = {}
            d["description"] = description
            d["descriptionType"] = "Abstract"
          end

          attributes = { 'xml:lang' => d["lang"], 'descriptionType' => d["descriptionType"] || "Abstract" }.compact

          xml.description(d["description"], attributes)
        end
      end
    end

    def insert_geo_locations(xml)
      return xml unless geo_locations.present?

      xml.geoLocations do
        geo_locations.each do |geo_location|
          xml.geoLocation do
            xml.geoLocationPlace(geo_location["geoLocationPlace"]) if geo_location["geoLocationPlace"]

            if geo_location["geoLocationPoint"]
              xml.geoLocationPoint do
                xml.pointLatitude(geo_location.dig("geoLocationPoint", "pointLatitude"))
                xml.pointLongitude(geo_location.dig("geoLocationPoint", "pointLongitude"))
              end
            end

            if geo_location["geoLocationBox"]
              xml.geoLocationBox do
                xml.westBoundLongitude(geo_location.dig("geoLocationBox", "westBoundLongitude"))
                xml.eastBoundLongitude(geo_location.dig("geoLocationBox", "eastBoundLongitude"))
                xml.southBoundLatitude(geo_location.dig("geoLocationBox", "southBoundLatitude"))
                xml.northBoundLatitude(geo_location.dig("geoLocationBox", "northBoundLatitude"))
              end
            end
            if geo_location["geoLocationPolygon"]
              xml.geoLocationPolygon do
                Array.wrap(geo_location["geoLocationPolygon"]).each do |polygon_point|
                  if polygon_point.has_key?("polygonPoint")
                    xml.polygonPoint do
                      xml.pointLatitude(polygon_point.dig("polygonPoint", "pointLatitude"))
                      xml.pointLongitude(polygon_point.dig("polygonPoint", "pointLongitude"))
                    end
                  else
                    xml.inPolygonPoint do
                      xml.pointLatitude(polygon_point.dig("inPolygonPoint", "pointLatitude"))
                      xml.pointLongitude(polygon_point.dig("inPolygonPoint", "pointLongitude"))
                    end
                  end
                end
              end
            end
          end
        end
      end
    end

    def root_attributes
      { :'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
        :'xsi:schemaLocation' => 'http://datacite.org/schema/kernel-4 http://schema.datacite.org/meta/kernel-4/metadata.xsd',
        :'xmlns' => 'http://datacite.org/schema/kernel-4' }
    end
  end
end
