require 'spec_helper'

describe Bolognese::Codemeta, vcr: true do
  let(:fixture_path) { "spec/fixtures/" }


  # context "get metadata" do
  #   it "BlogPosting" do
  #     expect(subject.id).to eq("https://doi.org/10.5438/4k3m-nyvg")
  #     expect(subject.url).to eq("https://blog.datacite.org/eating-your-own-dog-food")
  #     expect(subject.type).to eq("BlogPosting")
  #     expect(subject.author).to eq([{"@type"=>"Person", "@id"=>"http://orcid.org/0000-0003-1419-2405", "givenName"=>"Martin", "familyName"=>"Fenner"}])
  #     expect(subject.name).to eq("Eating your own Dog Food")
  #     expect(subject.alternate_name).to eq("MS-49-3632-5083")
  #     expect(subject.description).to start_with("Eating your own dog food")
  #     expect(subject.keywords).to eq("datacite, doi, metadata, featured")
  #     expect(subject.date_published).to eq("2016-12-20")
  #     expect(subject.date_modified).to eq("2016-12-20")
  #     expect(subject.is_part_of).to eq("@type"=>"Blog", "@id"=>"https://doi.org/10.5438/0000-00ss", "name"=>"DataCite Blog")
  #     expect(subject.citation).to eq([{"@type"=>"CreativeWork", "@id"=>"https://doi.org/10.5438/0012"},
  #                                     {"@type"=>"CreativeWork", "@id"=>"https://doi.org/10.5438/55e5-t5c0"}])
  #     expect(subject.publisher).to eq("@type"=>"Organization", "name"=>"DataCite")
  #   end
  #
  #   it "BlogPosting schema.org JSON" do
  #     json = JSON.parse(subject.as_schema_org)
  #     expect(json["@id"]).to eq("https://doi.org/10.5438/4k3m-nyvg")
  #   end
  #
  #   it "not found error" do
  #     id = "https://doi.org/10.5438/4K3M-NYVGx"
  #     subject = Bolognese::SchemaOrg.new(id: id)
  #     expect(subject.id).to be_nil
  #     expect(subject.exists?).to be false
  #   end
  # end

  context "get metadata as string" do
    let(:string) { IO.read(fixture_path + 'codemeta.json') }

    subject { Bolognese::Codemeta.new(string: string) }

    it "SoftwareSourceCode" do
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
                                     "@id"=>"http://orcid.org/0000-0002-3957-2474",
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
  end

  context "get metadata as datacite xml" do
    let(:string) { IO.read(fixture_path + 'codemeta.json') }

    subject { Bolognese::Codemeta.new(string: string) }

    it "SoftwareSourceCode" do
      expect(subject.validation_errors).to be_empty
      datacite = Maremma.from_xml(subject.as_datacite).fetch("resource", {})
      expect(datacite.dig("titles", "title")).to eq("R Interface to the DataONE REST API")
      expect(datacite.fetch("version")).to eq("2.0.0")
    end
  end

  context "get metadata as schema.org JSON" do
    let(:string) { IO.read(fixture_path + 'codemeta.json') }

    subject { Bolognese::Codemeta.new(string: string) }

    it "SoftwareSourceCode" do
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
                                     "@id"=>"http://orcid.org/0000-0002-3957-2474",
                                     "name"=>"University of California, Santa Barbara"}])
      expect(json["version"]).to eq("2.0.0")
    end
  end

  context "get metadata as bibtex" do
    let(:string) { IO.read(fixture_path + 'codemeta.json') }

    subject { Bolognese::Codemeta.new(string: string) }

    it "SoftwareSourceCode" do
      bibtex = BibTeX.parse(subject.as_bibtex).to_a(quotes: '').first
      expect(bibtex[:bibtex_type].to_s).to eq("misc")
      expect(bibtex[:bibtex_key]).to eq("https://doi.org/10.5063/f1m61h5x")
      expect(bibtex[:doi]).to eq("10.5063/f1m61h5x")
      expect(bibtex[:url]).to eq("https://github.com/DataONEorg/rdataone")
      expect(bibtex[:title]).to eq("R Interface to the DataONE REST API")
      expect(bibtex[:author]).to eq("Jones, Matt and Slaughter, Peter and {University of California, Santa Barbara}")
      expect(bibtex[:publisher]).to eq("https://cran.r-project.org")
      expect(bibtex[:keywords]).to eq("data sharing, data repository, DataONE")
      expect(bibtex[:year]).to eq("2016")
    end
  end
end
