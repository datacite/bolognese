require 'spec_helper'

describe Bolognese::Crossref, vcr: true do
  let(:id) { "https://doi.org/10.1371/journal.pone.0000030" }

  subject { Bolognese::Crossref.new(id: id) }

  context "validate url" do
    it "DOI" do
      str = "https://doi.org/10.5438/0000-00ss"
      response = subject.validate_url(str)
      expect(response).to eq("DOI")
    end

    it "URL" do
      str = "https://blog.datacite.org/eating-your-own-dog-food"
      response = subject.validate_url(str)
      expect(response).to eq("URL")
    end

    it "string" do
      str = "eating-your-own-dog-food"
      response = subject.validate_url(str)
      expect(response).to be_nil
    end
  end

  context "parse attributes" do
    it "string" do
      element = "10.5061/DRYAD.8515"
      response = subject.parse_attributes(element)
      expect(response).to eq("10.5061/DRYAD.8515")
    end

    it "hash" do
      element = { "__content__" => "10.5061/DRYAD.8515" }
      response = subject.parse_attributes(element)
      expect(response).to eq("10.5061/DRYAD.8515")
    end

    it "array" do
      element = [{ "__content__" => "10.5061/DRYAD.8515" }]
      response = subject.parse_attributes(element)
      expect(response).to eq("10.5061/DRYAD.8515")
    end

    it "nil" do
      element = nil
      response = subject.parse_attributes(element)
      expect(response).to be_nil
    end
  end

  context "normalize id" do
    it "doi" do
      doi = "10.5061/DRYAD.8515"
      response = subject.normalize_id(doi)
      expect(response).to eq("https://doi.org/10.5061/dryad.8515")
    end

    it "url" do
      url = "https://blog.datacite.org/eating-your-own-dog-food/"
      response = subject.normalize_id(url)
      expect(response).to eq("https://blog.datacite.org/eating-your-own-dog-food")
    end
  end

  context "normalize ids" do
    it "doi" do
      ids = [{"@type"=>"CreativeWork", "@id"=>"https://doi.org/10.5438/0012"}, {"@type"=>"CreativeWork", "@id"=>"https://doi.org/10.5438/55E5-T5C0"}]
      response = subject.normalize_ids(ids)
      expect(response).to eq([{"@type"=>"CreativeWork", "@id"=>"https://doi.org/10.5438/0012"}, {"@type"=>"CreativeWork", "@id"=>"https://doi.org/10.5438/55e5-t5c0"}])
    end

    it "url" do
      ids = [{"@type"=>"CreativeWork", "@id"=>"https://blog.datacite.org/eating-your-own-dog-food/"}]
      response = subject.normalize_ids(ids)
      expect(response).to eq([{"@type"=>"CreativeWork", "@id"=>"https://blog.datacite.org/eating-your-own-dog-food"}])
    end
  end
end
