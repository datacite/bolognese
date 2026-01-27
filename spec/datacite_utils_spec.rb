# frozen_string_literal: true

require 'spec_helper'
require 'pp'

describe Bolognese::Metadata, vcr: true do
  let(:input) { "https://doi.org/10.5061/DRYAD.8515" }

  subject { Bolognese::Metadata.new(input: input, from: "datacite") }

  context "insert_identifier" do
    it "doi" do
      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_identifier(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response["identifier"]).to eq("identifierType"=>"DOI", "__content__"=>"10.5061/dryad.8515")
    end
  end

  context "insert_creators" do
    it "insert" do
      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_creators(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response.dig("creators", "creator").first).to eq("affiliation" => {"__content__"=>"Centre International de Recherches Médicales de Franceville", "affiliationIdentifier"=>"https://ror.org/01wyqb997", "affiliationIdentifierScheme"=>"ROR"}, "creatorName"=>{"__content__"=>"Ollomo, Benjamin", "nameType"=>"Personal"}, "familyName"=>"Ollomo", "givenName"=>"Benjamin")
    end
  end

  context "insert_contributors" do
    it "none" do
      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_contributors(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response).to be_nil
    end
  end

  context "insert_person" do
    it "creator only name" do
      person = { "name" => "Carberry, Josiah" }
      type = "creator"
      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_person(xml, person, type) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response).to eq("creatorName"=>"Carberry, Josiah")
    end

    # it "creator given and family name" do
    #   person = { "givenName" => "Josiah", "familyName" => "Carberry" }
    #   type = "creator"
    #   xml = Nokogiri::XML::Builder.new { |xml| subject.insert_person(xml, person, type) }.to_xml
    #   response = Maremma.from_xml(xml)
    #   expect(response).to eq("creatorName"=>"Carberry, Josiah")
    # end
  end

  context "insert_titles" do
    it "insert" do
      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_titles(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response.dig("titles", "title")).to eq("Data from: A new malaria agent in African hominids.")
    end
  end

  context "insert_publisher" do
    it "insert" do
      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_publisher(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response["publisher"]).to eq("Dryad")
    end
  end

  context "insert_publication_year" do
    it "insert" do
      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_publication_year(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response["publicationYear"]).to eq("2011")
    end
  end

  context "insert_resource_type" do
    it "insert" do
      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_resource_type(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response["resourceType"]).to eq("resourceTypeGeneral"=>"Dataset", "__content__"=>"dataset")
    end
  end

  # context "insert_alternate_identifiers" do
  #   it "insert" do
  #     xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_alternate_identifiers(xml) }.to_xml
  #     response = Maremma.from_xml(xml)
  #     expect(response.dig("alternateIdentifiers", "alternateIdentifier").to be_nil)
  #   end
  # end

  context "insert_dates" do
    it "insert" do
      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_dates(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response.dig("dates", "date")).to eq([{"__content__"=>"2011-02-01T17:22:41Z", "dateType"=>"Available"}, {"__content__"=>"2011", "dateType"=>"Issued"}])
    end
  end

  context "insert_subjects" do
    it "insert" do
      input = "https://doi.org/10.5878/xyad-9f70"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_subjects(xml) }.to_xml
      response = Maremma.from_xml(xml)
      # It should preserve the classificationCode
      expect(response.dig("subjects", "subject")[0]["classificationCode"]).to eq("a046a1ec-a4d1-4777-8705-3a17548f1969")
      expect(response.dig("subjects", "subject")[0]).to eq({"subjectScheme"=>"ELSST", "valueURI"=>"https://elsst.cessda.eu/id/a046a1ec-a4d1-4777-8705-3a17548f1969", "classificationCode"=>"a046a1ec-a4d1-4777-8705-3a17548f1969", "xml:lang"=>"en", "__content__"=>"decision making"})
    end
  end

  context "insert_version" do
    it "insert" do
      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_version(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response.fetch("version", nil)).to eq("1")
    end
  end

  context "insert_sizes" do
    it "insert" do
      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_sizes(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response.fetch("sizes", nil)).to eq("size"=>"107328 bytes")
    end
  end

  context "insert_formats" do
    let(:input) { IO.read(fixture_path + 'datacite-empty-sizes.xml') }
    
    subject { Bolognese::Metadata.new(input: input, from: "datacite") }

    it "insert" do
      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_formats(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response.fetch("formats", nil)).to eq("format" => "text")
    end
  end

  context "insert_language" do
    it "insert" do
      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_language(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response.fetch("language", nil)).to eq("en")
    end
  end

  context "insert_related_identifiers" do
    it "related_identifier" do
      expect(subject.related_identifiers.length).to eq(1)
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"10.1371/journal.ppat.1000446", "relatedIdentifierType"=>"DOI", "relationType"=>"Cites")
    end

    it "insert" do
      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_related_identifiers(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response.dig("relatedIdentifiers", "relatedIdentifier")).to eq("__content__"=>"10.1371/journal.ppat.1000446", "relatedIdentifierType"=>"DOI", "relationType"=>"Cites")
    end
  end

  context "insert_rights_list" do
    it "insert" do
      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_rights_list(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response.dig("rightsList", "rights")).to eq("__content__" => "Creative Commons Zero v1.0 Universal",
        "rightsIdentifier" => "cc0-1.0",
        "rightsIdentifierScheme" => "SPDX",
        "rightsURI" => "https://creativecommons.org/publicdomain/zero/1.0/legalcode",
        "schemeURI" => "https://spdx.org/licenses/")
    end
  end

  context "insert_descriptions" do
    it "insert" do
      input = "https://doi.org/10.5438/4K3M-NYVG"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_descriptions(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response.dig("descriptions", "description")).to eq("descriptionType" => "Abstract", "__content__" => "Eating your own dog food is a slang term to describe that an organization should itself use the products and services it provides. For DataCite this means that we should use DOIs with appropriate metadata and strategies for long-term preservation for...")
    end
  end

  context "insert_related_items" do
    let(:input) { IO.read(fixture_path + 'datacite-example-relateditems.xml') }
    it "insert" do
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_related_items(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response.dig("relatedItems", "relatedItem")).to eq(
        "relationType" => "IsPublishedIn",
        "relatedItemType" => "Journal",
        "relatedItemIdentifier" => {"__content__"=>"10.5072/john-smiths-1234", "relatedItemIdentifierType"=>"DOI", "relatedMetadataScheme"=>"citeproc+json", "schemeType"=>"URL", "schemeURI"=>"https://github.com/citation-style-language/schema/raw/master/csl-data.json"},
        "creators" => {"creator"=>{"creatorName"=>{"__content__"=>"Smith, John", "nameType"=>"Personal"}, "familyName"=>"Smith", "givenName"=>"John"}},
        "titles" => {"title"=>["Understanding the fictional John Smith", {"__content__"=>"A detailed look", "titleType"=>"Subtitle"}]},
        "publicationYear" => "1776",
        "volume" => "776",
        "issue" => "1",
        "number" => {"__content__"=>"1", "numberType"=>"Chapter"},
        "firstPage" => "50",
        "lastPage" => "60",
        "publisher" => "Example Inc",
        "edition" => "1",
        "contributors" => {"contributor"=>{"contributorName"=>"Hallett, Richard", "contributorType"=>"ProjectLeader", "familyName"=>"Hallett", "givenName"=>"Richard"}}
      )
    end
  end

  ### New DataCite 4.6 Features Tests ###

  context "insert_resource_type with Project" do
    it "supports Project as resourceTypeGeneral" do
      # Mock the `types` hash to include Project
      subject.instance_variable_set(:@types, {
        "resourceTypeGeneral" => "Project",
        "resourceType" => "Research Project"
      })

      # Generate XML using the insert_resource_type method
      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_resource_type(xml) }.to_xml

      response = Maremma.from_xml(xml)

      # Expect `Project` in resourceTypeGeneral and `Research Project` as the content
      expect(response["resourceType"]).to eq(
        "resourceTypeGeneral" => "Project",
        "__content__" => "Research Project"
      )
    end
  end

  context "insert_resource_type with Award" do
    it "supports Award as resourceTypeGeneral" do
      # Mock the `types` hash to include Award
      subject.instance_variable_set(:@types, {
        "resourceTypeGeneral" => "Award",
        "resourceType" => "Nobel Prize"
      })

      # Generate XML using the insert_resource_type method
      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_resource_type(xml) }.to_xml

      response = Maremma.from_xml(xml)

      # Expect `Award` in resourceTypeGeneral and `Nobel Prize` as the content
      expect(response["resourceType"]).to eq(
        "resourceTypeGeneral" => "Award",
        "__content__" => "Nobel Prize"
      )
    end
  end

  context "insert_resource_type when resourceType is available, but using schemaOrg (via SO_TO_DC_TRANSLATIONS) when resourceTypeGeneral is unavailable" do
    it "supports schemaOrg value as resourceTypeGeneral" do
      # Mock the `types` hash to include the necessary values
      subject.instance_variable_set(:@types, {
        "schemaOrg" => "BlogPosting",
        "resourceType" => "This dataset contains all projects funded by the European Union under the fifth framework programme for research and technological development (FP5) from 1998 to 2002."
      })

      # Generate XML using the insert_resource_type method
      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_resource_type(xml) }.to_xml

      response = Maremma.from_xml(xml)

      # Expect `Text` in resourceTypeGeneral (via SO_TP_DC_TRANSLATIONS) and `This dataset contains all projects funded...` as the content
      expect(response["resourceType"]).to eq(
        "resourceTypeGeneral" => "Text",
        "__content__" => "This dataset contains all projects funded by the European Union under the fifth framework programme for research and technological development (FP5) from 1998 to 2002."
      )
    end
  end

  context "insert_resource_type when resourceType is available, 'OTHER' when schemaOrg has no valid translations, and 'resourceTypeGeneral is unavailable" do
    it "supports Other as resourceTypeGeneral" do
      # Mock the `types` hash to include the necessary values
      subject.instance_variable_set(:@types, {
        "schemaOrg" => "Invalid_SO_Value",
        "resourceType" => "This dataset contains all projects funded by the European Union under the fifth framework programme for research and technological development (FP5) from 1998 to 2002."
      })

      # Generate XML using the insert_resource_type method
      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_resource_type(xml) }.to_xml

      response = Maremma.from_xml(xml)

      # Expect `Text` in resourceTypeGeneral (via SO_TP_DC_TRANSLATIONS) and `This dataset contains all projects funded...` as the content
      expect(response["resourceType"]).to eq(
        "resourceTypeGeneral" => "Other",
        "__content__" => "This dataset contains all projects funded by the European Union under the fifth framework programme for research and technological development (FP5) from 1998 to 2002."
      )
    end
  end

  # Test case to insert Coverage DateType (new dateType in DataCite 4.6).
  context "insert_dates with Coverage" do
    it "inserts date with dateType Coverage" do
      subject.dates = [{ "date" => "2021-01-01", "dateType" => "Coverage" }]

      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_dates(xml) }.to_xml
      response = Maremma.from_xml(xml)
      dates = response.dig("dates", "date")
      expect(dates).to eq("__content__" => "2021-01-01", "dateType" => "Coverage")
    end
  end

  # Test case to insert Translator contributor (new contributorType in DataCite 4.6)
  context "insert_contributors Translator" do
    it "supports Translator contributorType" do
      subject.contributors = [
        { "contributorName" => "John Translator", "contributorType" => "Translator" }
      ]

      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_contributors(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response.dig("contributors", "contributor", "contributorType")).to eq("Translator")
    end
  end

  # Test case for RRID (new relatedIdentifierType in DataCite 4.6)
  context "insert_related_identifiers RRID" do
    it "supports RRID relatedIdentifierType" do
      subject.related_identifiers = [
        { "relatedIdentifier" => "RRID:AB_90755", "relatedIdentifierType" => "RRID", "relationType" => "References" }
      ]

      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_related_identifiers(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response.dig("relatedIdentifiers", "relatedIdentifier")).to eq("__content__" => "RRID:AB_90755", "relatedIdentifierType" => "RRID", "relationType" => "References")
    end
  end

  ### Test case #2 for adding CSTR ###
  context "insert_related_identifiers CSTR" do
    it "supports CSTR relatedIdentifierType" do
      subject.related_identifiers = [
        { "relatedIdentifier" => "CSTR:AB_12345", "relatedIdentifierType" => "CSTR", "relationType" => "References" }
      ]

      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_related_identifiers(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response.dig("relatedIdentifiers", "relatedIdentifier")).to eq("__content__" => "CSTR:AB_12345", "relatedIdentifierType" => "CSTR", "relationType" => "References")
    end
  end

  # Test case for HasTranslation (new relationType in DataCite 4.6)
  context "insert_related_identifiers HasTranslation" do
    it "supports HasTranslation relationType" do
      subject.related_identifiers = [
        { "relatedIdentifier" => "10.1234/translated-version", "relatedIdentifierType" => "DOI", "relationType" => "HasTranslation" }
      ]

      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_related_identifiers(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response.dig("relatedIdentifiers", "relatedIdentifier")).to eq("__content__" => "10.1234/translated-version", "relatedIdentifierType" => "DOI", "relationType" => "HasTranslation")
    end
  end

  ### New DataCite 4.7 Features Tests ###

  context "insert_resource_type with resourceTypeGeneral Poster" do
    it "resource_type" do
      # Mock the `types` hash to include Project
      subject.instance_variable_set(:@types, {
        "resourceTypeGeneral" => "Poster",
        "resourceType" => "Research Project"
      })

      # Generate XML using the insert_resource_type method
      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_resource_type(xml) }.to_xml

      response = Maremma.from_xml(xml)

      # Expect `Project` in resourceTypeGeneral and `Research Project` as the content
      expect(response["resourceType"]).to eq(
        "resourceTypeGeneral" => "Poster",
        "__content__" => "Research Project"
      )
    end
  end

  context "insert_resource_type with resourceTypeGeneral Presentation" do
    it "resource_type" do
      # Mock the `types` hash to include Project
      subject.instance_variable_set(:@types, {
        "resourceTypeGeneral" => "Presentation",
        "resourceType" => "Research Project"
      })

      # Generate XML using the insert_resource_type method
      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_resource_type(xml) }.to_xml

      response = Maremma.from_xml(xml)

      # Expect `Poster` in resourceTypeGeneral and `Research Project` as the content
      expect(response["resourceType"]).to eq(
        "resourceTypeGeneral" => "Presentation",
        "__content__" => "Research Project"
      )
    end
  end

  context "insert_related_identifier with resourceTypeGeneral Poster" do
    it "related_identifier" do
      subject.instance_variable_set(:@related_identifiers, [{"relatedIdentifier"=>"10.1371/journal.ppat.1000446", "relatedIdentifierType"=>"ARK", "relationType"=>"IsCitedBy", "resourceTypeGeneral"=>"Poster"}])
      expect(subject.related_identifiers.length).to eq(1)
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"10.1371/journal.ppat.1000446", "relatedIdentifierType"=>"ARK", "relationType"=>"IsCitedBy", "resourceTypeGeneral"=>"Poster")

      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_related_identifiers(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response.dig("relatedIdentifiers", "relatedIdentifier", "resourceTypeGeneral")).to eq("Poster")
    end
  end

  context "insert_related_identifier with resourceTypeGeneral Presentation" do
    it "related_identifier" do
      subject.instance_variable_set(:@related_identifiers, [{"relatedIdentifier"=>"10.1371/journal.ppat.1000446", "relatedIdentifierType"=>"ARK", "relationType"=>"IsCitedBy", "resourceTypeGeneral"=>"Presentation"}])
      expect(subject.related_identifiers.length).to eq(1)
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"10.1371/journal.ppat.1000446", "relatedIdentifierType"=>"ARK", "relationType"=>"IsCitedBy", "resourceTypeGeneral"=>"Presentation")

      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_related_identifiers(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response.dig("relatedIdentifiers", "relatedIdentifier", "resourceTypeGeneral")).to eq("Presentation")
    end
  end

  context "insert_insert_related_item with related_item_type Poster" do
    it "related_item" do
      subject.instance_variable_set(:@related_items, [{"relatedItemType"=>"Poster", "relationType"=>"IsCitedBy"}])
      expect(subject.related_items.length).to eq(1)
      expect(subject.related_items.first).to eq("relatedItemType"=>"Poster", "relationType"=>"IsCitedBy")

      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_related_items(xml) }.to_xml
      response = Maremma.from_xml(xml)

      expect(response.dig("relatedItems", "relatedItem", "relatedItemType")).to eq("Poster")
    end
  end

  context "insert_insert_related_item with related_item_type Presentation" do
    it "related_item" do
      subject.instance_variable_set(:@related_items, [{"relatedItemType"=>"Presentation", "relationType"=>"IsCitedBy"}])
      expect(subject.related_items.length).to eq(1)
      expect(subject.related_items.first).to eq("relatedItemType"=>"Presentation", "relationType"=>"IsCitedBy")

      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_related_items(xml) }.to_xml
      response = Maremma.from_xml(xml)

      expect(response.dig("relatedItems", "relatedItem", "relatedItemType")).to eq("Presentation")
    end
  end

  context "insert_related_identifier with relatedIdentifierType RAiD" do
    it "related_identifier" do
      subject.instance_variable_set(:@related_identifiers, [{"relatedIdentifier"=>"10.1371/journal.ppat.1000446", "relatedIdentifierType"=>"RAiD", "relationType"=>"IsCitedBy"}])
      expect(subject.related_identifiers.length).to eq(1)
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"10.1371/journal.ppat.1000446", "relatedIdentifierType"=>"RAiD", "relationType"=>"IsCitedBy")

      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_related_identifiers(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response.dig("relatedIdentifiers", "relatedIdentifier", "relatedIdentifierType")).to eq("RAiD")
    end
  end

  context "insert_related_identifier with relatedIdentifierType SWHID" do
    it "related_identifier" do
      subject.instance_variable_set(:@related_identifiers, [{"relatedIdentifier"=>"10.1371/journal.ppat.1000446", "relatedIdentifierType"=>"SWHID", "relationType"=>"IsCitedBy"}])
      expect(subject.related_identifiers.length).to eq(1)
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"10.1371/journal.ppat.1000446", "relatedIdentifierType"=>"SWHID", "relationType"=>"IsCitedBy")

      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_related_identifiers(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response.dig("relatedIdentifiers", "relatedIdentifier", "relatedIdentifierType")).to eq("SWHID")
    end
  end

  context "insert_insert_related_item with relatedItemIdentifierType RAiD" do
    it "related_item" do
      subject.instance_variable_set(:@related_items, [
        {
          "relatedItemType"=>"Presentation",
          "relationType"=>"IsCitedBy",
          "relatedItemIdentifier" => {
            "relatedItemIdentifier" => "10.82523/hnhr-r562",
            "relatedItemIdentifierType" => "RAiD"
          }
        }])
      expect(subject.related_items.length).to eq(1)
      expect(subject.related_items.first).to eq(
        "relatedItemType"=>"Presentation",
        "relationType"=>"IsCitedBy",
        "relatedItemIdentifier" => {
          "relatedItemIdentifier" => "10.82523/hnhr-r562",
          "relatedItemIdentifierType" => "RAiD"
        }
      )

      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_related_items(xml) }.to_xml
      response = Maremma.from_xml(xml)

      expect(response.dig(
        "relatedItems",
        "relatedItem",
        "relatedItemIdentifier",
        "relatedItemIdentifierType"
      )).to eq("RAiD")
    end
  end

  context "insert_insert_related_item with relatedItemIdentifierType SWHID" do
    it "related_item" do
      subject.instance_variable_set(:@related_items, [
        {
          "relatedItemType"=>"Presentation",
          "relationType"=>"IsCitedBy",
          "relatedItemIdentifier" => {
            "relatedItemIdentifier" => "10.82523/hnhr-r562",
            "relatedItemIdentifierType" => "SWHID"
          }
        }])
      expect(subject.related_items.length).to eq(1)
      expect(subject.related_items.first).to eq(
        "relatedItemType"=>"Presentation",
        "relationType"=>"IsCitedBy",
        "relatedItemIdentifier" => {
          "relatedItemIdentifier" => "10.82523/hnhr-r562",
          "relatedItemIdentifierType" => "SWHID"
        }
      )

      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_related_items(xml) }.to_xml
      response = Maremma.from_xml(xml)

      expect(response.dig(
        "relatedItems",
        "relatedItem",
        "relatedItemIdentifier",
        "relatedItemIdentifierType"
      )).to eq("SWHID")
    end
  end

  context "insert_related_identifier with relationType Other" do
    it "related_identifier" do
      subject.instance_variable_set(:@related_identifiers, [{"relatedIdentifier"=>"10.1371/journal.ppat.1000446", "relatedIdentifierType"=>"IsCitedBy", "relationType"=>"Other"}])
      expect(subject.related_identifiers.length).to eq(1)
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"10.1371/journal.ppat.1000446", "relatedIdentifierType"=>"IsCitedBy", "relationType"=>"Other")

      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_related_identifiers(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response.dig("relatedIdentifiers", "relatedIdentifier", "relationType")).to eq("Other")
    end
  end

  context "insert_insert_related_item with relationType Other" do
    it "related_item" do
      subject.instance_variable_set(:@related_items, [
        {
          "relatedItemType"=>"Presentation",
          "relationType"=>"Other",
          "relatedItemIdentifier" => {
            "relatedItemIdentifier" => "10.82523/hnhr-r562",
            "relatedItemIdentifierType" => "SWHID"
          }
        }])
      expect(subject.related_items.length).to eq(1)
      expect(subject.related_items.first).to eq(
        "relatedItemType"=>"Presentation",
        "relationType"=>"Other",
        "relatedItemIdentifier" => {
          "relatedItemIdentifier" => "10.82523/hnhr-r562",
          "relatedItemIdentifierType" => "SWHID"
        }
      )

      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_related_items(xml) }.to_xml
      response = Maremma.from_xml(xml)

      expect(response.dig(
        "relatedItems",
        "relatedItem",
        "relationType"
      )).to eq("Other")
    end
  end

  context "insert_related_identifier with relationTypeInformation 'Free text 1 - relationTypeInformation'" do
    it "related_identifier" do
      subject.instance_variable_set(:@related_identifiers, [{"relatedIdentifier"=>"10.1371/journal.ppat.1000446", "relatedIdentifierType"=>"SWHID", "relationType"=>"IsCitedBy", "relationTypeInformation" => "Free text 1 - relationTypeInformation"}])

      expect(subject.related_identifiers.length).to eq(1)
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"10.1371/journal.ppat.1000446", "relatedIdentifierType"=>"SWHID", "relationType"=>"IsCitedBy", "relationTypeInformation" => "Free text 1 - relationTypeInformation")

      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_related_identifiers(xml) }.to_xml
      response = Maremma.from_xml(xml)

      expect(response.dig("relatedIdentifiers", "relatedIdentifier", "relationTypeInformation")).to eq("Free text 1 - relationTypeInformation")
    end
  end

  context "insert_insert_related_item with relationTypeInformation 'Free text 2 - relationTypeInformation'" do
    it "related_item" do
      subject.instance_variable_set(:@related_items, [
        {
          "relatedItemType"=>"Presentation",
          "relationType"=>"IsCitedBy",
          "relationTypeInformation" => "Free text 2 - relationTypeInformation",
          "relatedItemIdentifier" => {
            "relatedItemIdentifier" => "10.82523/hnhr-r562",
            "relatedItemIdentifierType" => "SWHID"
          }
        }])
      expect(subject.related_items.length).to eq(1)
      expect(subject.related_items.first).to eq(
        "relatedItemType"=>"Presentation",
        "relationType"=>"IsCitedBy",
        "relationTypeInformation" => "Free text 2 - relationTypeInformation",
        "relatedItemIdentifier" => {
          "relatedItemIdentifier" => "10.82523/hnhr-r562",
          "relatedItemIdentifierType" => "SWHID"
        }
      )

      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_related_items(xml) }.to_xml
      response = Maremma.from_xml(xml)

      expect(response.dig(
        "relatedItems",
        "relatedItem",
        "relationTypeInformation"
      )).to eq("Free text 2 - relationTypeInformation")
    end
  end
end
