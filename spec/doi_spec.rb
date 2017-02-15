require 'spec_helper'

describe Bolognese::Crossref, vcr: true do
  let(:id) { "https://doi.org/10.1371/journal.pone.0000030" }

  subject { Bolognese::Crossref.new(id) }

  context "normalize doi" do
    it "doi" do
      doi = "10.5061/DRYAD.8515"
      response = subject.normalize_doi(doi)
      expect(response).to eq("https://doi.org/10.5061/dryad.8515")
    end

    it "doi with protocol" do
      doi = "doi:10.5061/DRYAD.8515"
      response = subject.normalize_doi(doi)
      expect(response).to eq("https://doi.org/10.5061/dryad.8515")
    end

    it "SICI doi" do
      doi = "10.1890/0012-9658(2006)87[2832:tiopma]2.0.co;2"
      response = subject.normalize_doi(doi)
      expect(response).to eq("https://doi.org/10.1890/0012-9658(2006)87%5B2832:tiopma%5D2.0.co;2")
    end

    it "https url" do
      doi = "https://doi.org/10.5061/dryad.8515"
      response = subject.normalize_doi(doi)
      expect(response).to eq("https://doi.org/10.5061/dryad.8515")
    end

    it "dx.doi.org url" do
      doi = "http://dx.doi.org/10.5061/dryad.8515"
      response = subject.normalize_doi(doi)
      expect(response).to eq("https://doi.org/10.5061/dryad.8515")
    end

    it "not valid doi prefix" do
      doi = "https://doi.org/20.5061/dryad.8515"
      response = subject.normalize_doi(doi)
      expect(response).to be_nil
    end

    it "doi prefix with string" do
      doi = "https://doi.org/10.506X/dryad.8515"
      response = subject.normalize_doi(doi)
      expect(response).to be_nil
    end

    it "doi prefix too long" do
      doi = "https://doi.org/10.506123/dryad.8515"
      response = subject.normalize_doi(doi)
      expect(response).to be_nil
    end

    it "doi from url without doi proxy" do
      doi = "https://handle.net/10.5061/dryad.8515"
      response = subject.normalize_doi(doi)
      expect(response).to be_nil
    end
  end

  context "doi registration agency" do
    it "datacite" do
      doi = "https://doi.org/10.5061/dryad.8515"
      response = subject.get_doi_ra(doi)
      expect(response["name"]).to eq("DataCite")
    end

    it "crossref" do
      doi = "https://doi.org/10.1371/journal.pone.0000030"
      response = subject.get_doi_ra(doi)
      expect(response["name"]).to eq("Crossref")
    end

    it "medra" do
      doi = "https://doi.org/10.1392/roma081203"
      response = subject.get_doi_ra(doi)
      expect(response["name"]).to eq("mEDRA")
    end

    it "not found" do
      doi = "https://doi.org/10.5061/dryad.8515x"
      response = subject.get_doi_ra(doi)
      expect(response["errors"]).to eq([{"DOI"=>"10.5061/DRYAD.8515X", "status"=>"Invalid DOI"}])
    end
  end
end
