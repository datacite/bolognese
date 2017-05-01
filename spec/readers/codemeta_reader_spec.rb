require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  let(:fixture_path) { "spec/fixtures/" }
  let(:input) { "https://github.com/datacite/maremma" }

  subject { Bolognese::Metadata.new(input: input) }

  context "get codemeta metadata" do
    it "maremma" do
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.5438/qeg0-3gm3")
      expect(subject.url).to eq("https://github.com/datacite/maremma")
      expect(subject.type).to eq("SoftwareSourceCode")
      expect(subject.author).to eq("type"=>"Person", "id"=>"http://orcid.org/0000-0003-0077-4738", "name"=>"Martin Fenner", "givenName"=>"Martin", "familyName"=>"Fenner")
      expect(subject.title).to eq("Maremma: a Ruby library for simplified network calls")
      expect(subject.description["text"]).to start_with("Ruby utility library for network requests")
      expect(subject.keywords).to eq("faraday, excon, net/http")
      expect(subject.date_created).to eq("2015-11-28")
      expect(subject.date_published).to eq("2017-02-24")
      expect(subject.date_modified).to eq("2017-02-24")
      expect(subject.publisher).to eq("DataCite")
    end
  end
end
