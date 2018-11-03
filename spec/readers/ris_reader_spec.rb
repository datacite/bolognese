# frozen_string_literal: true

require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  let(:input) { fixture_path + "crossref.ris" }

  subject { Bolognese::Metadata.new(input: input) }

  context "detect format" do
    it "extension" do
      expect(subject.valid?).to be true
    end

    it "string" do
      Bolognese::Metadata.new(input: IO.read(input).strip)
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.7554/elife.01567")
    end
  end

  context "get ris raw" do
    it "Crossref DOI" do
      expect(subject.raw).to eq(IO.read(input).strip)
    end
  end

  context "get ris metadata" do
    it "Crossref DOI" do
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.7554/elife.01567")
      expect(subject.type).to eq("ScholarlyArticle")
      expect(subject.url).to eq("http://elifesciences.org/lookup/doi/10.7554/eLife.01567")
      expect(subject.resource_type_general).to eq("Text")
      expect(subject.creator.length).to eq(5)
      expect(subject.creator.first).to eq("type"=>"Person",
                                         "name"=>"Martial Sankar",
                                         "givenName"=>"Martial",
                                         "familyName"=>"Sankar")
      expect(subject.title).to eq("Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
      expect(subject.description["text"]).to start_with("Among various advantages, their small size makes model organisms preferred subjects of investigation.")
      expect(subject.date_published).to eq("2014")
      expect(subject.related_identifiers).to eq([{"id"=>"2050084X", "related_identifier_type"=>"ISSN", "relation_type"=>"IsPartOf", "title"=>"eLife", "type"=>"Periodical"}])
      expect(subject.periodical).to eq("id"=>"2050084X", "title"=>"eLife", "type"=>"Periodical")
    end

    it "DOI does not exist" do
      input = fixture_path + "pure.ris"
      doi = "10.7554/elife.01567"
      subject = Bolognese::Metadata.new(input: input, doi: doi)
      expect(subject.valid?).to be false
      expect(subject.state).to eq("not_found")
      expect(subject.identifier).to eq("https://doi.org/10.7554/elife.01567")
      expect(subject.ris_type).to eq("THES")
      expect(subject.type).to eq("Thesis")
      expect(subject.resource_type_general).to eq("Text")
      expect(subject.creator).to eq("type"=>"Person", "name"=>"Y. Toparlar", "givenName"=>"Y.", "familyName"=>"Toparlar")
      expect(subject.title).to eq("A multiscale analysis of the urban heat island effect")
      expect(subject.description["text"]).to start_with("Designing the climates of cities")
      expect(subject.date_published).to eq("2018-04-25")
    end
  end
end
