require 'spec_helper'

describe Bolognese::Citeproc, vcr: true do
  let(:string) { IO.read(fixture_path + "citeproc.json") }

  subject { Bolognese::Citeproc.new(string: string) }

  context "get metadata" do
    it "BlogPosting" do
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(subject.type).to eq("BlogPosting")
      expect(subject.url).to eq("https://blog.datacite.org/eating-your-own-dog-food")
      expect(subject.resource_type_general).to eq("Text")
      expect(subject.author).to eq("type"=>"Person", "name"=>"Martin Fenner", "givenName"=>"Martin", "familyName"=>"Fenner")
      expect(subject.title).to eq("Eating your own Dog Food")
      expect(subject.description["text"]).to start_with("Eating your own dog food")
      expect(subject.date_published).to eq("2016-12-20")
      expect(subject.is_part_of).to eq("type"=>"Periodical", "name"=>"DataCite Blog")
    end
  end

  context "get metadata as datacite xml" do
    it "BlogPosting" do
      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.dig("resourceType", "resourceTypeGeneral")).to eq("Text")
      expect(datacite.dig("titles", "title")).to eq("Eating your own Dog Food")
      expect(datacite.dig("descriptions", "description", "__content__")).to start_with("Eating your own dog food")
      expect(datacite.dig("creators", "creator")).to eq("creatorName"=>"Fenner, Martin", "givenName"=>"Martin", "familyName"=>"Fenner")
    end
  end
end
