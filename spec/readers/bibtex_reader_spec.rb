# frozen_string_literal: true

require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  let(:input) { fixture_path + "crossref.bib" }

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

  context "get bibtex raw" do
    it "Crossref DOI" do
      expect(subject.raw).to eq(IO.read(input).strip)
    end
  end

  context "get bibtex metadata" do
    it "Crossref DOI" do
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.7554/elife.01567")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resource_type"=>"JournalArticle", "resource_type_general"=>"Text", "ris"=>"JOUR", "type"=>"ScholarlyArticle")
      expect(subject.url).to eq("http://elifesciences.org/lookup/doi/10.7554/eLife.01567")
      expect(subject.creator.length).to eq(5)
      expect(subject.creator.first).to eq("type"=>"Person", "name"=>"Martial Sankar", "givenName"=>"Martial", "familyName"=>"Sankar")
      expect(subject.title).to eq([{"text"=>"Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth"}])
      expect(subject.description.first["text"]).to start_with("Among various advantages, their small size makes model organisms preferred subjects of investigation.")
      expect(subject.rights.first["id"]).to eq("http://creativecommons.org/licenses/by/3.0/")
      expect(subject.dates).to eq([{"date"=>"2014", "date_type"=>"Issued"}])
      expect(subject.publication_year).to eq("2014")
      expect(subject.related_identifiers).to eq([{"id"=>"2050-084X", "related_identifier_type"=>"ISSN", "relation_type"=>"IsPartOf", "title"=>"eLife", "type"=>"Periodical"}])
    end

    it "DOI does not exist" do
      input = fixture_path + "pure.bib"
      doi = "10.7554/elife.01567"
      subject = Bolognese::Metadata.new(input: input, doi: doi)
      expect(subject.valid?).to be false
      expect(subject.state).to eq("not_found")
      expect(subject.identifier).to eq("https://doi.org/10.7554/elife.01567")
      expect(subject.types).to eq("bibtex"=>"phdthesis", "citeproc"=>"thesis", "resource_type"=>"Dissertation", "resource_type_general"=>"Text", "ris"=>"THES", "type"=>"Thesis")
      expect(subject.creator).to eq([{"type"=>"Person", "name"=>"Y. Toparlar", "givenName"=>"Y.", "familyName"=>"Toparlar"}])
      expect(subject.title).to eq([{"text"=>"A multiscale analysis of the urban heat island effect: from city averaged temperatures to the energy demand of individual buildings"}])
      expect(subject.description.first["text"]).to start_with("Designing the climates of cities")
      expect(subject.dates).to eq([{"date"=>"2018", "date_type"=>"Issued"}])
      expect(subject.publication_year).to eq("2018")
    end
  end
end
