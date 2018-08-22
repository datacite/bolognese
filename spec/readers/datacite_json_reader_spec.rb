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
      expect(subject.type).to eq("ScholarlyArticle")
      expect(subject.additional_type).to eq("BlogPosting")
      expect(subject.resource_type_general).to eq("Text")
      expect(subject.author).to eq("type"=>"Person", "id"=>"http://orcid.org/0000-0003-1419-2405", "name"=>"Fenner, Martin", "givenName"=>"Martin", "familyName"=>"Fenner")
      expect(subject.title).to eq("Eating your own Dog Food")
      expect(subject.alternate_identifier).to eq("type"=>"Local accession number", "name"=>"MS-49-3632-5083")
      expect(subject.date_published).to eq("2016-12-20")
      expect(subject.is_part_of).to eq("id"=>"https://doi.org/10.5438/0000-00ss")
      expect(subject.references).to eq([{"id"=>"https://doi.org/10.5438/0012"}, {"id"=>"https://doi.org/10.5438/55e5-t5c0"}])
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
