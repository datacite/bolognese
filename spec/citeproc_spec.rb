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

  context "get metadata as ris" do
    it "BlogPosting" do
      ris = subject.ris.split("\r\n")
      expect(ris[0]).to eq("TY - GEN")
      expect(ris[1]).to eq("T1 - Eating your own Dog Food")
      expect(ris[2]).to eq("T2 - DataCite Blog")
      expect(ris[3]).to eq("AU - Fenner, Martin")
      expect(ris[4]).to eq("DO - 10.5438/4k3m-nyvg")
      expect(ris[5]).to eq("UR - https://blog.datacite.org/eating-your-own-dog-food")
      expect(ris[6]).to eq("AB - Eating your own dog food is a slang term to describe that an organization should itself use the products and services it provides. For DataCite this means that we should use DOIs with appropriate metadata and strategies for long-term preservation for...")
      expect(ris[7]).to eq("PY - 2016")
      expect(ris[8]).to eq("PB - DataCite")
      expect(ris[9]).to eq("ER - ")
    end
  end
end
