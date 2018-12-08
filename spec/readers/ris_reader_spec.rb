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
      expect(subject.types).to eq("citeproc"=>"misc", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.url).to eq("http://elifesciences.org/lookup/doi/10.7554/eLife.01567")
      expect(subject.creators.length).to eq(5)
      expect(subject.creators.first).to eq("type"=>"Person",
                                         "name"=>"Martial Sankar",
                                         "givenName"=>"Martial",
                                         "familyName"=>"Sankar")
      expect(subject.titles).to eq([{"title"=>"Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth"}])
      expect(subject.descriptions.first["description"]).to start_with("Among various advantages, their small size makes model organisms preferred subjects of investigation.")
      expect(subject.dates).to eq([{"date"=>"2014", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2014")
      expect(subject.related_identifiers).to eq([{"id"=>"2050084X", "relatedIdentifierType"=>"ISSN", "relationType"=>"IsPartOf", "title"=>"eLife", "type"=>"Periodical"}])
      expect(subject.container).to eq("identifier"=>"2050084X", "title"=>"eLife", "type"=>"Journal", "volume"=>"3")
    end

    it "DOI does not exist" do
      input = fixture_path + "pure.ris"
      doi = "10.7554/elife.01567"
      subject = Bolognese::Metadata.new(input: input, doi: doi)
      expect(subject.valid?).to be false
      expect(subject.state).to eq("not_found")
      expect(subject.identifier).to eq("https://doi.org/10.7554/elife.01567")
      expect(subject.types).to eq("citeproc"=>"misc", "resourceTypeGeneral"=>"Text", "ris"=>"THES", "schemaOrg"=>"Thesis")
      expect(subject.creators).to eq([{"type"=>"Person", "name"=>"Y. Toparlar", "givenName"=>"Y.", "familyName"=>"Toparlar"}])
      expect(subject.titles).to eq([{"title"=>"A multiscale analysis of the urban heat island effect"}])
      expect(subject.descriptions.first["description"]).to start_with("Designing the climates of cities")
      expect(subject.dates).to eq([{"date"=>"2018-04-25", "dateType"=>"Issued"}, {"date"=>"2018-04-25", "dateType"=>"Created"}])
      expect(subject.publication_year).to eq("2018")
    end
  end
end
