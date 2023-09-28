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
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"BlogPosting", "resourceTypeGeneral"=>"Text", "ris"=>"RPRT", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators).to eq([{"type"=>"Person", "id"=>"http://orcid.org/0000-0003-1419-2405", "name"=>"Fenner, Martin", "givenName"=>"Martin", "familyName"=>"Fenner"}])
      expect(subject.publisher).to eq({"name"=>"DataCite"})
      expect(subject.titles).to eq([{"title"=>"Eating your own Dog Food"}])
      expect(subject.identifiers).to eq([{"identifier"=>"https://doi.org/10.5438/4k3m-nyvg", "identifierType"=>"DOI"}, {"identifier"=>"MS-49-3632-5083", "identifierType"=>"Local accession number"}])
      expect(subject.dates).to eq([{"date"=>"2016-12-20", "dateType"=>"Created"}, {"date"=>"2016-12-20", "dateType"=>"Issued"}, {"date"=>"2016-12-20", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2016")
      expect(subject.related_identifiers.length).to eq(3)
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"10.5438/0000-00ss", "relatedIdentifierType"=>"DOI", "relationType"=>"IsPartOf")
      expect(subject.related_identifiers.last).to eq("relatedIdentifier"=>"10.5438/55e5-t5c0", "relatedIdentifierType"=>"DOI", "relationType"=>"References")
      expect(subject.agency).to eq("datacite")
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
      subject = Bolognese::Metadata.new(input: input, from: "datacite_json", show_errors: true)
      expect(subject.valid?).to be false
      expect(subject.errors.first).to include("expected comma, not a string (after doi)")
      expect(subject.codemeta).to be_nil
    end

    it "SoftwareSourceCode overlapping_keys" do
      input = fixture_path + "datacite_software_overlapping_keys.json"
      subject = Bolognese::Metadata.new(input: input, from: "datacite_json", show_errors: true)
      expect(subject.valid?).to be false
      expect(subject.errors).to eq(["The same key is defined more than once: id"])
      expect(subject.codemeta).to be_nil
    end

    it "metadata from api" do
      input = "10.5281/zenodo.28518"
      subject = Bolognese::Metadata.new(input: input, regenerate: true)
      expect(subject.valid?).to be true
      expect(subject.types).to eq("bibtex"=>"misc", "citeproc"=>"article", "resourceTypeGeneral"=>"Software", "ris"=>"COMP", "schemaOrg"=>"SoftwareSourceCode")
      expect(subject.creators.length).to eq(2)
      expect(subject.creators.first).to eq("affiliation"=>[{"name"=>"University of Washington"}], "familyName"=>"Vanderplas", "givenName"=>"Jake", "name"=>"Vanderplas, Jake", "nameIdentifiers"=>[], "nameType"=>"Personal")
      expect(subject.publisher).to eq({"name"=>"Zenodo"})
      expect(subject.titles).to eq([{"title"=>"Supersmoother: Minor Bug Fix Release"}])
      expect(subject.id).to eq("https://doi.org/10.5281/zenodo.28518")
      expect(subject.identifiers).to eq([{"identifier"=>"https://zenodo.org/record/28518", "identifierType"=>"URL"}])
      expect(subject.dates).to eq([{"date"=>"2015-08-19", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2015")
      expect(subject.version_info).to eq("v0.3.2")
      expect(subject.datacite).to include("<version>v0.3.2</version>")
      expect(subject.related_identifiers.length).to eq(2)
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"https://github.com/jakevdp/supersmoother/tree/v0.3.2", "relatedIdentifierType"=>"URL", "relationType"=>"IsSupplementTo")
      expect(subject.agency).to eq("datacite")
    end
  end
end
