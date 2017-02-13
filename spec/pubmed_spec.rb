require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  context "pubmed metadata" do
    before(:each) { allow(Time).to receive(:now).and_return(Time.mktime(2015, 6, 25)) }

    let(:pmid) { "17183658" }

    it "get_pubmed_metadata" do
      response = subject.get_pubmed_metadata(pmid)
      expect(response["pmid"]).to eq(pmid)
      expect(response["title"]).to eq("Triose phosphate isomerase deficiency is caused by altered dimerization--not catalytic inactivity--of the mutant enzymes")
      expect(response["container-title"]).to eq("PLoS One")
      expect(response["issued"]).to eq("2006")
      expect(response["type"]).to eq("article-journal")
      expect(response["publisher_id"]).to be_nil
    end

    it "get_pubmed_metadata with not found error" do
      ids = { "pmcid" => "PMC1762313", "pmid" => "17183658", "doi" => "10.1371/journal.pone.0000030", "versions" => [{ "pmcid" => "PMC1762313.1", "current" => "true" }] }
      response = subject.get_pubmed_metadata("#{pmid}x")
      expect(response).to eq(error: "Resource not found.", status: 404)
    end
  end
end
