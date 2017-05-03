require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  let(:fixture_path) { "spec/fixtures/" }
  let(:input) { "https://github.com/datacite/maremma" }

  subject { Bolognese::Metadata.new(input: input) }

  context "get codemeta raw" do
    it "rdataone" do
      input = fixture_path + 'codemeta.json'
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.raw).to eq(IO.read(input))
    end
  end

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

    it "no codemeta.json" do
      input = "https://github.com/datacite/homepage"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.id).to be_nil
      expect(subject.exists?).to be false
    end

    it "not found error" do
      input = "https://github.com/datacite/x"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.id).to be_nil
      expect(subject.exists?).to be false
    end

    it "rdataone" do
      input = fixture_path + 'codemeta.json'
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.id).to eq("https://doi.org/10.5063/f1m61h5x")
      expect(subject.url).to eq("https://github.com/DataONEorg/rdataone")
      expect(subject.type).to eq("SoftwareSourceCode")
      expect(subject.author).to eq( [{"type"=>"Person",
                                      "id"=>"http://orcid.org/0000-0003-0077-4738",
                                      "name"=>"Matt Jones",
                                      "givenName"=>"Matt",
                                      "familyName"=>"Jones"},
                                     {"type"=>"Person",
                                      "id"=>"http://orcid.org/0000-0002-2192-403X",
                                      "name"=>"Peter Slaughter",
                                      "givenName"=>"Peter",
                                      "familyName"=>"Slaughter"},
                                     {"type"=>"Organization", "name"=>"University Of California, Santa Barbara"}])
      expect(subject.title).to eq("R Interface to the DataONE REST API")
      expect(subject.description["text"]).to start_with("Provides read and write access to data and metadata")
      expect(subject.keywords).to eq("data sharing, data repository, DataONE")
      expect(subject.version).to eq("2.0.0")
      expect(subject.date_created).to eq("2016-05-27")
      expect(subject.date_published).to eq("2016-05-27")
      expect(subject.date_modified).to eq("2016-05-27")
      expect(subject.publisher).to eq("https://cran.r-project.org")
    end

    it "maremma" do
      input = fixture_path + 'maremma/codemeta.json'
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.5438/qeg0-3gm3")
      expect(subject.url).to eq("https://github.com/datacite/maremma")
      expect(subject.type).to eq("SoftwareSourceCode")
      expect(subject.author).to eq("type"=>"Person", "id"=>"http://orcid.org/0000-0003-0077-4738", "name"=>"Martin Fenner", "givenName"=>"Martin", "familyName"=>"Fenner")
      expect(subject.title).to eq("Maremma: a Ruby library for simplified network calls")
      expect(subject.description["text"]).to start_with("Simplifies network calls")
      expect(subject.keywords).to eq("faraday, excon, net/http")
      expect(subject.date_created).to eq("2015-11-28")
      expect(subject.date_published).to eq("2017-02-24")
      expect(subject.date_modified).to eq("2017-02-24")
      expect(subject.publisher).to eq("DataCite")
    end
  end
end
