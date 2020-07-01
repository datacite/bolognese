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
      expect(subject.identifiers).to eq([{"identifier"=>"https://doi.org/10.7554/elife.01567", "identifierType"=>"DOI"}])
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
      expect(subject.identifiers).to eq([{"identifier"=>"https://doi.org/10.7554/elife.01567", "identifierType"=>"DOI"}])
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceTypeGeneral"=>"Text", "resourceType"=>"JournalArticle", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.url).to eq("http://elifesciences.org/lookup/doi/10.7554/eLife.01567")
      expect(subject.creators.length).to eq(5)
      expect(subject.creators.first).to eq("familyName"=>"Sankar", "givenName"=>"Martial", "name"=>"Sankar, Martial", "nameType"=>"Personal")
      expect(subject.titles).to eq([{"title"=>"Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth"}])
      expect(subject.descriptions.first["description"]).to start_with("Among various advantages, their small size makes model organisms preferred subjects of investigation.")
      expect(subject.rights_list).to eq([{"rights"=>"Creative Commons Attribution 3.0 Unported",
        "rightsIdentifier"=>"cc-by-3.0",
        "rightsIdentifierScheme"=>"SPDX",
        "rightsUri"=>"https://creativecommons.org/licenses/by/3.0/legalcode",
        "schemeUri"=>"https://spdx.org/licenses/"}])
      expect(subject.dates).to eq([{"date"=>"2014", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2014")
      expect(subject.related_identifiers).to eq([{"relatedIdentifier"=>"2050-084X", "relatedIdentifierType"=>"ISSN", "relationType"=>"IsPartOf", "title"=>"eLife", "type"=>"Periodical"}])
    end

    it "DOI does not exist" do
      input = fixture_path + "pure.bib"
      doi = "10.7554/elife.01567"
      subject = Bolognese::Metadata.new(input: input, doi: doi)
      expect(subject.valid?).to be false
      expect(subject.state).to eq("not_found")
      expect(subject.identifiers).to eq([{"identifier"=>"https://doi.org/10.7554/elife.01567", "identifierType"=>"DOI"}])
      expect(subject.types).to eq("bibtex"=>"phdthesis", "citeproc"=>"thesis", "resourceTypeGeneral"=>"Text", "resourceType"=>"Dissertation", "ris"=>"THES", "schemaOrg"=>"Thesis")
      expect(subject.creators).to eq([{"familyName"=>"Toparlar", "givenName"=>"Y.", "name"=>"Toparlar, Y.", "nameType"=>"Personal"}])
      expect(subject.titles).to eq([{"title"=>"A multiscale analysis of the urban heat island effect: from city averaged temperatures to the energy demand of individual buildings"}])
      expect(subject.descriptions.first["description"]).to start_with("Designing the climates of cities")
      expect(subject.dates).to eq([{"date"=>"2018", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2018")
    end
  end
end
