# frozen_string_literal: true

require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  let(:input) { fixture_path + "datacite.json" }

  subject { Bolognese::Metadata.new(input: input) }

  context "get datacite_json raw" do
    it "BlogPosting" do
      expect(subject.raw).to eq(IO.read(input).strip)
    end
  end

  context "get datacite_json metadata" do
    it "BlogPosting" do
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"BlogPosting", "resourceTypeGeneral"=>"Text", "ris"=>"RPRT", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators).to eq([{"type"=>"Person", "id"=>"http://orcid.org/0000-0003-1419-2405", "name"=>"Fenner, Martin", "givenName"=>"Martin", "familyName"=>"Fenner"}])
      expect(subject.titles).to eq([{"title"=>"Eating your own Dog Food"}])
      expect(subject.alternate_identifiers).to eq([{"alternateIdentifier"=>"MS-49-3632-5083", "alternateIdentifierType"=>"Local accession number"}])
      expect(subject.dates).to eq([{"date"=>"2016-12-20", "dateType"=>"Created"}, {"date"=>"2016-12-20", "dateType"=>"Issued"}, {"date"=>"2016-12-20", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2016")
      expect(subject.related_identifiers.length).to eq(3)
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"10.5438/0000-00ss", "relatedIdentifierType"=>"DOI", "relationType"=>"IsPartOf")
      expect(subject.related_identifiers.last).to eq("relatedIdentifier"=>"10.5438/55e5-t5c0", "relatedIdentifierType"=>"DOI", "relationType"=>"References")
      expect(subject.agency).to eq("DataCite")
    end

    # it "SoftwareSourceCode" do
    #   input = fixture_path + "datacite_software.json"
    #   subject = Bolognese::Metadata.new(input: input, from: "datacite_json")
    #   expect(subject.valid?).to be true
    #   expect(subject.identifier).to eq("https://doi.org/10.5063/f1m61h5x")
    #   expect(subject.types).to eq("bibtex"=>"misc", "citeproc"=>"article", "resource_type"=>"Software", "resource_type_general"=>"Software", "ris"=>"COMP", "type"=>"SoftwareSourceCode")
    #   expect(subject.creators).to eq([{"familyName"=>"Jones", "givenName"=>"Matthew B.", "name"=>"Matthew B. Jones", "type"=>"Person"}])
    #   expect(subject.titles).to eq([{"title"=>"dataone: R interface to the DataONE network of data repositories"}])
    #   expect(subject.dates).to eq([{"date"=>"2016", "date_type"=>"Issued"}])
    #   expect(subject.publication_year).to eq("2016")
    #   expect(subject.publisher).to eq("KNB Data Repository")
    #   expect(subject.agency).to eq("DataCite")
    # end

    it "SoftwareSourceCode missing_comma" do
      input = fixture_path + "datacite_software_missing_comma.json"
      subject = Bolognese::Metadata.new(input: input, from: "datacite_json")
      expect(subject.valid?).to be false
      expect(subject.errors).to eq(["expected comma, not a string at line 4, column 11 [parse.c:381]"])
      expect(subject.codemeta).to be_nil
    end

    it "SoftwareSourceCode overlapping_keys" do
      input = fixture_path + "datacite_software_overlapping_keys.json"
      subject = Bolognese::Metadata.new(input: input, from: "datacite_json")
      expect(subject.valid?).to be false
      expect(subject.errors).to eq(["The same key is defined more than once: id"])
      expect(subject.codemeta).to be_nil
    end
  end
end
