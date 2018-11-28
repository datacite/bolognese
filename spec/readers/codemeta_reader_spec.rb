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
      expect(subject.types).to eq("bibtex"=>"misc", "citeproc"=>"article-journal", "resourceTypeGeneral"=>"Software", "ris"=>"COMP", "schemaOrg"=>"SoftwareSourceCode")
      expect(subject.creator).to eq([{"type"=>"Person", "id"=>"http://orcid.org/0000-0003-0077-4738", "name"=>"Martin Fenner", "givenName"=>"Martin", "familyName"=>"Fenner"}])
      expect(subject.titles).to eq([{"title"=>"Maremma: a Ruby library for simplified network calls"}])
      expect(subject.descriptions.first["description"]).to start_with("Ruby utility library for network requests")
      expect(subject.subjects).to eq([{"subject"=>"faraday"}, {"subject"=>"excon"}, {"subject"=>"net/http"}])
      expect(subject.dates).to eq([{"date"=>"2017-02-24", "dateType"=>"Issued"}, {"date"=>"2015-11-28", "dateType"=>"Created"}, {"date"=>"2017-02-24", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2017")
      expect(subject.publisher).to eq("DataCite")
    end

    it "rdataone" do
      input = fixture_path + 'codemeta.json'
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.identifier).to eq("https://doi.org/10.5063/f1m61h5x")
      expect(subject.url).to eq("https://github.com/DataONEorg/rdataone")
      expect(subject.types).to eq("bibtex"=>"misc", "citeproc"=>"article-journal", "resourceTypeGeneral"=>"Software", "ris"=>"COMP", "schemaOrg"=>"SoftwareSourceCode")
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
      expect(subject.titles).to eq([{"title"=>"R Interface to the DataONE REST API"}])
      expect(subject.descriptions.first["description"]).to start_with("Provides read and write access to data and metadata")
      expect(subject.subjects).to eq([{"subject"=>"data sharing"}, {"subject"=>"data repository"}, {"subject"=>"DataONE"}])
      expect(subject.version_info).to eq("2.0.0")
      expect(subject.dates).to eq([{"date"=>"2016-05-27", "dateType"=>"Issued"}, {"date"=>"2016-05-27", "dateType"=>"Created"}, {"date"=>"2016-05-27", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2016")
      expect(subject.publisher).to eq("https://cran.r-project.org")
    end

    it "maremma" do
      input = fixture_path + 'maremma/codemeta.json'
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.5438/qeg0-3gm3")
      expect(subject.url).to eq("https://github.com/datacite/maremma")
      expect(subject.types).to eq("bibtex"=>"misc", "citeproc"=>"article-journal", "resourceTypeGeneral"=>"Software", "ris"=>"COMP", "schemaOrg"=>"SoftwareSourceCode")
      expect(subject.creator).to eq([{"type"=>"Person", "id"=>"http://orcid.org/0000-0003-0077-4738", "name"=>"Martin Fenner", "givenName"=>"Martin", "familyName"=>"Fenner"}])
      expect(subject.titles).to eq([{"title"=>"Maremma: a Ruby library for simplified network calls"}])
      expect(subject.descriptions.first["description"]).to start_with("Simplifies network calls")
      expect(subject.subjects).to eq([{"subject"=>"faraday"}, {"subject"=>"excon"}, {"subject"=>"net/http"}])
      expect(subject.dates).to eq([{"date"=>"2017-02-24", "dateType"=>"Issued"}, {"date"=>"2015-11-28", "dateType"=>"Created"}, {"date"=>"2017-02-24", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2017")
      expect(subject.publisher).to eq("DataCite")
    end

    it "metadata_reports" do
      input = "https://github.com/datacite/metadata-reports/blob/master/software/codemeta.json"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.5438/wr0x-e194")
      expect(subject.url).to eq("https://github.com/datacite/metadata-reports")
      expect(subject.types).to eq("bibtex"=>"misc", "citeproc"=>"article-journal", "resourceTypeGeneral"=>"Software", "ris"=>"COMP", "schemaOrg"=>"SoftwareSourceCode")
      expect(subject.creator.size).to eq(4)
      expect(subject.creator.last).to eq("type"=>"Person", "id"=>"https://orcid.org/0000-0001-8135-3489", "name"=>"Lars Holm Nielsen", "givenName"=>"Lars Holm", "familyName"=>"Nielsen")
      expect(subject.titles).to eq([{"title"=>"DOI Registrations for Software"}])
      expect(subject.descriptions.first["description"]).to start_with("Analysis of DataCite DOIs registered for software")
      expect(subject.subjects).to eq([{"subject"=>"doi"}, {"subject"=>"software"}, {"subject"=>"codemeta"}])
      expect(subject.dates).to eq([{"date"=>"2018-05-17", "dateType"=>"Issued"}, {"date"=>"2018-03-09", "dateType"=>"Created"}, {"date"=>"2018-05-17", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2018")
      expect(subject.publisher).to eq("DataCite")
    end
  end
end
