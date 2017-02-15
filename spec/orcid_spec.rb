require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  # context "orcid metadata" do
  #   before(:each) { allow(Time).to receive(:now).and_return(Time.mktime(2015, 6, 25)) }

  #   let(:orcid) { "0000-0002-0159-2197" }

  #   it "get_orcid_metadata" do
  #     response = subject.get_orcid_metadata(orcid)
  #     expect(response["title"]).to eq("ORCID record for Jonathan A. Eisen")
  #     expect(response["container-title"]).to eq("ORCID Registry")
  #     expect(response["issued"]).to eq("2015")
  #     expect(response["type"]).to eq("entry")
  #     expect(response["URL"]).to eq("http://orcid.org/0000-0002-0159-2197")
  #   end

  #   it "get_orcid_metadata with not found error" do
  #     response = subject.get_orcid_metadata("#{orcid}x")
  #     expect(response).to eq("errors"=>"Resource not found.")
  #   end
  # end
end
