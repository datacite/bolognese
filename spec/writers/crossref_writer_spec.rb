require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  context "write metadata as crossref" do
    it "DOI with data citation" do
      input = "10.7554/eLife.01567"
      subject = Bolognese::Metadata.new(input: input)
      crossref = Maremma.from_xml(subject.crossref)
      expect(crossref).to eq("https://doi.org/10.7554/elife.01567")
      expect(metadata["url"]).to eq("http://elifesciences.org/lookup/doi/10.7554/eLife.01567")
      expect(metadata.type).to eq("ScholarlyArticle")
      expect(metadata.additional_type).to eq("JournalArticle")
      expect(subject.resource_type_general).to eq("Text")
      expect(subject.author.length).to eq(5)
      expect(subject.author.last).to eq("type"=>"Person", "name"=>"Christian S Hardtke", "givenName"=>"Christian S", "familyName"=>"Hardtke")
      expect(subject.license).to eq("url"=>"http://creativecommons.org/licenses/by/3.0/")
      expect(subject.title).to eq("Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
      expect(subject.date_published).to eq("2014-02-11")
      expect(subject.date_modified).to eq("2015-08-11T05:35:02Z")
      expect(subject.is_part_of).to eq("type"=>"Periodical", "name"=>"eLife", "issn"=>"2050-084X")
      expect(subject.references.count).to eq(27)
      expect(subject.references[21]).to eq("id"=>"https://doi.org/10.5061/dryad.b835k", "relationType"=>"Cites", "position"=>"22", "datePublished"=>"2014")
      expect(subject.provider).to eq("Crossref")
    end

    it "from DataCite" do
      input = "https://doi.org/10.5061/DRYAD.8515"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      expect(subject.crossref).to be nil
    end
  end
end
