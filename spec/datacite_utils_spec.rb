require 'spec_helper'

describe Bolognese::Datacite, vcr: true do
  let(:id) { "https://doi.org/10.5061/DRYAD.8515" }

  subject { Bolognese::Datacite.new(id: id) }

  context "insert_identifier" do
    it "doi" do
      xml = Nokogiri::XML::Builder.new { |xml| subject.insert_identifier(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response["identifier"]).to eq("identifierType"=>"DOI", "__content__"=>"10.5061/DRYAD.8515")
    end
  end

  context "insert_creators" do
    it "insert" do
      xml = Nokogiri::XML::Builder.new { |xml| subject.insert_creators(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response.dig("creators", "creator").first).to eq("creatorName"=>"Benjamin Ollomo", "givenName"=>"Benjamin", "familyName"=>"Ollomo")
    end
  end

  context "insert_contributors" do
    it "none" do
      xml = Nokogiri::XML::Builder.new { |xml| subject.insert_contributors(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response).to be_nil
    end
  end

  context "insert_person" do
    it "creator only name" do
      person = { "name" => "Carberry, Josiah" }
      type = "creator"
      xml = Nokogiri::XML::Builder.new { |xml| subject.insert_person(xml, person, type) }.to_xml
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
      xml = Nokogiri::XML::Builder.new { |xml| subject.insert_titles(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response.dig("titles", "title")).to eq("Data from: A new malaria agent in African hominids.")
    end
  end

  context "insert_publisher" do
    it "insert" do
      xml = Nokogiri::XML::Builder.new { |xml| subject.insert_publisher(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response["publisher"]).to eq("Dryad Digital Repository")
    end
  end

  context "insert_publication_year" do
    it "insert" do
      xml = Nokogiri::XML::Builder.new { |xml| subject.insert_publication_year(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response["publicationYear"]).to eq("2011")
    end
  end

  context "insert_resource_type" do
    it "insert" do
      xml = Nokogiri::XML::Builder.new { |xml| subject.insert_resource_type(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response["resourceType"]).to eq("resourceTypeGeneral"=>"Dataset", "__content__"=>"DataPackage")
    end
  end

  context "insert_alternate_identifiers" do
    it "insert" do
      xml = Nokogiri::XML::Builder.new { |xml| subject.insert_alternate_identifiers(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response.dig("alternateIdentifiers", "alternateIdentifier")).to eq("alternateIdentifierType"=>"citation", "__content__"=>"Ollomo B, Durand P, Prugnolle F, Douzery EJP, Arnathau C, Nkoghe D, Leroy E, Renaud F (2009) A new malaria agent in African hominids. PLoS Pathogens 5(5): e1000446.")
    end
  end

  context "insert_dates" do
    it "insert" do
      xml = Nokogiri::XML::Builder.new { |xml| subject.insert_dates(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response.dig("dates", "date")).to eq("dateType"=>"Issued", "__content__"=>"2011")
    end
  end

  context "insert_subjects" do
    it "insert" do
      xml = Nokogiri::XML::Builder.new { |xml| subject.insert_subjects(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response.dig("subjects", "subject")).to eq(["Phylogeny", "Malaria", "Parasites", "Taxonomy", "Mitochondrial genome", "Africa", "Plasmodium"])
    end
  end

  context "insert_version" do
    it "insert" do
      xml = Nokogiri::XML::Builder.new { |xml| subject.insert_version(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response.fetch("version", nil)).to eq("1")
    end
  end

  context "insert_related_identifiers" do
    it "rel_identifiers" do
      expect(subject.rel_identifiers).to eq([{"__content__"=>"https://doi.org/10.5061/dryad.8515/1",
                                              "related_identifier_type"=>"DOI",
                                              "relation_type"=>"HasPart"},
                                             {"__content__"=>"https://doi.org/10.5061/dryad.8515/2",
                                              "related_identifier_type"=>"DOI",
                                              "relation_type"=>"HasPart"},
                                             {"__content__"=>"https://doi.org/10.1371/journal.ppat.1000446",
                                              "related_identifier_type"=>"DOI",
                                              "relation_type"=>"References"}])
    end

    it "insert" do
      xml = Nokogiri::XML::Builder.new { |xml| subject.insert_related_identifiers(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response.dig("relatedIdentifiers", "relatedIdentifier")).to eq([{"relatedIdentifierType"=>"DOI",
                                                                              "relationType"=>"HasPart",
                                                                              "__content__"=>"https://doi.org/10.5061/dryad.8515/1"},
                                                                             {"relatedIdentifierType"=>"DOI",
                                                                              "relationType"=>"HasPart",
                                                                              "__content__"=>"https://doi.org/10.5061/dryad.8515/2"},
                                                                             {"relatedIdentifierType"=>"DOI",
                                                                              "relationType"=>"References",
                                                                              "__content__"=>"https://doi.org/10.1371/journal.ppat.1000446"}])
    end
  end

  context "insert_rights_list" do
    it "insert" do
      xml = Nokogiri::XML::Builder.new { |xml| subject.insert_rights_list(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response.dig("rightsList", "rights")).to eq("rightsURI"=>"http://creativecommons.org/publicdomain/zero/1.0/")
    end
  end

  context "insert_descriptions" do
    it "insert" do
      id = "https://doi.org/10.5438/4K3M-NYVG"
      subject = Bolognese::Datacite.new(id: id)
      xml = Nokogiri::XML::Builder.new { |xml| subject.insert_descriptions(xml) }.to_xml
      response = Maremma.from_xml(xml)
      expect(response.dig("descriptions", "description")).to eq("descriptionType" => "Abstract", "__content__" => "Eating your own dog food is a slang term to describe that an organization should itself use the products and services it provides. For DataCite this means that we should use DOIs with appropriate metadata and strategies for long-term preservation for...")
    end
  end
end
