require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  context "datacite metadata" do
    before(:each) { allow(Time).to receive(:now).and_return(Time.mktime(2015, 6, 25)) }

    let(:datacite_doi) { "10.5061/DRYAD.8515" }

    it "get_datacite_metadata" do
      response = subject.get_datacite_metadata(datacite_doi)
      expect(response["DOI"]).to eq(datacite_doi)
      expect(response["title"]).to eq("Data from: A new malaria agent in African hominids")
      expect(response["container-title"]).to eq("Dryad Digital Repository")
      expect(response["author"]).to eq([{"family"=>"Ollomo", "given"=>"Benjamin"}, {"family"=>"Durand", "given"=>"Patrick"}, {"family"=>"Prugnolle", "given"=>"Franck"}, {"family"=>"Douzery", "given"=>"Emmanuel J. P."}, {"family"=>"Arnathau", "given"=>"Céline"}, {"family"=>"Nkoghe", "given"=>"Dieudonné"}, {"family"=>"Leroy", "given"=>"Eric"}, {"family"=>"Renaud", "given"=>"François"}])
      expect(response["issued"]).to be_nil
      expect(response["published"]).to eq("2011")
      expect(response["deposited"]).to eq("2011-02-01T17:32:02Z")
      expect(response["updated"]).to eq("2017-02-04T17:54:39Z")
      expect(response["resource_type_id"]).to eq("Dataset")
      expect(response["resource_type"]).to eq("DataPackage")
      expect(response["publisher_id"]).to eq("CDL.DRYAD")
      expect(response["registration_agency_id"]).to eq("datacite")
    end

    it "get_datacite_metadata with not found error" do
      ids = { "pmcid" => "PMC1762313", "pmid" => "17183658", "doi" => "10.5061/dryad.8515", "versions" => [{ "pmcid" => "PMC1762313.1", "current" => "true" }] }
      response = subject.get_datacite_metadata("#{datacite_doi}x")
      expect(response).to eq(error: "Resource not found.", status: 404)
    end
  end
end
