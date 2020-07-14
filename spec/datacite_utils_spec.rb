# frozen_string_literal: true

require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  let(:input) { "https://doi.org/10.5061/DRYAD.8515" }

  subject { Bolognese::Metadata.new(input, from: "datacite") }

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
      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_subjects(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response.dig("subjects", "subject")).to eq(["Plasmodium", "malaria", "taxonomy", "mitochondrial genome", "phylogeny", "Parasites"])
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
    
    subject { Bolognese::Metadata.new(input, from: "datacite") }

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
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"10.1371/journal.ppat.1000446", "relatedIdentifierType"=>"DOI", "relationType"=>"IsSupplementTo")
    end

    it "insert" do
      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_related_identifiers(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response.dig("relatedIdentifiers", "relatedIdentifier")).to eq("__content__"=>"10.1371/journal.ppat.1000446", "relatedIdentifierType"=>"DOI", "relationType"=>"IsSupplementTo")
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
      subject = Bolognese::Metadata.new(input, from: "datacite")
      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| subject.insert_descriptions(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response.dig("descriptions", "description")).to eq("descriptionType" => "Abstract", "__content__" => "Eating your own dog food is a slang term to describe that an organization should itself use the products and services it provides. For DataCite this means that we should use DOIs with appropriate metadata and strategies for long-term preservation for...")
    end
  end
end
