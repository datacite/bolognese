require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  context "crossref metadata" do
    before(:each) { allow(Time).to receive(:now).and_return(Time.mktime(2015, 6, 25)) }

    let(:crossref_doi) { "10.1371/journal.pone.0000030" }

    it "get_crossref_metadata" do
      response = subject.get_crossref_metadata(crossref_doi)
      expect(response["DOI"]).to eq(crossref_doi)
      expect(response["title"]).to eq("Triose Phosphate Isomerase Deficiency Is Caused by Altered Dimerization–Not Catalytic Inactivity–of the Mutant Enzymes")
      expect(response["container-title"]).to eq("PLoS ONE")
      expect(response["author"]).to eq([{"given"=>"Markus", "family"=>"Ralser"}, {"given"=>"Gino", "family"=>"Heeren"}, {"given"=>"Michael", "family"=>"Breitenbach"}, {"given"=>"Hans", "family"=>"Lehrach"}, {"given"=>"Sylvia", "family"=>"Krobitsch"}])
      expect(response["issued"]).to eq("2006-12-20")
      expect(response["published"]).to eq("2006-12-20")
      expect(response["deposited"]).to eq("2017-01-01T03:37:08Z")
      expect(response["updated"]).to eq("2017-01-01T04:40:02Z")
      expect(response["resource_type_id"]).to eq("Text")
      expect(response["resource_type"]).to eq("journal-article")
      expect(response["publisher_id"]).to eq("340")
      expect(response["registration_agency_id"]).to eq("crossref")
    end

    it "get_crossref_metadata with SICI DOI" do
      doi = "10.1890/0012-9658(2006)87[2832:tiopma]2.0.co;2"
      response = subject.get_crossref_metadata(doi)
      expect(response["DOI"]).to eq(doi)
      expect(response["title"]).to eq("THE IMPACT OF PARASITE MANIPULATION AND PREDATOR FORAGING BEHAVIOR ON PREDATOR–PREY COMMUNITIES")
      expect(response["container-title"]).to eq("Ecology")
      expect(response["issued"]).to eq("2006-11")
      expect(response["published"]).to eq("2006-11")
      expect(response["deposited"]).to eq("2016-10-04T23:20:17Z")
      expect(response["updated"]).to eq("2016-11-28T12:49:49Z")
      expect(response["resource_type_id"]).to eq("Text")
      expect(response["resource_type"]).to eq("journal-article")
      expect(response["publisher_id"]).to eq("311")
    end

    it "get_crossref_metadata with date in future" do
      doi = "10.1016/j.ejphar.2015.03.018"
      response = subject.get_crossref_metadata(doi)
      expect(response["DOI"]).to eq(doi)
      expect(response["title"]).to eq("Paving the path to HIV neurotherapy: Predicting SIV CNS disease")
      expect(response["container-title"]).to eq("European Journal of Pharmacology")
      expect(response["issued"]).to eq("2016-11-02T20:32:47Z")
      expect(response["published"]).to eq("2015-07")
      expect(response["deposited"]).to eq("2016-08-20T08:19:38Z")
      expect(response["updated"]).to eq("2016-11-02T20:32:47Z")
      expect(response["resource_type_id"]).to eq("Text")
      expect(response["resource_type"]).to eq("journal-article")
      expect(response["publisher_id"]).to eq("78")
    end

    it "get_crossref_metadata with not found error" do
      ids = { "pmcid" => "PMC1762313", "pmid" => "17183658", "doi" => "10.1371/journal.pone.0000030", "versions" => [{ "pmcid" => "PMC1762313.1", "current" => "true" }] }
      response = subject.get_crossref_metadata("#{crossref_doi}x")
      expect(response).to eq(error: "Resource not found.", status: 404)
    end
  end
end
