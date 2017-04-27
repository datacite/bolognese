require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  let(:input) { "https://blog.datacite.org/eating-your-own-dog-food/" }
  let(:fixture_path) { "spec/fixtures/" }

  subject { Bolognese::Metadata.new(input: input) }

  context "get metadata" do
    it "BlogPosting" do
      #expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(subject.url).to eq("https://blog.datacite.org/eating-your-own-dog-food")
      expect(subject.type).to eq("BlogPosting")
      expect(subject.author).to eq("type"=>"Person", "id"=>"http://orcid.org/0000-0003-1419-2405", "name"=>"Martin Fenner", "givenName"=>"Martin", "familyName"=>"Fenner")
      expect(subject.title).to eq("Eating your own Dog Food")
      expect(subject.alternate_name).to eq("MS-49-3632-5083")
      expect(subject.description["text"]).to start_with("Eating your own dog food")
      expect(subject.keywords).to eq("datacite, doi, metadata, featured")
      expect(subject.date_published).to eq("2016-12-20")
      expect(subject.date_modified).to eq("2016-12-20")
      expect(subject.is_part_of).to eq("id"=>"https://doi.org/10.5438/0000-00ss", "type"=>"Blog", "name"=>"DataCite Blog", "relationType"=>"IsPartOf", "resourceTypeGeneral" => "Text")
      expect(subject.references).to eq([{"id"=>"https://doi.org/10.5438/0012",
                                         "type"=>"CreativeWork",
                                         "relationType"=>"References",
                                         "resourceTypeGeneral"=>"Other"},
                                        {"id"=>"https://doi.org/10.5438/55e5-t5c0",
                                         "type"=>"CreativeWork",
                                         "relationType"=>"References",
                                         "resourceTypeGeneral"=>"Other"}])
      expect(subject.publisher).to eq("DataCite")
    end

    it "BlogPosting schema.org JSON" do
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.5438/4k3m-nyvg")
    end

    it "not found error" do
      input = "https://doi.org/10.5438/4K3M-NYVGx"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.id).to be_nil
      expect(subject.exists?).to be false
    end
  end

  context "get metadata as string" do
    it "BlogPosting" do
      input = fixture_path + 'schema_org.json'
      subject = Bolognese::Metadata.new(input: input)

      expect(subject.id).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(subject.url).to eq("https://blog.datacite.org/eating-your-own-dog-food")
      expect(subject.type).to eq("BlogPosting")
      expect(subject.author).to eq("type"=>"Person", "id"=>"http://orcid.org/0000-0003-1419-2405", "name"=>"Martin Fenner", "givenName"=>"Martin", "familyName"=>"Fenner")
      expect(subject.title).to eq("Eating your own Dog Food")
      expect(subject.alternate_name).to eq("MS-49-3632-5083")
      expect(subject.description["text"]).to start_with("Eating your own dog food")
      expect(subject.keywords).to eq("datacite, doi, metadata, featured")
      expect(subject.date_published).to eq("2016-12-20")
      expect(subject.date_modified).to eq("2016-12-20")
      expect(subject.is_part_of).to eq("id"=>"https://doi.org/10.5438/0000-00ss", "type"=>"Blog", "name"=>"DataCite Blog", "relationType"=>"IsPartOf", "resourceTypeGeneral"=>"Text")
      expect(subject.references).to eq([{"id"=>"https://doi.org/10.5438/0012",
                                         "type"=>"CreativeWork",
                                         "relationType"=>"References",
                                         "resourceTypeGeneral"=>"Other"},
                                        {"id"=>"https://doi.org/10.5438/55e5-t5c0",
                                          "type"=>"CreativeWork",
                                          "relationType"=>"References",
                                          "resourceTypeGeneral"=>"Other"}])
      expect(subject.publisher).to eq("DataCite")
    end
  end

  context "get metadata as datacite xml" do
    it "with data citation" do
      #expect(subject.valid?).to be true
      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.dig("titles", "title")).to eq("Eating your own Dog Food")
      expect(datacite.dig("relatedIdentifiers", "relatedIdentifier").count).to eq(3)
      expect(datacite.dig("relatedIdentifiers", "relatedIdentifier").first).to eq("relatedIdentifierType"=>"DOI", "relationType"=>"IsPartOf", "resourceTypeGeneral"=>"Text", "__content__"=>"https://doi.org/10.5438/0000-00ss")
    end
  end

  context "get metadata as bibtex" do
    it "with data citation" do
      bibtex = BibTeX.parse(subject.bibtex).to_a(quotes: '').first
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

  context "get metadata as citeproc" do
    it "BlogPosting" do
      json = JSON.parse(subject.citeproc)
      expect(json["type"]).to eq("post-weblog")
      expect(json["id"]).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(json["DOI"]).to eq("10.5438/4k3m-nyvg")
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
      expect(ris[4]).to eq("DO - 10.5438/4k3m-nyvg")
      expect(ris[5]).to eq("UR - https://blog.datacite.org/eating-your-own-dog-food")
      expect(ris[6]).to eq("AB - Eating your own dog food is a slang term to describe that an organization should itself use the products and services it provides. For DataCite this means that we should use DOIs with appropriate metadata and strategies for long-term preservation for...")
      expect(ris[7]).to eq("KW - datacite")
      expect(ris[11]).to eq("PY - 2016")
      expect(ris[12]).to eq("PB - DataCite")
      expect(ris[13]).to eq("ER - ")
    end
  end

  # context "get metadata as turtle" do
  #   it "BlogPosting" do
  #     expect(subject.valid?).to be true
  #     ttl = subject.turtle.split("\n")
  #     expect(ttl[0]).to eq("@prefix schema: <http://schema.org/> .")
  #     expect(ttl[2]).to eq("<https://doi.org/10.5438/4k3m-nyvg> a schema:ScholarlyArticle;")
  #   end
  # end
  #
  # context "get metadata as rdf_xml" do
  #   it "BlogPosting" do
  #     puts subject.rdf_xml
  #     expect(subject.valid?).to be true
  #     rdf_xml = Maremma.from_xml(subject.rdf_xml).fetch("RDF", {})
  #     expect(rdf_xml.dig("ScholarlyArticle", "rdf:about")).to eq("https://doi.org/10.5438/4k3m-nyvg")
  #     expect(rdf_xml.dig("ScholarlyArticle", "author", "Person", "rdf:about")).to eq("http://orcid.org/0000-0003-1419-2405")
  #     expect(rdf_xml.dig("ScholarlyArticle", "author", "Person", "name")).to eq("Fenner, Martin")
  #     expect(rdf_xml.dig("ScholarlyArticle", "name")).to eq("Eating your own Dog Food")
  #     expect(rdf_xml.dig("ScholarlyArticle", "keywords")).to eq("datacite, doi, metadata")
  #     expect(rdf_xml.dig("ScholarlyArticle", "datePublished", "__content__")).to eq("2016-12-20")
  #   end
  # end
end
