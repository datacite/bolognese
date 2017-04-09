require 'spec_helper'

describe Bolognese::DataciteJson, vcr: true do
  let(:string) { IO.read(fixture_path + "datacite.json") }

  subject { Bolognese::DataciteJson.new(string: string) }

  context "get metadata as string" do
    it "BlogPosting" do
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(subject.type).to eq("ScholarlyArticle")
      expect(subject.additional_type).to eq("BlogPosting")
      expect(subject.resource_type_general).to eq("Text")
      expect(subject.author).to eq("type"=>"Person", "id"=>"http://orcid.org/0000-0003-1419-2405", "name"=>"Fenner, Martin", "givenName"=>"Martin", "familyName"=>"Fenner")
      expect(subject.title).to eq("Eating your own Dog Food")
      expect(subject.alternate_name).to eq("type"=>"Local accession number", "name"=>"MS-49-3632-5083")
      expect(subject.date_published).to eq("2016-12-20")
      expect(subject.is_part_of).to eq("id"=>"https://doi.org/10.5438/0000-00ss", "relationType"=>"IsPartOf")
      expect(subject.references).to eq([{"id"=>"https://doi.org/10.5438/0012", "relationType"=>"References"}, {"id"=>"https://doi.org/10.5438/55e5-t5c0", "relationType"=>"References"}])
      expect(subject.provider).to eq("DataCite")
    end
  end

  context "get metadata as codemeta" do
    it "SoftwareSourceCode" do
      string = IO.read(fixture_path + "datacite_software.json")
      subject = Bolognese::DataciteJson.new(string: string)
      expect(subject.valid?).to be true
      json = JSON.parse(subject.codemeta)
      expect(json["@context"]).to eq("https://raw.githubusercontent.com/codemeta/codemeta/master/codemeta.jsonld")
      expect(json["@id"]).to eq("https://doi.org/10.5063/f1m61h5x")
      expect(json["@type"]).to eq("SoftwareSourceCode")
      expect(json["identifier"]).to eq("https://doi.org/10.5063/f1m61h5x")
      expect(json["agents"]).to eq("type"=>"Person", "name"=>"Matthew B. Jones", "givenName"=>"Matthew B.", "familyName"=>"Jones")
      expect(json["title"]).to eq("dataone: R interface to the DataONE network of data repositories")
      expect(json["datePublished"]).to eq("2016")
      expect(json["publisher"]).to eq("KNB Data Repository")
    end
  end

  context "get metadata as bibtex" do
    it "BlogPosting" do
      bibtex = BibTeX.parse(subject.bibtex).to_a(quotes: '').first
      expect(bibtex[:bibtex_type].to_s).to eq("article")
      expect(bibtex[:bibtex_key]).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(bibtex[:doi]).to eq("10.5438/4K3M-NYVG")
      expect(bibtex[:title]).to eq("Eating your own Dog Food")
      expect(bibtex[:author]).to eq("Fenner, Martin")
      expect(bibtex[:publisher]).to eq("DataCite")
      expect(bibtex[:year]).to eq("2016")
    end
  end

  context "get metadata as citeproc" do
    it "BlogPosting" do
      json = JSON.parse(subject.citeproc)
      expect(json["type"]).to eq("report")
      expect(json["id"]).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(json["DOI"]).to eq("10.5438/4K3M-NYVG")
      expect(json["title"]).to eq("Eating your own Dog Food")
      expect(json["author"]).to eq("family" => "Fenner","given" => "Martin")
      expect(json["publisher"]).to eq("DataCite")
      expect(json["issued"]).to eq("date-parts" => [[2016, 12, 20]])
    end
  end

  context "get metadata as ris" do
    it "BlogPosting" do
      ris = subject.ris.split("\r\n")
      expect(ris[0]).to eq("TY - GEN")
      expect(ris[1]).to eq("T1 - Eating your own Dog Food")
      expect(ris[2]).to eq("T2 - DataCite")
      expect(ris[3]).to eq("AU - Fenner, Martin")
      expect(ris[4]).to eq("DO - 10.5438/4K3M-NYVG")
      expect(ris[5]).to eq("AB - Eating your own dog food is a slang term to describe that an organization should itself use the products and services it provides. For DataCite this means that we should use DOIs with appropriate metadata and strategies for long-term preservation for...")
      expect(ris[6]).to eq("KW - datacite")
      expect(ris[9]).to eq("PY - 2016")
      expect(ris[10]).to eq("PB - DataCite")
      expect(ris[11]).to eq("AN - MS-49-3632-5083")
      expect(ris[12]).to eq("ER - ")
    end
  end
end
