# frozen_string_literal: true

require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  context "write metadata as crossref" do
    it "journal article" do
      input = fixture_path + 'crossref.xml'
      subject = Bolognese::Metadata.new(input: input)
      crossref = Maremma.from_xml(subject.crossref).dig("crossref_result", "query_result", "body", "query", "doi_record")
      expect(crossref.dig("crossref", "journal", "journal_metadata", "full_title")).to eq("eLife")
      expect(crossref.dig("crossref", "journal", "journal_article", "doi_data", "doi")).to eq("10.7554/eLife.01567")
    end

    it "from DataCite" do
      input = "https://doi.org/10.5061/DRYAD.8515"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      expect(subject.crossref).to be nil
    end
  end
end
