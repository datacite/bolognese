require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  context "metadata" do
    before(:each) { allow(Time).to receive(:now).and_return(Time.mktime(2015, 6, 25)) }

    let(:crossref_doi) { "10.1371/journal.pone.0000030" }
    let(:datacite_doi) { "10.5438/4K3M-NYVG" }
    let(:pmid) { "17183658" }
    let(:orcid) { "0000-0002-0159-2197" }

    it "get_metadata crossref" do
      response = subject.get_metadata(id: crossref_doi, service: "crossref")
      expect(response["DOI"]).to eq(crossref_doi)
      expect(response["title"]).to eq("Triose Phosphate Isomerase Deficiency Is Caused by Altered Dimerization–Not Catalytic Inactivity–of the Mutant Enzymes")
      expect(response["container-title"]).to eq("PLoS ONE")
      expect(response["issued"]).to eq("2006-12-20")
      expect(response["published"]).to eq("2006-12-20")
      expect(response["deposited"]).to eq("2017-01-01T03:37:08Z")
      expect(response["updated"]).to eq("2017-01-01T04:40:02Z")
      expect(response["resource_type_id"]).to eq("Text")
      expect(response["resource_type"]).to eq("journal-article")
      expect(response["publisher_id"]).to eq("340")
      expect(response["registration_agency_id"]).to eq("crossref")
    end

    it "get_metadata datacite" do
      response = subject.get_metadata(id: datacite_doi, service: "datacite")
      expect(response["title"]).to eq("Eating your own Dog Food")
      expect(response["container-title"]).to eq("DataCite")
      expect(response["author"]).to eq([{"family"=>"Fenner", "given"=>"Martin", "ORCID"=>"http://orcid.org/0000-0003-1419-2405"}])
      expect(response["issued"]).to eq("2016-12-20")
      expect(response["published"]).to eq("2016")
      expect(response["deposited"]).to eq("2016-12-19T20:49:21Z")
      expect(response["updated"]).to eq("2017-01-09T13:53:12Z")
      expect(response["resource_type_id"]).to eq("Text")
      expect(response["resource_type"]).to eq("BlogPosting")
      expect(response["publisher_id"]).to eq("DATACITE.DATACITE")
      expect(response["registration_agency_id"]).to eq("datacite")
    end

    it "get_metadata pubmed" do
      response = subject.get_metadata(id: pmid, service: "pubmed")
      expect(response["pmid"]).to eq(pmid)
      expect(response["title"]).to eq("Triose phosphate isomerase deficiency is caused by altered dimerization--not catalytic inactivity--of the mutant enzymes")
      expect(response["container-title"]).to eq("PLoS One")
      expect(response["issued"]).to eq("2006")
      expect(response["type"]).to eq("article-journal")
      expect(response["publisher_id"]).to be_nil
    end

    it "get_metadata orcid" do
      response = subject.get_metadata(id: orcid, service: "orcid")
      expect(response["title"]).to eq("ORCID record for Jonathan A. Eisen")
      expect(response["container-title"]).to eq("ORCID Registry")
      expect(response["issued"]).to eq("2015")
      expect(response["type"]).to eq("entry")
      expect(response["URL"]).to eq("http://orcid.org/0000-0002-0159-2197")
    end

    it "get_metadata github" do
      url = "https://github.com/lagotto/lagotto"
      response = subject.get_metadata(id: url, service: "github")
      expect(response["title"]).to eq("Tracking events around scholarly content")
      expect(response["container-title"]).to eq("Github")
      expect(response["issued"]).to eq("2012-05-02T22:07:40Z")
      expect(response["type"]).to eq("computer_program")
      expect(response["URL"]).to eq("https://github.com/lagotto/lagotto")
    end

    it "get_metadata github_owner" do
      url = "https://github.com/lagotto"
      response = subject.get_metadata(id: url, service: "github_owner")
      expect(response["title"]).to eq("Github profile for Lagotto")
      expect(response["container-title"]).to eq("Github")
      expect(response["issued"]).to eq("2012-05-01T19:38:33Z")
      expect(response["type"]).to eq("entry")
      expect(response["URL"]).to eq("https://github.com/lagotto")
    end

    it "get_metadata github_release" do
      url = "https://github.com/lagotto/lagotto/tree/v.4.3"
      response = subject.get_metadata(id: url, service: "github_release")
      expect(response["title"]).to eq("Lagotto 4.3")
      expect(response["container-title"]).to eq("Github")
      expect(response["issued"]).to eq("2015-07-19T22:43:10Z")
      expect(response["type"]).to eq("computer_program")
      expect(response["URL"]).to eq("https://github.com/lagotto/lagotto/tree/v.4.3")
    end

    it "get_metadata github_release missing title and date" do
      url = "https://github.com/brian-j-smith/Mamba.jl/tree/v0.4.8"
      response = subject.get_metadata(id: url, service: "github_release")
      expect(response["title"]).to eq("Mamba 0.4.8")
      expect(response["container-title"]).to eq("Github")
      expect(response["issued"]).to eq("2015-05-21T01:52:37Z")
      expect(response["type"]).to eq("computer_program")
      expect(response["URL"]).to eq("https://github.com/brian-j-smith/Mamba.jl/tree/v0.4.8")
    end
  end
end
