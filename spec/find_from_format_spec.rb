# frozen_string_literal: true

require 'spec_helper'
require 'bolognese/cli'

describe Bolognese::CLI do
  context "find_from_format_by_id", vcr: true do
    let(:subject) do
      described_class.new
    end

    it "crossref" do
      id = "https://doi.org/10.7554/eLife.01567"
      expect(subject.find_from_format_by_id(id)).to eq("crossref")
    end

    it "datacite" do
      id = "https://doi.org/10.5061/DRYAD.8515"
      expect(subject.find_from_format_by_id(id)).to eq("datacite")
    end

    it "codemeta" do
      id = "https://github.com/datacite/maremma"
      expect(subject.find_from_format_by_id(id)).to eq("codemeta")
    end

    it "schema_org" do
      id = "https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/GAOC03"
      expect(subject.find_from_format_by_id(id)).to eq("schema_org")
    end
  end

  context "find_from_format_by_string" do
    let(:subject) do
      described_class.new
    end

    it "crossref" do
      string = IO.read(fixture_path + 'crossref.xml').strip
      expect(subject.find_from_format_by_string(string)).to eq("crossref")
    end

    it "datacite" do
      string = IO.read(fixture_path + 'datacite.xml').strip
      expect(subject.find_from_format_by_string(string)).to eq("datacite")
    end

    it "datacite namespaced" do
      string = IO.read(fixture_path + 'ns0.xml').strip
      expect(subject.find_from_format_by_string(string)).to eq("datacite")
    end

    it "codemeta" do
      string = IO.read(fixture_path + 'codemeta.json').strip
      expect(subject.find_from_format_by_string(string)).to eq("codemeta")
    end

    it "schema_org" do
      string = IO.read(fixture_path + 'schema_org.json').strip
      expect(subject.find_from_format_by_string(string)).to eq("schema_org")
    end

    it "ris" do
      string = IO.read(fixture_path + 'crossref.ris').strip
      expect(subject.find_from_format_by_string(string)).to eq("ris")
    end

    it "ris from pure" do
      string = IO.read(fixture_path + 'pure.ris').strip
      expect(subject.find_from_format_by_string(string)).to eq("ris")
    end

    it "bibtex" do
      string = IO.read(fixture_path + 'crossref.bib').strip
      expect(subject.find_from_format_by_string(string)).to eq("bibtex")
    end
  end
end
