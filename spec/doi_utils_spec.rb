# frozen_string_literal: true

require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  let(:input) { "https://doi.org/10.1101/097196" }

  subject { Bolognese::Metadata.new(input: input, from: "crossref") }

  context "doi resolver" do
    it "doi" do
      doi = "10.5061/DRYAD.8515"
      response = subject.doi_resolver(doi)
      expect(response).to eq("https://doi.org/")
    end

    it "doi with protocol" do
      doi = "doi:10.5061/DRYAD.8515"
      response = subject.doi_resolver(doi)
      expect(response).to eq("https://doi.org/")
    end

    it "https url" do
      doi = "https://doi.org/10.5061/dryad.8515"
      response = subject.doi_resolver(doi)
      expect(response).to eq("https://doi.org/")
    end

    it "dx.doi.org url" do
      doi = "http://dx.doi.org/10.5061/dryad.8515"
      response = subject.doi_resolver(doi)
      expect(response).to eq("https://doi.org/")
    end

    it "test resolver" do
      doi = "https://handle.test.datacite.org/10.5061/dryad.8515"
      response = subject.doi_resolver(doi)
      expect(response).to eq("https://handle.test.datacite.org/")
    end

    it "test resolver http" do
      doi = "http://handle.test.datacite.org/10.5061/dryad.8515"
      response = subject.doi_resolver(doi)
      expect(response).to eq("https://handle.test.datacite.org/")
    end

    it "force test resolver" do
      doi = "https://doi.org/10.5061/dryad.8515"
      response = subject.doi_resolver(doi, sandbox: true)
      expect(response).to eq("https://handle.test.datacite.org/")
    end
  end

  context "doi_api_url" do
    it "doi" do
      doi = "10.5061/DRYAD.8515"
      response = subject.doi_api_url(doi)
      expect(response).to eq("https://api.datacite.org/dois/10.5061/dryad.8515")
    end

    it "doi with protocol" do
      doi = "doi:10.5061/DRYAD.8515"
      response = subject.doi_api_url(doi)
      expect(response).to eq("https://api.datacite.org/dois/10.5061/dryad.8515")
    end

    it "https url" do
      doi = "https://doi.org/10.5061/dryad.8515"
      response = subject.doi_api_url(doi)
      expect(response).to eq("https://api.datacite.org/dois/10.5061/dryad.8515")
    end

    it "dx.doi.org url" do
      doi = "http://dx.doi.org/10.5061/dryad.8515"
      response = subject.doi_api_url(doi)
      expect(response).to eq("https://api.datacite.org/dois/10.5061/dryad.8515")
    end

    it "test resolver" do
      doi = "https://handle.test.datacite.org/10.5061/dryad.8515"
      response = subject.doi_api_url(doi)
      expect(response).to eq("https://api.test.datacite.org/dois/10.5061/dryad.8515")
    end

    it "test resolver http" do
      doi = "http://handle.test.datacite.org/10.5061/dryad.8515"
      response = subject.doi_api_url(doi)
      expect(response).to eq("https://api.test.datacite.org/dois/10.5061/dryad.8515")
    end

    it "force test resolver" do
      doi = "https://doi.org/10.5061/dryad.8515"
      response = subject.doi_api_url(doi, sandbox: true)
      expect(response).to eq("https://api.test.datacite.org/dois/10.5061/dryad.8515")
    end
  end

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

    it "url with one slash" do
      doi = "https:/doi.org/10.5061/dryad.8515"
      response = subject.normalize_doi(doi)
      expect(response).to eq("https://doi.org/10.5061/dryad.8515")
    end

    it "doi from datacite sandbox" do
      doi = "https://handle.test.datacite.org/10.5438/55e5-t5c0"
      response = subject.normalize_doi(doi)
      expect(response).to eq("https://handle.test.datacite.org/10.5438/55e5-t5c0")
    end

    it "doi force datacite sandbox" do
      doi = "10.5438/55e5-t5c0"
      response = subject.normalize_doi(doi, sandbox: true)
      expect(response).to eq("https://handle.test.datacite.org/10.5438/55e5-t5c0")
    end
  end

  context "doi_from_url" do
    it "url" do
      doi = subject.doi_from_url("https://doi.org/10.5061/dryad.8515")
      expect(doi).to eq("10.5061/dryad.8515")
    end

    it "doi" do
      doi = subject.doi_from_url("10.5061/dryad.8515")
      expect(doi).to eq("10.5061/dryad.8515")
    end

    it "doi with special characters" do
      doi = subject.doi_from_url("10.5067/terra+aqua/ceres/cldtyphist_l3.004")
      expect(doi).to eq("10.5067/terra+aqua/ceres/cldtyphist_l3.004")
    end

    it "not a doi" do
      doi = subject.doi_from_url("https://doi.org/10.5061")
      expect(doi).to be nil
    end

    it "sandbox url" do
      doi = subject.doi_from_url("https://handle.test.datacite.org/10.5438/55e5-t5c0")
      expect(doi).to eq("10.5438/55e5-t5c0")
    end
  end

  context "doi registration agency" do
    it "datacite" do
      doi = "https://doi.org/10.5061/dryad.8515"
      response = subject.get_doi_ra(doi)
      expect(response).to eq("DataCite")
    end

    it "crossref" do
      doi = "10.1371/journal.pone.0000030"
      response = subject.get_doi_ra(doi)
      expect(response).to eq("Crossref")
    end

    it "medra" do
      doi = "https://doi.org/10.1392/roma081203"
      response = subject.get_doi_ra(doi)
      expect(response).to eq("mEDRA")
    end

    it "kisti" do
      doi = "https://doi.org/10.5012/bkcs.2013.34.10.2889"
      response = subject.get_doi_ra(doi)
      expect(response).to eq("KISTI")
    end

    it "jalc" do
      doi = "https://doi.org/10.11367/grsj1979.12.283"
      response = subject.get_doi_ra(doi)
      expect(response).to eq("JaLC")
    end

    it "op" do
      doi = "https://doi.org/10.2791/81962"
      response = subject.get_doi_ra(doi)
      expect(response).to eq("OP")
    end

    it "not a valid prefix" do
      doi = "https://doi.org/10.a/dryad.8515x"
      response = subject.get_doi_ra(doi)
      expect(response).to be_nil
    end

    it "not found" do
      doi = "https://doi.org/10.99999/dryad.8515x"
      response = subject.get_doi_ra(doi)
      expect(response).to be_nil
    end
  end

  context "validate prefix" do
    it "doi" do
      doi = "10.5061/dryad.8515"
      response = subject.validate_prefix(doi)
      expect(response).to eq("10.5061")
    end

    it "doi with protocol" do
      doi = "doi:10.5061/dryad.8515"
      response = subject.validate_prefix(doi)
      expect(response).to eq("10.5061")
    end

    it "doi as url" do
      doi = "https://doi.org/10.5061/dryad.8515"
      response = subject.validate_prefix(doi)
      expect(response).to eq("10.5061")
    end

    it "only prefix" do
      doi = "10.5061"
      response = subject.validate_prefix(doi)
      expect(response).to eq("10.5061")
    end
  end
end
