require 'spec_helper'

describe Bolognese::SchemaOrg, vcr: true do
  let(:id) { "https://blog.datacite.org/eating-your-own-dog-food" }
  let(:fixture_path) { "spec/fixtures/" }

  subject { Bolognese::SchemaOrg.new(id: id) }

  context "get metadata" do
    it "BlogPosting" do
      expect(subject.id).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(subject.url).to eq("https://blog.datacite.org/eating-your-own-dog-food")
      expect(subject.type).to eq("BlogPosting")
      expect(subject.author).to eq("@type"=>"Person", "@id"=>"http://orcid.org/0000-0003-1419-2405", "givenName"=>"Martin", "familyName"=>"Fenner")
      expect(subject.name).to eq("Eating your own Dog Food")
      expect(subject.alternate_name).to eq("MS-49-3632-5083")
      expect(subject.description).to start_with("Eating your own dog food")
      expect(subject.keywords).to eq("datacite, doi, metadata, featured")
      expect(subject.date_published).to eq("2016-12-20")
      expect(subject.date_modified).to eq("2016-12-20")
      expect(subject.is_part_of).to eq("@type"=>"Blog", "@id"=>"https://doi.org/10.5438/0000-00ss", "name"=>"DataCite Blog")
      expect(subject.citation).to eq([{"@type"=>"CreativeWork", "@id"=>"https://doi.org/10.5438/0012"},
                                      {"@type"=>"CreativeWork", "@id"=>"https://doi.org/10.5438/55e5-t5c0"}])
      expect(subject.publisher).to eq("@type"=>"Organization", "name"=>"DataCite")
    end

    it "BlogPosting schema.org JSON" do
      json = JSON.parse(subject.as_schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.5438/4k3m-nyvg")
    end

    it "not found error" do
      id = "https://doi.org/10.5438/4K3M-NYVGx"
      subject = Bolognese::SchemaOrg.new(id: id)
      expect(subject.id).to be_nil
      expect(subject.exists?).to be false
    end
  end

  context "get metadata as string" do
    it "BlogPosting" do
      string = File.read(fixture_path + 'schema_org.json')
      subject = Bolognese::SchemaOrg.new(string: string)

      expect(subject.id).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(subject.url).to eq("https://blog.datacite.org/eating-your-own-dog-food")
      expect(subject.type).to eq("BlogPosting")
      expect(subject.author).to eq("@type"=>"Person", "@id"=>"http://orcid.org/0000-0003-1419-2405", "givenName"=>"Martin", "familyName"=>"Fenner")
      expect(subject.name).to eq("Eating your own Dog Food")
      expect(subject.alternate_name).to eq("MS-49-3632-5083")
      expect(subject.description).to start_with("Eating your own dog food")
      expect(subject.keywords).to eq("datacite, doi, metadata, featured")
      expect(subject.date_published).to eq("2016-12-20")
      expect(subject.date_modified).to eq("2016-12-20")
      expect(subject.is_part_of).to eq("@type"=>"Blog", "@id"=>"https://doi.org/10.5438/0000-00ss", "name"=>"DataCite Blog")
      expect(subject.citation).to eq([{"@type"=>"CreativeWork", "@id"=>"https://doi.org/10.5438/0012"},
                                      {"@type"=>"CreativeWork", "@id"=>"https://doi.org/10.5438/55e5-t5c0"}])
      expect(subject.publisher).to eq("@type"=>"Organization", "name"=>"DataCite")
    end
  end

  context "get metadata as datacite xml" do
    it "with data citation" do
      expect(subject.validation_errors).to be_empty
      datacite = Maremma.from_xml(subject.as_datacite).fetch("resource", {})
      expect(datacite.dig("titles", "title")).to eq("Eating your own Dog Food")
      expect(datacite.dig("relatedIdentifiers", "relatedIdentifier").count).to eq(3)
      expect(datacite.dig("relatedIdentifiers", "relatedIdentifier").first).to eq("relatedIdentifierType"=>"DOI", "relationType"=>"IsPartOf", "__content__"=>"https://doi.org/10.5438/0000-00ss")
    end
  end

  context "get metadata as bibtex" do
    it "with data citation" do
      bibtex = BibTeX.parse(subject.as_bibtex).to_a(quotes: '').first
      expect(bibtex[:bibtex_type].to_s).to eq("article")
      expect(bibtex[:bibtex_key]).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(bibtex[:doi]).to eq("10.5438/4k3m-nyvg")
      expect(bibtex[:title]).to eq("Eating your own Dog Food")
      expect(bibtex[:author]).to eq("Fenner, Martin")
      expect(bibtex[:publisher]).to eq("DataCite")
      expect(bibtex[:keywords]).to eq("datacite, doi, metadata, featured")
      expect(bibtex[:year]).to eq("2016")
    end
  end
end
