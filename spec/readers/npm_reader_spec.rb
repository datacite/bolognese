# frozen_string_literal: true

require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  let(:input) { fixture_path + "cgimp_package.json" }

  subject { Bolognese::Metadata.new(input: input, from: "npm") }

  context "get npm raw" do
    it "software" do
      expect(subject.raw).to eq(IO.read(input).strip)
    end
  end

  context "get npm metadata" do
    it "minimal" do
      expect(subject.valid?).to be false
      expect(subject.errors.first).to start_with("3:0: ERROR: Element '{http://datacite.org/schema/kernel-4}identifier'")
      #expect(subject.identifiers).to eq([{"identifier"=>"https://doi.org/10.5438/4k3m-nyvg", "identifierType"=>"DOI"}])
      #expect(subject.url).to eq("https://blog.datacite.org/eating-your-own-dog-food")
      expect(subject.types).to eq("bibtex"=>"misc", "citeproc"=>"article", "reourceType"=>"NPM Package", "resourceTypeGeneral"=>"Software", "ris"=>"GEN", "schemaOrg"=>"SoftwareSourceCode")
      expect(subject.creators).to eq([{"name"=>":(unav)", "nameType"=>"Organizational"}])
      expect(subject.titles).to eq([{"title"=>"fullstack_app"}])
      expect(subject.descriptions).to be_empty
      expect(subject.rights_list).to eq([{"rights"=>"ISC"}])
      expect(subject.version_info).to eq("1.0.0")
      #expect(subject.dates).to eq([{"date"=>"2016-12-20", "dateType"=>"Issued"}])
      #expect(subject.publication_year).to eq("2016")
    end

    it "minimal with description" do
      input = fixture_path + "cit_package.json"
      subject = Bolognese::Metadata.new(input: input, from: "npm") 
      expect(subject.valid?).to be false
      expect(subject.errors.first).to start_with("3:0: ERROR: Element '{http://datacite.org/schema/kernel-4}identifier'")
      #expect(subject.identifiers).to eq([{"identifier"=>"https://doi.org/10.5438/4k3m-nyvg", "identifierType"=>"DOI"}])
      #expect(subject.url).to eq("https://blog.datacite.org/eating-your-own-dog-food")
      expect(subject.types).to eq("bibtex"=>"misc", "citeproc"=>"article", "reourceType"=>"NPM Package", "resourceTypeGeneral"=>"Software", "ris"=>"GEN", "schemaOrg"=>"SoftwareSourceCode")
      expect(subject.creators).to eq([{"name"=>":(unav)", "nameType"=>"Organizational"}])
      expect(subject.titles).to eq([{"title"=>"CITapp"}])
      expect(subject.descriptions).to eq([{"description"=>"Concealed Information Test app", "descriptionType"=>"Abstract"}])
      expect(subject.version_info).to eq("1.1.0")
      #expect(subject.dates).to eq([{"date"=>"2016-12-20", "dateType"=>"Issued"}])
      #expect(subject.publication_year).to eq("2016")
    end

    it "minimal with description" do
      input = fixture_path + "edam_package.json"
      subject = Bolognese::Metadata.new(input: input, from: "npm") 
      expect(subject.valid?).to be false
      expect(subject.errors.first).to start_with("3:0: ERROR: Element '{http://datacite.org/schema/kernel-4}identifier'")
      #expect(subject.identifiers).to eq([{"identifier"=>"https://doi.org/10.5438/4k3m-nyvg", "identifierType"=>"DOI"}])
      #expect(subject.url).to eq("https://blog.datacite.org/eating-your-own-dog-food")
      expect(subject.types).to eq("bibtex"=>"misc", "citeproc"=>"article", "reourceType"=>"NPM Package", "resourceTypeGeneral"=>"Software", "ris"=>"GEN", "schemaOrg"=>"SoftwareSourceCode")
      expect(subject.creators).to eq([{"affiliation"=>[], "familyName"=>"Brancotte", "givenName"=>"Bryan", "name"=>"Brancotte, Bryan", "nameIdentifiers"=>[], "nameType"=>"Personal"}])
      expect(subject.titles).to eq([{"title"=>"edam-browser"}])
      expect(subject.descriptions).to eq([{"description"=>
        +   "The EDAM Browser is a client-side web-based visualization javascript widget. Its goals are to help describing bio-related resources and service with EDAM, and to facilitate and foster community contributions to EDAM.",
           "descriptionType"=>"Abstract"}])
      expect(subject.version_info).to eq("1.0.0")
      #expect(subject.dates).to eq([{"date"=>"2016-12-20", "dateType"=>"Issued"}])
      #expect(subject.publication_year).to eq("2016")
    end
  end
end
