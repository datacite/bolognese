require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  let(:input) { fixture_path + "datacite.json" }

  subject { Bolognese::Metadata.new(input: input, from: "datacite_json") }

  context "get metadata as string" do
    it "BlogPosting" do
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(subject.type).to eq("ScholarlyArticle")
      expect(subject.additional_type).to eq("BlogPosting")
      expect(subject.resource_type_general).to eq("Text")
      expect(subject.author).to eq("type"=>"Person", "id"=>"http://orcid.org/0000-0003-1419-2405", "name"=>"Fenner, Martin", "givenName"=>"Martin", "familyName"=>"Fenner")
      expect(subject.title).to eq("Eating your own Dog Food")
      expect(subject.alternate_name).to eq("type"=>"Local accession number", "name"=>"MS-49-3632-5083")
      expect(subject.date_published).to eq("2016-12-20")
      expect(subject.is_part_of).to eq("id"=>"https://doi.org/10.5438/0000-00ss", "relationType"=>"IsPartOf")
      expect(subject.references).to eq([{"id"=>"https://doi.org/10.5438/0012", "relationType"=>"References"}, {"id"=>"https://doi.org/10.5438/55e5-t5c0", "relationType"=>"References"}])
      expect(subject.provider).to eq("DataCite")
    end
  end
end
