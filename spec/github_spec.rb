require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  context "github metadata" do
    before(:each) { allow(Time).to receive(:now).and_return(Time.mktime(2015, 6, 25)) }

    let(:url) { "https://github.com/lagotto/lagotto" }

    it "get_github_metadata" do
      response = subject.get_github_metadata(url)
      expect(response["title"]).to eq("Tracking events around scholarly content")
      expect(response["container-title"]).to eq("Github")
      expect(response["issued"]).to eq("2012-05-02T22:07:40Z")
      expect(response["type"]).to eq("computer_program")
      expect(response["URL"]).to eq("https://github.com/lagotto/lagotto")
    end

    it "get_github_metadata with not found error" do
      response = subject.get_github_metadata("#{url}x")
      expect(response).to eq(:error=>"Resource not found.", :status=>404)
    end
  end
end
