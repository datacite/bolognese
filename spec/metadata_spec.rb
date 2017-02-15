require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  context "find PID service" do
    it "crossref" do
      id = "https://doi.org/10.1371/journal.pone.0000030"
      subject = Bolognese::Metadata.new(id)
      expect(subject.service).to eq("crossref")
    end

    it "crossref doi not url" do
      id = "10.1371/journal.pone.0000030"
      subject = Bolognese::Metadata.new(id)
      expect(subject.service).to eq("crossref")
    end

    it "datacite" do
      id = "https://doi.org/10.5438/4K3M-NYVG"
      subject = Bolognese::Metadata.new(id)
      expect(subject.service).to eq("datacite")
    end

    it "datacite doi http" do
      id = "http://doi.org/10.5438/4K3M-NYVG"
      subject = Bolognese::Metadata.new(id)
      expect(subject.service).to eq("datacite")
    end

    it "orcid" do
      id = "http://orcid.org/0000-0002-0159-2197"
      subject = Bolognese::Metadata.new(id)
      expect(subject.service).to eq("orcid")
    end
  end
end
