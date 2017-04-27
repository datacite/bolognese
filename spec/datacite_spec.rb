require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  let(:id) { "https://doi.org/10.5061/DRYAD.8515" }

  subject { Bolognese::Metadata.new(input: id, from: "datacite") }

  context "get metadata" do
    it "Schema.org JSON isReferencedBy" do
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.5061/dryad.8515")
      expect(json["@reverse"]).to eq("citation"=>{"@id"=>"https://doi.org/10.1371/journal.ppat.1000446"})
    end

    it "Schema.org JSON IsSupplementTo" do
      id = "https://doi.org/10.5517/CC8H01S"
      subject = Bolognese::Metadata.new(input: id, from: "datacite")
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.5517/cc8h01s")
      expect(json["@reverse"]).to eq("isBasedOn"=>{"@id"=>"https://doi.org/10.1107/s1600536804021154"})
    end
  end

  context "get metadata as string" do
    it "BlogPosting" do
      string = IO.read(fixture_path + "datacite.xml")
      subject = Bolognese::Metadata.new(input: string, from: "datacite")
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

    # it "missing creator" do
    #   string = IO.read(fixture_path + "datacite_missing_creator.xml")
    #   subject = Bolognese::Metadata.new(string: string, regenerate: true)
    #   expect(subject.valid?).to be true
    #   expect(subject.datacite_errors).to eq(2)
    #   expect(subject.id).to eq("https://doi.org/10.5438/4k3m-nyvg")
    #   expect(subject.errors).to eq("Element '{http://datacite.org/schema/kernel-4}creators': Missing child element(s). Expected is ( {http://datacite.org/schema/kernel-4}creator ).")
    # end
  end

  context "get metadata as datacite xml 4.0" do
    it "Dataset" do
      id = "https://doi.org/10.5061/DRYAD.8515"
      subject = Bolognese::Metadata.new(input: id, from: "datacite", regenerate: true)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.5061/dryad.8515")
      expect(subject.type).to eq("Dataset")
      expect(subject.additional_type).to eq("DataPackage")
      expect(subject.resource_type_general).to eq("Dataset")
      expect(subject.author.length).to eq(8)
      expect(subject.author.first).to eq("type"=>"Person", "name"=>"Benjamin Ollomo", "givenName"=>"Benjamin", "familyName"=>"Ollomo")
      expect(subject.title).to eq("Data from: A new malaria agent in African hominids.")
      expect(subject.alternate_name).to eq("type"=>"citation", "name"=>"Ollomo B, Durand P, Prugnolle F, Douzery EJP, Arnathau C, Nkoghe D, Leroy E, Renaud F (2009) A new malaria agent in African hominids. PLoS Pathogens 5(5): e1000446.")
      expect(subject.license).to eq("url"=>"http://creativecommons.org/publicdomain/zero/1.0/")
      expect(subject.date_published).to eq("2011")
      expect(subject.has_part).to eq([{"id"=>"https://doi.org/10.5061/dryad.8515/1", "relationType"=>"HasPart"},
                                      {"id"=>"https://doi.org/10.5061/dryad.8515/2", "relationType"=>"HasPart"}])
      expect(subject.is_referenced_by).to eq("id"=>"https://doi.org/10.1371/journal.ppat.1000446", "relationType"=>"IsReferencedBy")
      expect(subject.publisher).to eq("Dryad Digital Repository")
      expect(subject.provider).to eq("DataCite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-3")

      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.fetch("xsi:schemaLocation", "").split(" ").first).to eq("http://datacite.org/schema/kernel-4")
    end
  end

  context "get metadata as codemeta" do
    it "SoftwareSourceCode" do
      id = "https://doi.org/10.5063/f1m61h5x"
      subject = Bolognese::Metadata.new(input: id, from: "datacite")
      expect(subject.valid?).to be true
      json = JSON.parse(subject.codemeta)
      expect(json["@context"]).to eq("https://raw.githubusercontent.com/codemeta/codemeta/master/codemeta.jsonld")
      expect(json["@id"]).to eq("https://doi.org/10.5063/f1m61h5x")
      expect(json["@type"]).to eq("SoftwareSourceCode")
      expect(json["identifier"]).to eq("https://doi.org/10.5063/f1m61h5x")
      expect(json["agents"]).to eq("name" => "Jones, Matthew B.; Slaughter, Peter; Nahf, Rob; Boettiger, Carl ; Jones, Chris; Read, Jordan; Walker, Lauren; Hart, Edmund; Chamberlain, Scott")
      expect(json["title"]).to eq("dataone: R interface to the DataONE network of data repositories")
      expect(json["datePublished"]).to eq("2016")
      expect(json["publisher"]).to eq("KNB Data Repository")
    end
  end

  context "get metadata as bibtex" do
    it "Dataset" do
      bibtex = BibTeX.parse(subject.bibtex).to_a(quotes: '').first
      expect(bibtex[:bibtex_type].to_s).to eq("misc")
      expect(bibtex[:bibtex_key]).to eq("https://doi.org/10.5061/dryad.8515")
      expect(bibtex[:doi]).to eq("10.5061/DRYAD.8515")
      expect(bibtex[:title]).to eq("Data from: A new malaria agent in African hominids.")
      expect(bibtex[:author]).to eq("Ollomo, Benjamin and Durand, Patrick and Prugnolle, Franck and Douzery, Emmanuel J. P. and Arnathau, Céline and Nkoghe, Dieudonné and Leroy, Eric and Renaud, François")
      expect(bibtex[:publisher]).to eq("Dryad Digital Repository")
      expect(bibtex[:year]).to eq("2011")
    end

    it "BlogPosting" do
      id = "https://doi.org/10.5438/4K3M-NYVG"
      subject = Bolognese::Metadata.new(input: id)
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
    it "Dataset" do
      subject = Bolognese::Metadata.new(input: id, from: "datacite")
      expect(subject.valid?).to be true
      json = JSON.parse(subject.citeproc)
      expect(json["type"]).to eq("dataset")
      expect(json["id"]).to eq("https://doi.org/10.5061/dryad.8515")
      expect(json["DOI"]).to eq("10.5061/DRYAD.8515")
      expect(json["title"]).to eq("Data from: A new malaria agent in African hominids.")
      expect(json["author"]).to eq([{"family"=>"Ollomo", "given"=>"Benjamin"},
                                    {"family"=>"Durand", "given"=>"Patrick"},
                                    {"family"=>"Prugnolle", "given"=>"Franck"},
                                    {"family"=>"Douzery", "given"=>"Emmanuel J. P."},
                                    {"family"=>"Arnathau", "given"=>"Céline"},
                                    {"family"=>"Nkoghe", "given"=>"Dieudonné"},
                                    {"family"=>"Leroy", "given"=>"Eric"},
                                    {"family"=>"Renaud", "given"=>"François"}])
      expect(json["publisher"]).to eq("Dryad Digital Repository")
      expect(json["issued"]).to eq("date-parts" => [[2011]])
    end

    it "BlogPosting" do
      id = "https://doi.org/10.5438/4K3M-NYVG"
      subject = Bolognese::Metadata.new(input: id, from: "datacite")
      expect(subject.valid?).to be true
      json = JSON.parse(subject.citeproc)
      expect(json["type"]).to eq("report")
      expect(json["id"]).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(json["DOI"]).to eq("10.5438/4K3M-NYVG")
      expect(json["title"]).to eq("Eating your own Dog Food")
      expect(json["author"]).to eq("family"=>"Fenner", "given"=>"Martin")
      expect(json["publisher"]).to eq("DataCite")
      expect(json["issued"]).to eq("date-parts"=>[[2016, 12, 20]])
    end
  end

  context "get metadata as ris" do
    it "Dataset" do
      subject = Bolognese::Metadata.new(input: id, from: "datacite")
      expect(subject.valid?).to be true
      ris = subject.ris.split("\r\n")
      expect(ris[0]).to eq("TY - DATA")
      expect(ris[1]).to eq("T1 - Data from: A new malaria agent in African hominids.")
      expect(ris[2]).to eq("T2 - Dryad Digital Repository")
      expect(ris[3]).to eq("AU - Ollomo, Benjamin")
      expect(ris[11]).to eq("DO - 10.5061/DRYAD.8515")
      expect(ris[13]).to eq("KW - Malaria")
      expect(ris[19]).to eq("PY - 2011")
      expect(ris[20]).to eq("PB - Dryad Digital Repository")
      expect(ris[21]).to eq("AN - Ollomo B, Durand P, Prugnolle F, Douzery EJP, Arnathau C, Nkoghe D, Leroy E, Renaud F (2009) A new malaria agent in African hominids. PLoS Pathogens 5(5): e1000446.")
      expect(ris[22]).to eq("ER - ")
    end

    it "BlogPosting" do
      id = "https://doi.org/10.5438/4K3M-NYVG"
      subject = Bolognese::Metadata.new(input: id, from: "datacite")
      expect(subject.valid?).to be true
      ris = subject.ris.split("\r\n")
      expect(ris[0]).to eq("TY - RPRT")
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

  context "get metadata as turtle" do
    it "Dataset" do
      subject = Bolognese::Metadata.new(input: id, from: "datacite")
      expect(subject.valid?).to be true
      ttl = subject.turtle.split("\n")
      expect(ttl[0]).to eq("@prefix schema: <http://schema.org/> .")
      expect(ttl[2]).to eq("<https://doi.org/10.5061/dryad.8515> a schema:Dataset;")
    end

    it "BlogPosting" do
      id = "https://doi.org/10.5438/4K3M-NYVG"
      subject = Bolognese::Metadata.new(input: id, from: "datacite")
      expect(subject.valid?).to be true
      ttl = subject.turtle.split("\n")
      expect(ttl[0]).to eq("@prefix schema: <http://schema.org/> .")
      expect(ttl[2]).to eq("<https://doi.org/10.5438/4k3m-nyvg> a schema:ScholarlyArticle;")
    end
  end

  context "get metadata as rdf_xml" do
    it "BlogPosting" do
      id = "https://doi.org/10.5438/4K3M-NYVG"
      subject = Bolognese::Metadata.new(input: id, from: "datacite")
      expect(subject.valid?).to be true
      rdf_xml = Maremma.from_xml(subject.rdf_xml).fetch("RDF", {})
      expect(rdf_xml.dig("ScholarlyArticle", "rdf:about")).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(rdf_xml.dig("ScholarlyArticle", "author", "Person", "rdf:about")).to eq("http://orcid.org/0000-0003-1419-2405")
      expect(rdf_xml.dig("ScholarlyArticle", "author", "Person", "name")).to eq("Fenner, Martin")
      expect(rdf_xml.dig("ScholarlyArticle", "name")).to eq("Eating your own Dog Food")
      expect(rdf_xml.dig("ScholarlyArticle", "keywords")).to eq("datacite, doi, metadata")
      expect(rdf_xml.dig("ScholarlyArticle", "datePublished", "__content__")).to eq("2016-12-20")
    end
  end
end
