require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  let(:fixture_path) { "spec/fixtures/" }
  let(:input) { "https://github.com/datacite/maremma" }

  subject { Bolognese::Metadata.new(input: input) }

  context "get metadata" do
    it "maremma schema.org JSON" do
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.5438/qeg0-3gm3")
      expect(json["name"]).to eq("Maremma: a Ruby library for simplified network calls")
      expect(json["author"]).to eq("name"=>"Martin Fenner", "givenName"=>"Martin", "familyName"=>"Fenner", "@type"=>"Person", "@id"=>"http://orcid.org/0000-0003-0077-4738")
    end

    it "no codemeta.json" do
      input = "https://github.com/datacite/homepage"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.id).to be_nil
      expect(subject.exists?).to be false
    end

    it "not found error" do
      input = "https://github.com/datacite/x"
      subject = Bolognese::Codemeta.new(input: input)
      expect(subject.id).to be_nil
      expect(subject.exists?).to be false
    end
  end

  context "get metadata as string" do
    let(:input) { fixture_path + 'codemeta.json' }

    subject { Bolognese::Metadata.new(input: input) }

    it "rdataone" do
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

  context "get metadata as datacite xml" do
    it "rdataone" do
      input = fixture_path + 'codemeta.json'
      subject = Bolognese::Metadata.new(input: input)
      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.dig("titles", "title")).to eq("R Interface to the DataONE REST API")
      expect(datacite.dig("creators", "creator")).to eq([{"creatorName"=>"Jones, Matt",
                                                          "givenName"=>"Matt",
                                                          "familyName"=>"Jones",
                                                          "nameIdentifier"=>
                                                         {"schemeURI"=>"http://orcid.org/",
                                                          "nameIdentifierScheme"=>"ORCID",
                                                          "__content__"=>"http://orcid.org/0000-0003-0077-4738"}},
                                                         {"creatorName"=>"Slaughter, Peter",
                                                           "givenName"=>"Peter",
                                                           "familyName"=>"Slaughter",
                                                          "nameIdentifier"=>
                                                         {"schemeURI"=>"http://orcid.org/",
                                                          "nameIdentifierScheme"=>"ORCID",
                                                          "__content__"=>"http://orcid.org/0000-0002-2192-403X"}},
                                                         {"creatorName"=>"University Of California, Santa Barbara"}])
      expect(datacite.fetch("version")).to eq("2.0.0")
    end

    it "maremma" do
      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.dig("titles", "title")).to eq("Maremma: a Ruby library for simplified network calls")
      expect(datacite.dig("creators", "creator")).to eq("creatorName"=>"Fenner, Martin", "givenName"=>"Martin", "familyName"=>"Fenner", "nameIdentifier"=>{"schemeURI"=>"http://orcid.org/", "nameIdentifierScheme"=>"ORCID", "__content__"=>"http://orcid.org/0000-0003-0077-4738"})
    end
  end

  context "get metadata as schema.org JSON" do
    it "rdataone" do
      string = fixture_path + 'codemeta.json'
      subject = Bolognese::Metadata.new(input: input)
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.5063/f1m61h5x")
      expect(json["@type"]).to eq("SoftwareSourceCode")
      expect(json["name"]).to eq("R Interface to the DataONE REST API")
      expect(json["author"]).to eq([{"name"=>"Matt Jones",
                                     "givenName"=>"Matt",
                                     "familyName"=>"Jones",
                                     "@type"=>"Person",
                                     "@id"=>"http://orcid.org/0000-0003-0077-4738"},
                                    {"name"=>"Peter Slaughter",
                                     "givenName"=>"Peter",
                                     "familyName"=>"Slaughter",
                                     "@type"=>"Person",
                                     "@id"=>"http://orcid.org/0000-0002-2192-403X"},
                                    {"name"=>"University Of California, Santa Barbara", "@type"=>"Organization"}])
      expect(json["version"]).to eq("2.0.0")
    end

    it "maremma" do
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.5438/qeg0-3gm3")
      expect(json["@type"]).to eq("SoftwareSourceCode")
      expect(json["name"]).to eq("Maremma: a Ruby library for simplified network calls")
      expect(json["author"]).to eq("name"=>"Martin Fenner", "givenName"=>"Martin", "familyName"=>"Fenner", "@type"=>"Person", "@id"=>"http://orcid.org/0000-0003-0077-4738")
    end
  end

  context "get metadata as bibtex" do
    it "maremma" do
      bibtex = BibTeX.parse(subject.bibtex).to_a(quotes: '').first
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

  context "get metadata as citeproc" do
    it "maremma" do
      json = JSON.parse(subject.citeproc)
      expect(json["type"]).to eq("computer_program")
      expect(json["id"]).to eq("https://doi.org/10.5438/qeg0-3gm3")
      expect(json["DOI"]).to eq("10.5438/qeg0-3gm3")
      expect(json["title"]).to eq("Maremma: a Ruby library for simplified network calls")
      expect(json["author"]).to eq("family" => "Fenner", "given" => "Martin")
      expect(json["publisher"]).to eq("DataCite")
      expect(json["issued"]).to eq("date-parts" => [[2017, 2, 24]])
    end
  end

  context "get metadata as ris" do
    it "maremma" do
      ris = subject.ris.split("\r\n")
      expect(ris[0]).to eq("TY - COMP")
      expect(ris[1]).to eq("T1 - Maremma: a Ruby library for simplified network calls")
      expect(ris[2]).to eq("T2 - DataCite")
      expect(ris[3]).to eq("AU - Fenner, Martin")
      expect(ris[4]).to eq("DO - 10.5438/qeg0-3gm3")
      expect(ris[5]).to eq("UR - https://github.com/datacite/maremma")
      expect(ris[6]).to eq("AB - Ruby utility library for network requests. Based on Faraday and Excon, provides a wrapper for XML/JSON parsing and error handling. All successful responses are returned as hash with key data, all errors in a JSONAPI-friendly hash with key errors.")
      expect(ris[7]).to eq("KW - faraday")
      expect(ris[10]).to eq("PY - 2017")
      expect(ris[11]).to eq("PB - DataCite")
      expect(ris[12]).to eq("ER - ")
    end
  end

  context "get metadata as turtle" do
    it "maremma" do
      ttl = subject.turtle.split("\n")
      expect(ttl[0]).to eq("@prefix schema: <http://schema.org/> .")
      expect(ttl[2]).to eq("<https://doi.org/10.5438/qeg0-3gm3> a schema:SoftwareSourceCode;")
    end
  end

  context "get metadata as rdf_xml" do
    it "maremma" do
      rdf_xml = Maremma.from_xml(subject.rdf_xml).fetch("RDF", {})
      expect(rdf_xml.dig("SoftwareSourceCode", "rdf:about")).to eq("https://doi.org/10.5438/qeg0-3gm3")
      expect(rdf_xml.dig("SoftwareSourceCode", "author", "Person", "rdf:about")).to eq("http://orcid.org/0000-0003-0077-4738")
      expect(rdf_xml.dig("SoftwareSourceCode", "author", "Person", "name")).to eq("Martin Fenner")
      expect(rdf_xml.dig("SoftwareSourceCode", "name")).to eq("Maremma: a Ruby library for simplified network calls")
      expect(rdf_xml.dig("SoftwareSourceCode", "keywords")).to eq("faraday, excon, net/http")
      expect(rdf_xml.dig("SoftwareSourceCode", "datePublished", "__content__")).to eq("2017-02-24")
    end
  end
end
