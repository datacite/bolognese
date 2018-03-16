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
      expect(subject.id).to eq("https://doi.org/10.7554/elife.01567")
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
      expect(subject.id).to eq("https://doi.org/10.7554/elife.01567")
      expect(subject.type).to eq("ScholarlyArticle")
      expect(subject.b_url).to eq("http://elifesciences.org/lookup/doi/10.7554/eLife.01567")
      expect(subject.resource_type_general).to eq("Text")
      expect(subject.author.length).to eq(5)
      expect(subject.author.first).to eq("type"=>"Person", "name"=>"Martial Sankar", "givenName"=>"Martial", "familyName"=>"Sankar")
      expect(subject.title).to eq("Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
      expect(subject.description["text"]).to start_with("Among various advantages, their small size makes model organisms preferred subjects of investigation.")
      expect(subject.license["id"]).to eq("http://creativecommons.org/licenses/by/3.0/")
      expect(subject.date_published).to eq("2014")
      expect(subject.is_part_of).to eq("type"=>"Periodical", "title"=>"eLife", "issn"=>"2050-084X")
    end
  end
end
