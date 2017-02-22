require 'spec_helper'

describe Bolognese::Metadata, vcr: true do

  subject { Bolognese::Metadata.new }

  context "find from format by ID" do
    it "crossref" do
      id = "https://doi.org/10.1371/journal.pone.0000030"
      expect(subject.find_from_format(id: id)).to eq("crossref")
    end

    it "crossref doi not url" do
      id = "10.1371/journal.pone.0000030"
      expect(subject.find_from_format(id: id)).to eq("crossref")
    end

    it "datacite" do
      id = "https://doi.org/10.5438/4K3M-NYVG"
      expect(subject.find_from_format(id: id)).to eq("datacite")
    end

    it "datacite doi http" do
      id = "http://doi.org/10.5438/4K3M-NYVG"
      expect(subject.find_from_format(id: id)).to eq("datacite")
    end

    it "orcid" do
      id = "http://orcid.org/0000-0002-0159-2197"
      expect(subject.find_from_format(id: id)).to eq("orcid")
    end

    it "schema_org" do
      id = "https://blog.datacite.org/eating-your-own-dog-food"
      expect(subject.find_from_format(id: id)).to eq("schema_org")
    end
  end

  context "find from format from file" do
    let(:file) { fixture_path + "crossref.bib" }

    it "bibtex" do
      string = IO.read(file)
      ext = File.extname(file)
      expect(subject.find_from_format(string: string, ext: ext)).to eq("bibtex")
    end

    it "crossref" do
      string = IO.read(fixture_path + "crossref.xml")
      expect(subject.find_from_format(string: string)).to eq("crossref")
    end

    it "datacite" do
      string = IO.read(fixture_path + "datacite.xml")
      expect(subject.find_from_format(string: string)).to eq("datacite")
    end
  end
end
