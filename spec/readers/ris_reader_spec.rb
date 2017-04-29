require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  let(:input) { fixture_path + "crossref.ris" }

  subject { Bolognese::Metadata.new(input: input) }

  context "get metadata" do
    it "Crossref DOI" do
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.7554/elife.01567")
      expect(subject.type).to eq("ScholarlyArticle")
      expect(subject.url).to eq("http://elifesciences.org/lookup/doi/10.7554/eLife.01567")
      expect(subject.resource_type_general).to eq("Text")
      expect(subject.author).to eq([{"@type"=>"Person", "givenName"=>"Martial", "familyName"=>"Sankar"},
                                    {"@type"=>"Person", "givenName"=>"Kaisa", "familyName"=>"Nieminen"},
                                    {"@type"=>"Person", "givenName"=>"Laura", "familyName"=>"Ragni"},
                                    {"@type"=>"Person", "givenName"=>"Ioannis", "familyName"=>"Xenarios"},
                                    {"@type"=>"Person", "givenName"=>"Christian S", "familyName"=>"Hardtke"}])
      expect(subject.title).to eq("Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
      expect(subject.description["text"]).to start_with("Among various advantages, their small size makes model organisms preferred subjects of investigation.")
      expect(subject.license["id"]).to eq("http://creativecommons.org/licenses/by/3.0/")
      expect(subject.date_published).to eq("2014")
      expect(subject.is_part_of).to eq("type"=>"Periodical", "name"=>"eLife", "issn"=>"2050-084X")
    end
  end
end
