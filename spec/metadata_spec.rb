require 'spec_helper'

describe Bolognese::Metadata, vcr: true do

  subject { Bolognese::Metadata.new }

  context "find PID provider" do
    it "crossref" do
      id = "https://doi.org/10.1371/journal.pone.0000030"
      expect(subject.find_provider(id)).to eq("crossref")
    end

    it "crossref doi not url" do
      id = "10.1371/journal.pone.0000030"
      expect(subject.find_provider(id)).to eq("crossref")
    end

    it "datacite" do
      id = "https://doi.org/10.5438/4K3M-NYVG"
      expect(subject.find_provider(id)).to eq("datacite")
    end

    it "datacite doi http" do
      id = "http://doi.org/10.5438/4K3M-NYVG"
      expect(subject.find_provider(id)).to eq("datacite")
    end

    it "orcid" do
      id = "http://orcid.org/0000-0002-0159-2197"
      expect(subject.find_provider(id)).to eq("orcid")
    end

    it "schema_org" do
      id = "https://blog.datacite.org/eating-your-own-dog-food"
      expect(subject.find_provider(id)).to eq("schema_org")
    end
  end
end
