# frozen_string_literal: true

require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  let(:input) { "https://github.com/datacite/maremma" }

  subject { Bolognese::Metadata.new(input: input) }

  context "get codemeta raw" do
    it "rdataone" do
      input = fixture_path + 'codemeta.json'
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.raw).to eq(IO.read(input).strip)
    end
  end

  context "get codemeta metadata" do
    it "maremma" do
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.5438/qeg0-3gm3")
      expect(subject.url).to eq("https://github.com/datacite/maremma")
      expect(subject.type).to eq("SoftwareSourceCode")
      expect(subject.creator).to eq("type"=>"Person", "id"=>"http://orcid.org/0000-0003-0077-4738", "name"=>"Martin Fenner", "givenName"=>"Martin", "familyName"=>"Fenner")
      expect(subject.title).to eq("Maremma: a Ruby library for simplified network calls")
      expect(subject.description["text"]).to start_with("Ruby utility library for network requests")
      expect(subject.keywords).to eq(["faraday", "excon", "net/http"])
      expect(subject.dates).to eq("2015-11-28")
      expect(subject.date_published).to eq("2017-02-24")
      expect(subject.date_modified).to eq("2017-02-24")
      expect(subject.publisher).to eq("DataCite")
    end

    it "rdataone" do
      input = fixture_path + 'codemeta.json'
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.identifier).to eq("https://doi.org/10.5063/f1m61h5x")
      expect(subject.url).to eq("https://github.com/DataONEorg/rdataone")
      expect(subject.type).to eq("SoftwareSourceCode")
      expect(subject.creator).to eq( [{"type"=>"Person",
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
      expect(subject.keywords).to eq(["data sharing", "data repository", "DataONE"])
      expect(subject.version).to eq("2.0.0")
      expect(subject.dates).to eq("2016-05-27")
      expect(subject.date_published).to eq("2016-05-27")
      expect(subject.date_modified).to eq("2016-05-27")
      expect(subject.publisher).to eq("https://cran.r-project.org")
    end

    it "maremma" do
      input = fixture_path + 'maremma/codemeta.json'
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.5438/qeg0-3gm3")
      expect(subject.url).to eq("https://github.com/datacite/maremma")
      expect(subject.type).to eq("SoftwareSourceCode")
      expect(subject.creator).to eq("type"=>"Person", "id"=>"http://orcid.org/0000-0003-0077-4738", "name"=>"Martin Fenner", "givenName"=>"Martin", "familyName"=>"Fenner")
      expect(subject.title).to eq("Maremma: a Ruby library for simplified network calls")
      expect(subject.description["text"]).to start_with("Simplifies network calls")
      expect(subject.keywords).to eq(["faraday", "excon", "net/http"])
      expect(subject.dates).to eq("2015-11-28")
      expect(subject.date_published).to eq("2017-02-24")
      expect(subject.date_modified).to eq("2017-02-24")
      expect(subject.publisher).to eq("DataCite")
    end

    it "metadata_reports" do
      input = "https://github.com/datacite/metadata-reports/blob/master/software/codemeta.json"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.5438/wr0x-e194")
      expect(subject.url).to eq("https://github.com/datacite/metadata-reports")
      expect(subject.type).to eq("SoftwareSourceCode")
      expect(subject.creator.size).to eq(4)
      expect(subject.creator.last).to eq("type"=>"Person", "id"=>"https://orcid.org/0000-0001-8135-3489", "name"=>"Lars Holm Nielsen", "givenName"=>"Lars Holm", "familyName"=>"Nielsen")
      expect(subject.title).to eq("DOI Registrations for Software")
      expect(subject.description["text"]).to start_with("Analysis of DataCite DOIs registered for software")
      expect(subject.keywords).to eq(["doi", "software", "codemeta"])
      expect(subject.dates).to eq("2018-03-09")
      expect(subject.date_published).to eq("2018-05-17")
      expect(subject.date_modified).to eq("2018-05-17")
      expect(subject.publisher).to eq("DataCite")
    end
  end
end
