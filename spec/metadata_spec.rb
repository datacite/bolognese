# frozen_string_literal: true

require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  let(:input) { "http://doi.org/10.5438/4K3M-NYVG" }
  subject { Bolognese::Metadata.new(input: input) }

  context "handle input" do
    it "unknown DOI prefix" do
      input = "http://doi.org/10.0137/14802"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be false
      expect(subject.bibtex).to be_nil
    end

    it "DOI RA not Crossref or DataCite" do
      input = "http://doi.org/10.3980/j.issn.2222-3959.2015.03.07"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be false
      expect(subject.bibtex).to be_nil
    end
  end

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

    it "unknown DOI registration agency" do
      id = "http://doi.org/10.0137/14802"
      expect(subject.find_from_format(id: id)).to be_nil
    end

    it "orcid" do
      id = "http://orcid.org/0000-0002-0159-2197"
      expect(subject.find_from_format(id: id)).to eq("orcid")
    end

    it "github" do
      id = "https://github.com/datacite/maremma"
      expect(subject.find_from_format(id: id)).to eq("codemeta")
    end

    it "schema_org" do
      id = "https://blog.datacite.org/eating-your-own-dog-food"
      expect(subject.find_from_format(id: id)).to eq("schema_org")
    end
  end

  context "find from format from file" do
    it "bibtex" do
      file = fixture_path + "crossref.bib"
      string = IO.read(file)
      ext = File.extname(file)
      expect(subject.find_from_format(string: string, ext: ext)).to eq("bibtex")
    end

    it "ris" do
      file = fixture_path + "crossref.ris"
      string = IO.read(file)
      ext = File.extname(file)
      expect(subject.find_from_format(string: string, ext: ext)).to eq("ris")
    end

    it "crossref" do
      file = fixture_path + "crossref.xml"
      string = IO.read(file)
      ext = File.extname(file)
      expect(subject.find_from_format(string: string, ext: ext)).to eq("crossref")
    end

    it "datacite" do
      file = fixture_path + "datacite.xml"
      string = IO.read(file)
      ext = File.extname(file)
      expect(subject.find_from_format(string: string, ext: ext)).to eq("datacite")
    end

    it "datacite_json" do
      file = fixture_path + "datacite.json"
      string = IO.read(file)
      ext = File.extname(file)
      expect(subject.find_from_format(string: string, ext: ext)).to eq("datacite_json")
    end

    it "schema_org" do
      file = fixture_path + "schema_org.json"
      string = IO.read(file)
      ext = File.extname(file)
      expect(subject.find_from_format(string: string, ext: ext)).to eq("schema_org")
    end

    it "citeproc" do
      file = fixture_path + "citeproc.json"
      string = IO.read(file)
      ext = File.extname(file)
      expect(subject.find_from_format(string: string, ext: ext)).to eq("citeproc")
    end

    it "crosscite" do
      file = fixture_path + "crosscite.json"
      string = IO.read(file)
      ext = File.extname(file)
      expect(subject.find_from_format(string: string, ext: ext)).to eq("crosscite")
    end

    it "codemeta" do
      file = fixture_path + "codemeta.json"
      string = IO.read(file)
      ext = File.extname(file)
      expect(subject.find_from_format(string: string, ext: ext)).to eq("codemeta")
    end
  end

  context "find from format from string" do
    it "crosscite" do
      file = fixture_path + "crosscite.json"
      string = IO.read(file)
      expect(subject.find_from_format(string: string)).to eq("crosscite")
    end
  end

  context "jsonlint" do
    it "valid" do
      json = IO.read(fixture_path + "datacite_software.json")
      response = subject.jsonlint(json)
      expect(response).to be_empty
    end

    it "nil" do
      json = nil
      response = subject.jsonlint(json)
      expect(response).to eq(["No JSON provided"])
    end

    it "missing_comma" do
      json = IO.read(fixture_path + "datacite_software_missing_comma.json")
      response = subject.jsonlint(json)
      expect(response.first).to include("expected comma, not a string (after doi)")
    end

    it "overlapping_keys" do
      json = IO.read(fixture_path + "datacite_software_overlapping_keys.json")
      response = subject.jsonlint(json)
      expect(response).to eq(["The same key is defined more than once: id"])
    end
  end

  context "container"
    it "has provided container when present" do
      input = fixture_path + "datacite_with_container.json"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.container).to eq({
        "type" => "Series",
        "identifier" => "10.17605/OSF.IO/CEA94",
        "identifierType" => "DOI"
      })
    end

    it "has SeriesInformation when present" do
      input = fixture_path + "datacite_with_container_and_seriesinformation.json"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.container).to eq({
        "firstPage" => "firstpage",
        "identifier" => "10.5438/0000-00ss",
        "identifierType" => "DOI",
        "issue" => "issue",
        "lastPage" => "lastpage",
        "title" => "series title",
        "type" => "Series",
        "volume" => "volume"
      })
    end

    it "has relatedItem when present" do
      input = fixture_path + "datacite_with_container_and_seriesinformation_and_relateditem.json"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.container).to eq({
        "firstPage" => "50",
        "identifier" => "3034-834X",
        "identifierType" => "ISSN",
        "issue" => "1",
        "lastPage" => "60",
        "title" => "Understanding the fictional John Smith",
        "type" => "Series",
        "volume" => "776",
        "edition" => "1",
        "number" => "1",
        "chapterNumber" => "1"
      })
    end
end
