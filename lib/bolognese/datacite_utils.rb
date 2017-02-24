module Bolognese
  module DataciteUtils

    SO_TO_DC_TRANSLATIONS = {
      "Article" => "Text",
      "AudioObject" => "Sound",
      "Blog" => "Text",
      "BlogPosting" => "Text",
      "Collection" => "Collection",
      "CreativeWork" => "Other",
      "DataCatalog" => "Dataset",
      "Dataset" => "Dataset",
      "Event" => "Event",
      "ImageObject" => "Image",
      "Movie" => "Audiovisual",
      "PublicationIssue" => "Text",
      "ScholarlyArticle" => "Text",
      "Service" => "Service",
      "SoftwareSourceCode" => "Software",
      "VideoObject" => "Audiovisual",
      "WebPage" => "Text",
      "WebSite" => "Text"
    }

    LICENSE_NAMES = {
      "http://creativecommons.org/publicdomain/zero/1.0/" => "Public Domain (CC0 1.0)",
      "http://creativecommons.org/licenses/by/3.0/" => "Creative Commons Attribution 3.0 (CC-BY 3.0)",
      "http://creativecommons.org/licenses/by/4.0/" => "Creative Commons Attribution 4.0 (CC-BY 4.0)",
      "http://creativecommons.org/licenses/by-nc/4.0/" => "Creative Commons Attribution Noncommercial 4.0 (CC-BY-NC 4.0)",
      "http://creativecommons.org/licenses/by-sa/4.0/" => "Creative Commons Attribution Share Alike 4.0 (CC-BY-SA 4.0)",
      "http://creativecommons.org/licenses/by-nc-nd/4.0/" => "Creative Commons Attribution Noncommercial No Derivatives 4.0 (CC-BY-NC-ND 4.0)"
    }

    SCHEMA = File.expand_path("../../../resources/kernel-4.0/metadata.xsd", __FILE__)

    def schema
      Nokogiri::XML::Schema(open(SCHEMA))
    end

    def datacite_xml
      @datacite_xml ||= Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
        xml.resource(root_attributes) do
          insert_work(xml)
        end
      end.to_xml
    end

    def as_datacite
      if validation_errors.blank?
        datacite_xml
      end
    end

    def validation_errors
      schema.validate(Nokogiri::XML(datacite_xml)).map { |error| error.to_s }
    end

    def insert_work(xml)
      insert_identifier(xml)
      insert_creators(xml)
      insert_titles(xml)
      insert_publisher(xml)
      insert_publication_year(xml)
      insert_resource_type(xml)
      insert_alternate_identifiers(xml)
      insert_subjects(xml)
      insert_contributors(xml)
      insert_funding_references(xml)
      insert_dates(xml)
      insert_related_identifiers(xml)
      insert_version(xml)
      insert_rights_list(xml)
      insert_descriptions(xml)
    end

    def insert_identifier(xml)
      xml.identifier(doi, 'identifierType' => "DOI")
    end

    def insert_creators(xml)
      xml.creators do
        Array.wrap(author).each do |creator|
          xml.creator do
            insert_person(xml, creator, "creator")
          end
        end
      end
    end

    def insert_contributors(xml)
      return xml unless editor.present?

      xml.contributors do
        Array.wrap(editor).each do |contributor|
          xml.contributor("contributorType" => "Editor") do
            insert_person(xml, contributor, "contributor")
          end
        end
      end
    end

    def insert_person(xml, person, type)
      person_name = person["name"].presence || [person["familyName"], person["givenName"]].compact.join(", ")

      xml.send(type + "Name", person_name)
      xml.givenName(person["givenName"]) if person["givenName"].present?
      xml.familyName(person["familyName"]) if person["familyName"].present?
      xml.nameIdentifier(person["@id"], 'schemeURI' => 'http://orcid.org/', 'nameIdentifierScheme' => 'ORCID') if person["@id"].present?
    end

    def insert_titles(xml)
      xml.titles do
        insert_title(xml)
      end
    end

    def insert_title(xml)
      xml.title(name)
    end

    def insert_publisher(xml)
      xml.publisher(container_title)
    end

    def insert_publication_year(xml)
      xml.publicationYear(publication_year)
    end

    def resource_type
      { "resource_type_general" => SO_TO_DC_TRANSLATIONS[type] || "Other",
        "__content__" => additional_type || type }
    end

    def insert_resource_type(xml)
      return xml unless type.present?

      xml.resourceType(resource_type["__content__"],
        'resourceTypeGeneral' => resource_type["resource_type_general"])
    end

    def insert_alternate_identifiers(xml)
      return xml unless alternate_name.present?

      xml.alternateIdentifiers do
        xml.alternateIdentifier(alternate_name, 'alternateIdentifierType' => "Local accession number")
      end
    end

    def insert_dates(xml)
      xml.dates do
        insert_date(xml, date_created, 'Created') if date_created.present?
        insert_date(xml, date_published, 'Issued') if date_published.present?
        insert_date(xml, date_modified, 'Updated') if date_modified.present?
      end
    end

    def insert_date(xml, date, date_type)
      xml.date(date, 'dateType' => date_type)
    end

    def insert_funding_references(xml)
      return xml unless Array.wrap(funder).present?

      xml.fundingReferences do
        Array.wrap(funder).each do |funding_reference|
          xml.fundingReference do
            insert_funding_reference(xml, funding_reference)
          end
        end
      end
    end

    def insert_funding_reference(xml, funding_reference)
      xml.funderName(funding_reference["name"]) if funding_reference["name"].present?
      xml.funderIdentifier(funding_reference["@id"], "funderIdentifierType" => "Crossref Funder ID") if funding_reference["@id"].present?
    end

    def insert_subjects(xml)
      return xml unless keywords.present?

      xml.subjects do
        keywords.split(", ").each do |subject|
          xml.subject(subject)
        end
      end
    end

    def insert_version(xml)
      return xml unless version.present?

      xml.version(version)
    end

    def rel_identifiers
      rel_identifier(rel_ids: is_part_of, relation_type: "IsPartOf") +
      rel_identifier(rel_ids: has_part, relation_type: "HasPart") +
      rel_identifier(rel_ids: citation, relation_type: "References")
    end

    def rel_identifier(rel_ids: nil, relation_type: nil)
      Array.wrap(rel_ids).map do |i|
        { "__content__" => i["@id"],
          "related_identifier_type" => validate_url(i["@id"]),
          "relation_type" => relation_type }
      end.select { |i| i["related_identifier_type"].present? }
    end

    def insert_related_identifiers(xml)
      return xml unless rel_identifiers.present?

      xml.relatedIdentifiers do
        rel_identifiers.each do |related_identifier|
          xml.relatedIdentifier(related_identifier["__content__"], 'relatedIdentifierType' => related_identifier["related_identifier_type"], 'relationType' => related_identifier["relation_type"])
        end
      end
    end

    def insert_rights_list(xml)
      return xml unless license.present?

      xml.rightsList do
        Array.wrap(license).each do |lic|
          xml.rights(LICENSE_NAMES[lic], 'rightsURI' => lic)
        end
      end
    end

    def insert_descriptions(xml)
      return xml unless descriptions.present?

      xml.descriptions do
        Array.wrap(description).each do |des|
          insert_description(xml, des)
        end
      end
    end

    def insert_description(xml, des)
      if des.is_a?(String)
        xml.description(des.strip, 'descriptionType' => "Abstract")
      elsif des.is_a?(Hash)
        xml.description(des["__content__"].strip, 'descriptionType' => des["descriptionType"],)
      end
    end

    def without_control(s)
      r = ''
      s.each_codepoint do |c|
        if c >= 32
          r << c
        end
      end
      r
    end

    def root_attributes
      { :'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
        :'xsi:schemaLocation' => 'http://datacite.org/schema/kernel-4 http://schema.datacite.org/meta/kernel-4/metadata.xsd',
        :'xmlns' => 'http://datacite.org/schema/kernel-4' }
    end
  end
end
