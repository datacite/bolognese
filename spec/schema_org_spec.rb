require 'spec_helper'

describe Bolognese::SchemaOrg, vcr: true do
  context "get metadata" do
    let(:id) { "https://doi.org/10.5438/4K3M-NYVG" }

    subject { Bolognese::SchemaOrg.new(id: id) }

    it "BlogPosting" do
      expect(subject.id).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(subject.url).to eq("https://blog.datacite.org/eating-your-own-dog-food")
      expect(subject.type).to eq("BlogPosting")
      expect(subject.author).to eq([{"@type"=>"Person", "@id"=>"http://orcid.org/0000-0003-1419-2405", "givenName"=>"Martin", "familyName"=>"Fenner"}])
      expect(subject.name).to eq("Eating your own Dog Food")
      expect(subject.alternate_name).to eq("MS-49-3632-5083")
      expect(subject.description).to start_with("Eating your own dog food")
      expect(subject.date_published).to eq("2016-12-20")
      expect(subject.date_modified).to eq("2016-12-20")
      expect(subject.is_part_of).to eq("@type"=>"Blog", "@id"=>"https://doi.org/10.5438/0000-00ss", "name"=>"DataCite Blog")
      expect(subject.citation).to eq([{"@type"=>"CreativeWork", "@id"=>"https://doi.org/10.5438/0012"},
                                      {"@type"=>"CreativeWork", "@id"=>"https://doi.org/10.5438/55e5-t5c0"}])
    end

    it "not found error" do
      id = "https://doi.org/10.5438/4K3M-NYVGx"
      subject = Bolognese::SchemaOrg.new(id: id)
      expect(subject.id).to be_nil
      expect(subject.exists?).to be false
    end
  end
end
