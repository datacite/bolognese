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
      expect(subject.types).to eq("bibtex"=>"misc", "citeproc"=>"article", "ris"=>"GEN", "type"=>"CreativeWork")
      expect(subject.creator).to eq("type"=>"Person", "id"=>"http://orcid.org/0000-0003-1419-2405", "name"=>"Fenner, Martin", "givenName"=>"Martin", "familyName"=>"Fenner")
      expect(subject.title).to eq("Eating your own Dog Food")
      expect(subject.alternate_identifiers).to eq([{"alternate-identifier"=>"MS-49-3632-5083", "alternate-identifier-type"=>"Local accession number"}])
      expect(subject.dates).to eq([{"date"=>"2016-12-20", "date_type"=>"Created"}, {"date"=>"2016-12-20", "date_type"=>"Issued"}, {"date"=>"2016-12-20", "date_type"=>"Updated"}])
      expect(subject.publication_year).to eq("2016")
      expect(subject.related_identifiers.length).to eq(3)
      expect(subject.related_identifiers.first).to eq("id"=>"10.5438/0000-00ss", "related_identifier_type"=>"DOI", "relation_type"=>"IsPartOf")
      expect(subject.related_identifiers.last).to eq("id"=>"10.5438/55e5-t5c0", "related_identifier_type"=>"DOI", "relation_type"=>"References")
      expect(subject.service_provider).to eq("DataCite")
    end

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
