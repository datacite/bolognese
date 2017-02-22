require 'spec_helper'

describe Bolognese::Bibtex, vcr: true do
  let(:string) { IO.read(fixture_path + "crossref.bib") }

  subject { Bolognese::Bibtex.new(string: string) }

  context "get metadata" do
    it "Crossref DOI" do
      expect(subject.id).to eq("https://doi.org/10.7554/elife.01567")
      expect(subject.type).to eq("ScholarlyArticle")
      expect(subject.url).to eq("http://elifesciences.org/lookup/doi/10.7554/eLife.01567")
      expect(subject.resource_type_general).to eq("Text")
      expect(subject.author).to eq([{"@type"=>"Person", "givenName"=>"Martial", "familyName"=>"Sankar"},
                                    {"@type"=>"Person", "givenName"=>"Kaisa", "familyName"=>"Nieminen"},
                                    {"@type"=>"Person", "givenName"=>"Laura", "familyName"=>"Ragni"},
                                    {"@type"=>"Person", "givenName"=>"Ioannis", "familyName"=>"Xenarios"},
                                    {"@type"=>"Person", "givenName"=>"Christian S", "familyName"=>"Hardtke"}])
      expect(subject.name).to eq("Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
      expect(subject.description).to start_with("Among various advantages, their small size makes model organisms preferred subjects of investigation.")
      expect(subject.license).to eq("http://creativecommons.org/licenses/by/3.0/")
      expect(subject.date_published).to eq("2014")
      expect(subject.is_part_of).to eq("@type"=>"Periodical", "name"=>"eLife", "issn"=>"2050-084X")
    end
  end

  context "get metadata as datacite xml" do
    it "Crossref DOI" do
      expect(subject.validation_errors).to be_empty
      datacite = Maremma.from_xml(subject.as_datacite).fetch("resource", {})
      expect(datacite.dig("resourceType", "resourceTypeGeneral")).to eq("Text")
      expect(datacite.dig("titles", "title")).to eq("Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
      expect(datacite.dig("descriptions", "description", "__content__")).to start_with("Among various advantages, their small size makes model organisms preferred subjects of investigation.")
      expect(datacite.dig("creators", "creator").count).to eq(5)
      expect(datacite.dig("creators", "creator").first).to eq("creatorName"=>"Sankar, Martial", "givenName"=>"Martial", "familyName"=>"Sankar")
    end
  end
end
