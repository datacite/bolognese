require 'spec_helper'

describe Bolognese::Codemeta, vcr: true do
  let(:fixture_path) { "spec/fixtures/" }
  let(:id) { "https://github.com/datacite/maremma" }

  subject { Bolognese::Codemeta.new(id: id) }

  context "get metadata" do
    it "maremma" do
      expect(subject.id).to eq("https://doi.org/10.5438/qeg0-3gm3")
      expect(subject.url).to eq("https://github.com/datacite/maremma")
      expect(subject.type).to eq("SoftwareSourceCode")
      expect(subject.author).to eq("@id"=>"http://orcid.org/0000-0003-0077-4738", "@type"=>"person", "name"=>"Martin Fenner")
      expect(subject.name).to eq("Maremma: a Ruby library for simplified network calls")
      expect(subject.description).to start_with("Simplifies network calls")
      expect(subject.keywords).to eq("faraday, excon, net/http")
      expect(subject.date_created).to eq("2015-11-28")
      expect(subject.date_published).to eq("2017-02-24")
      expect(subject.date_modified).to eq("2017-02-24")
      expect(subject.publisher).to eq("@type"=>"Organization", "name"=>"DataCite")
    end

    it "maremma schema.org JSON" do
      json = JSON.parse(subject.as_schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.5438/qeg0-3gm3")
      expect(json["name"]).to eq("Maremma: a Ruby library for simplified network calls")
      expect(json["author"]).to eq("@type"=>"person", "@id"=>"http://orcid.org/0000-0003-0077-4738", "name"=>"Martin Fenner")
    end

    it "no codemeta.json" do
      id = "https://github.com/datacite/homepage"
      subject = Bolognese::Codemeta.new(id: id)
      expect(subject.id).to be_nil
      expect(subject.exists?).to be false
    end

    it "not found error" do
      id = "https://github.com/datacite/x"
      subject = Bolognese::Codemeta.new(id: id)
      expect(subject.id).to be_nil
      expect(subject.exists?).to be false
    end
  end

  context "get metadata as string" do
    let(:string) { IO.read(fixture_path + 'codemeta.json') }

    subject { Bolognese::Codemeta.new(string: string) }

    it "rdataone" do
      expect(subject.id).to eq("https://doi.org/10.5063/f1m61h5x")
      expect(subject.url).to eq("https://github.com/DataONEorg/rdataone")
      expect(subject.type).to eq("SoftwareSourceCode")
      expect(subject.author).to eq([{"@type"=>"person",
                                     "@id"=>"http://orcid.org/0000-0003-0077-4738",
                                     "name"=>"Matt Jones"},
                                    {"@type"=>"person",
                                     "@id"=>"http://orcid.org/0000-0002-2192-403X",
                                     "name"=>"Peter Slaughter"},
                                    {"@type"=>"organization",
                                     "name"=>"University of California, Santa Barbara"}])
      expect(subject.name).to eq("R Interface to the DataONE REST API")
      expect(subject.description).to start_with("Provides read and write access to data and metadata")
      expect(subject.keywords).to eq("data sharing, data repository, DataONE")
      expect(subject.version).to eq("2.0.0")
      expect(subject.date_created).to eq("2016-05-27")
      expect(subject.date_published).to eq("2016-05-27")
      expect(subject.date_modified).to eq("2016-05-27")
      expect(subject.publisher).to eq("@type"=>"Organization", "name"=>"https://cran.r-project.org")
    end

    it "maremma" do
      string = IO.read(fixture_path + 'maremma/codemeta.json')
      subject = Bolognese::Codemeta.new(string: string)
      expect(subject.id).to eq("https://doi.org/10.5438/qeg0-3gm3")
      expect(subject.url).to eq("https://github.com/datacite/maremma")
      expect(subject.type).to eq("SoftwareSourceCode")
      expect(subject.author).to eq("@id"=>"http://orcid.org/0000-0003-0077-4738", "@type"=>"person", "name"=>"Martin Fenner")
      expect(subject.name).to eq("Maremma: a Ruby library for simplified network calls")
      expect(subject.description).to start_with("Simplifies network calls")
      expect(subject.keywords).to eq("faraday, excon, net/http")
      expect(subject.date_created).to eq("2015-11-28")
      expect(subject.date_published).to eq("2017-02-24")
      expect(subject.date_modified).to eq("2017-02-24")
      expect(subject.publisher).to eq("@type"=>"Organization", "name"=>"DataCite")
    end
  end

  context "get metadata as datacite xml" do
    it "rdataone" do
      string = IO.read(fixture_path + 'codemeta.json')
      subject = Bolognese::Codemeta.new(string: string)
      expect(subject.validation_errors).to be_empty
      datacite = Maremma.from_xml(subject.as_datacite).fetch("resource", {})
      expect(datacite.dig("titles", "title")).to eq("R Interface to the DataONE REST API")
      expect(datacite.dig("creators", "creator")).to eq([{"creatorName"=>"Matt Jones",
                                                          "nameIdentifier"=>
                                                         {"schemeURI"=>"http://orcid.org/",
                                                          "nameIdentifierScheme"=>"ORCID",
                                                          "__content__"=>"http://orcid.org/0000-0003-0077-4738"}},
                                                         {"creatorName"=>"Peter Slaughter",
                                                          "nameIdentifier"=>
                                                         {"schemeURI"=>"http://orcid.org/",
                                                          "nameIdentifierScheme"=>"ORCID",
                                                          "__content__"=>"http://orcid.org/0000-0002-2192-403X"}},
                                                         {"creatorName"=>"University of California, Santa Barbara"}])
      expect(datacite.fetch("version")).to eq("2.0.0")
    end

    it "maremma" do
      expect(subject.validation_errors).to be_empty
      datacite = Maremma.from_xml(subject.as_datacite).fetch("resource", {})
      expect(datacite.dig("titles", "title")).to eq("Maremma: a Ruby library for simplified network calls")
      expect(datacite.dig("creators", "creator")).to eq("creatorName"=>"Martin Fenner", "nameIdentifier"=>{"schemeURI"=>"http://orcid.org/", "nameIdentifierScheme"=>"ORCID", "__content__"=>"http://orcid.org/0000-0003-0077-4738"})
    end
  end

  context "get metadata as schema.org JSON" do
    it "rdataone" do
      string = IO.read(fixture_path + 'codemeta.json')
      subject = Bolognese::Codemeta.new(string: string)
      json = JSON.parse(subject.as_schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.5063/f1m61h5x")
      expect(json["@type"]).to eq("SoftwareSourceCode")
      expect(json["name"]).to eq("R Interface to the DataONE REST API")
      expect(json["author"]).to eq([{"@type"=>"person",
                                     "@id"=>"http://orcid.org/0000-0003-0077-4738",
                                     "name"=>"Matt Jones"},
                                    {"@type"=>"person",
                                     "@id"=>"http://orcid.org/0000-0002-2192-403X",
                                     "name"=>"Peter Slaughter"},
                                    {"@type"=>"organization",
                                     "name"=>"University of California, Santa Barbara"}])
      expect(json["version"]).to eq("2.0.0")
    end

    it "maremma" do
      json = JSON.parse(subject.as_schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.5438/qeg0-3gm3")
      expect(json["@type"]).to eq("SoftwareSourceCode")
      expect(json["name"]).to eq("Maremma: a Ruby library for simplified network calls")
      expect(json["author"]).to eq("@type"=>"person", "@id"=>"http://orcid.org/0000-0003-0077-4738", "name"=>"Martin Fenner")
    end
  end

  context "get metadata as bibtex" do
    it "maremma" do
      bibtex = BibTeX.parse(subject.as_bibtex).to_a(quotes: '').first
      expect(bibtex[:bibtex_type].to_s).to eq("misc")
      expect(bibtex[:bibtex_key]).to eq("https://doi.org/10.5438/qeg0-3gm3")
      expect(bibtex[:doi]).to eq("10.5438/qeg0-3gm3")
      expect(bibtex[:url]).to eq("https://github.com/datacite/maremma")
      expect(bibtex[:title]).to eq("Maremma: a Ruby library for simplified network calls")
      expect(bibtex[:author]).to eq("Fenner, Martin")
      expect(bibtex[:publisher]).to eq("DataCite")
      expect(bibtex[:keywords]).to eq("faraday, excon, net/http")
      expect(bibtex[:year]).to eq("2017")
    end
  end
end
