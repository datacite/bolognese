require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  let(:input) { "10.7554/eLife.01567" }

  subject { Bolognese::Metadata.new(input: input, from: "crossref") }

  context "get metadata" do
    it "Schema.org JSON" do
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.7554/elife.01567")
    end
  end

  context "get metadata as string" do
    it "DOI with data citation" do
      input = "10.7554/eLife.01567"
      string = Bolognese::Metadata.new(input: input, from: "crossref").crossref

      subject = Bolognese::Metadata.new(input: string, from: "crossref")
      expect(subject.id).to eq("https://doi.org/10.7554/elife.01567")
      expect(subject.url).to eq("http://elifesciences.org/lookup/doi/10.7554/eLife.01567")
      expect(subject.type).to eq("ScholarlyArticle")
      expect(subject.additional_type).to eq("JournalArticle")
      expect(subject.resource_type_general).to eq("Text")
      expect(subject.author.length).to eq(5)
      expect(subject.author.last).to eq("type"=>"Person", "name"=>"Christian S Hardtke", "givenName"=>"Christian S", "familyName"=>"Hardtke")
      expect(subject.license).to eq("url"=>"http://creativecommons.org/licenses/by/3.0/")
      expect(subject.title).to eq("Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
      expect(subject.date_published).to eq("2014-02-11")
      expect(subject.date_modified).to eq("2015-08-11T05:35:02Z")
      expect(subject.is_part_of).to eq("type"=>"Periodical", "name"=>"eLife", "issn"=>"2050-084X")
      expect(subject.references.count).to eq(27)
      expect(subject.references[21]).to eq("id"=>"https://doi.org/10.5061/dryad.b835k", "relationType"=>"Cites", "position"=>"22", "datePublished"=>"2014")
      expect(subject.provider).to eq("Crossref")
    end
  end

  context "get metadata as datacite xml" do
    it "with data citation" do
      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.dig("resourceType", "resourceTypeGeneral")).to eq("Text")
      expect(datacite.dig("titles", "title")).to eq("Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
      expect(datacite.dig("relatedIdentifiers", "relatedIdentifier").count).to eq(27)
      expect(datacite.dig("relatedIdentifiers", "relatedIdentifier").first).to eq("relatedIdentifierType"=>"DOI", "relationType"=>"Cites", "__content__"=>"https://doi.org/10.1038/nature02100")
      expect(datacite.dig("rightsList")).to eq("rights"=>{"rightsURI"=>"http://creativecommons.org/licenses/by/3.0/"})
      expect(datacite.dig("fundingReferences", "fundingReference").count).to eq(4)
      expect(datacite.dig("fundingReferences", "fundingReference").last).to eq("funderName"=>"University of Lausanne", "funderIdentifier"=>{"funderIdentifierType"=>"Crossref Funder ID", "__content__"=>"https://doi.org/10.13039/501100006390"})
    end

    it "with ORCID ID" do
      input = "https://doi.org/10.1155/2012/291294"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.dig("resourceType", "resourceTypeGeneral")).to eq("Text")
      expect(datacite.dig("creators", "creator").count).to eq(7)
      expect(datacite.dig("creators", "creator")[2]).to eq("creatorName" => "Hernandez, Beatriz",
       +"familyName" => "Hernandez",
       +"givenName" => "Beatriz",
        "nameIdentifier" => {"schemeURI"=>"http://orcid.org/", "nameIdentifierScheme"=>"ORCID", "__content__"=>"http://orcid.org/0000-0003-2043-4925"})
    end

    it "with editor" do
      input = "https://doi.org/10.1371/journal.pone.0000030"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.dig("contributors", "contributor")).to eq("contributorType"=>"Editor", "contributorName"=>"Janbon, Guilhem", "givenName"=>"Guilhem", "familyName"=>"Janbon")
    end
  end

  context "get metadata as bibtex" do
    it "with data citation" do
      bibtex = BibTeX.parse(subject.bibtex).to_a(quotes: '').first
      expect(bibtex[:bibtex_type].to_s).to eq("article")
      expect(bibtex[:bibtex_key]).to eq("https://doi.org/10.7554/elife.01567")
      expect(bibtex[:doi]).to eq("10.7554/eLife.01567")
      expect(bibtex[:url]).to eq("http://elifesciences.org/lookup/doi/10.7554/eLife.01567")
      expect(bibtex[:title]).to eq("Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
      expect(bibtex[:author]).to eq("Sankar, Martial and Nieminen, Kaisa and Ragni, Laura and Xenarios, Ioannis and Hardtke, Christian S")
      expect(bibtex[:journal]).to eq("eLife")
      expect(bibtex[:year]).to eq("2014")
    end

    it "with pages" do
      input = "https://doi.org/10.1155/2012/291294"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      bibtex = BibTeX.parse(subject.bibtex).to_a(quotes: '').first
      expect(bibtex[:bibtex_type].to_s).to eq("article")
      expect(bibtex[:bibtex_key]).to eq("https://doi.org/10.1155/2012/291294")
      expect(bibtex[:doi]).to eq("10.1155/2012/291294")
      expect(bibtex[:url]).to eq("http://www.hindawi.com/journals/pm/2012/291294/")
      expect(bibtex[:title]).to eq("Delineating a Retesting Zone Using Receiver Operating Characteristic Analysis on Serial QuantiFERON Tuberculosis Test Results in US Healthcare Workers")
      expect(bibtex[:author]).to eq("Thanassi, Wendy and Noda, Art and Hernandez, Beatriz and Newell, Jeffery and Terpeluk, Paul and Marder, David and Yesavage, Jerome A.")
      expect(bibtex[:journal]).to eq("Pulmonary Medicine")
      expect(bibtex[:pages]).to eq("1-7")
      expect(bibtex[:year]).to eq("2012")
    end
  end

  context "get metadata as citeproc" do
    it "journal article" do
      input = "10.7554/eLife.01567"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      expect(subject.valid?).to be true
      json = JSON.parse(subject.citeproc)
      expect(json["type"]).to eq("article-journal")
      expect(json["id"]).to eq("https://doi.org/10.7554/elife.01567")
      expect(json["DOI"]).to eq("10.7554/eLife.01567")
      expect(json["title"]).to eq("Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
      expect(json["author"]).to eq([{"family"=>"Sankar", "given"=>"Martial"},
                                    {"family"=>"Nieminen", "given"=>"Kaisa"},
                                    {"family"=>"Ragni", "given"=>"Laura"},
                                    {"family"=>"Xenarios", "given"=>"Ioannis"},
                                    {"family"=>"Hardtke", "given"=>"Christian S"}])
      expect(json["container-title"]).to eq("eLife")
      expect(json["volume"]).to eq("3")
      expect(json["issued"]).to eq("date-parts" => [[2014, 2, 11]])
    end

    it "with pages" do
      input = "https://doi.org/10.1155/2012/291294"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      expect(subject.valid?).to be true
      json = JSON.parse(subject.citeproc)
      expect(json["type"]).to eq("article-journal")
      expect(json["id"]).to eq("https://doi.org/10.1155/2012/291294")
      expect(json["DOI"]).to eq("10.1155/2012/291294")
      expect(json["title"]).to eq("Delineating a Retesting Zone Using Receiver Operating Characteristic Analysis on Serial QuantiFERON Tuberculosis Test Results in US Healthcare Workers")
      expect(json["author"]).to eq([{"family"=>"Thanassi", "given"=>"Wendy"},
                                    {"family"=>"Noda", "given"=>"Art"},
                                    {"family"=>"Hernandez", "given"=>"Beatriz"},
                                    {"family"=>"Newell", "given"=>"Jeffery"},
                                    {"family"=>"Terpeluk", "given"=>"Paul"},
                                    {"family"=>"Marder", "given"=>"David"},
                                    {"family"=>"Yesavage", "given"=>"Jerome A."}])
      expect(json["container-title"]).to eq("Pulmonary Medicine")
      expect(json["volume"]).to eq("2012")
      expect(json["page"]).to eq("1-7")
      expect(json["issued"]).to eq("date-parts"=>[[2012]])
    end
  end

  context "get metadata as ris" do
    it "journal article" do
      input = "10.7554/eLife.01567"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      expect(subject.valid?).to be true
      ris = subject.ris.split("\r\n")
      expect(ris[0]).to eq("TY - JOUR")
      expect(ris[1]).to eq("T1 - Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
      expect(ris[2]).to eq("T2 - eLife")
      expect(ris[3]).to eq("AU - Sankar, Martial")
      expect(ris[8]).to eq("DO - 10.7554/eLife.01567")
      expect(ris[9]).to eq("UR - http://elifesciences.org/lookup/doi/10.7554/eLife.01567")
      expect(ris[10]).to eq("PY - 2014")
      expect(ris[11]).to eq("VL - 3")
      expect(ris[12]).to eq("ER - ")
    end

    it "with pages" do
      input = "https://doi.org/10.1155/2012/291294"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      expect(subject.valid?).to be true
      ris = subject.ris.split("\r\n")
      expect(ris[0]).to eq("TY - JOUR")
      expect(ris[1]).to eq("T1 - Delineating a Retesting Zone Using Receiver Operating Characteristic Analysis on Serial QuantiFERON Tuberculosis Test Results in US Healthcare Workers")
      expect(ris[2]).to eq("T2 - Pulmonary Medicine")
      expect(ris[3]).to eq("AU - Thanassi, Wendy")
      expect(ris[10]).to eq("DO - 10.1155/2012/291294")
      expect(ris[11]).to eq("UR - http://www.hindawi.com/journals/pm/2012/291294/")
      expect(ris[12]).to eq("PY - 2012")
      expect(ris[13]).to eq("VL - 2012")
      expect(ris[14]).to eq("SP - 1-7")
      expect(ris[15]).to eq("ER - ")
    end
  end

  context "get metadata as turtle" do
    it "journal article" do
      inputs = "10.7554/eLife.01567"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      expect(subject.valid?).to be true
      ttl = subject.turtle.split("\n")
      expect(ttl[0]).to eq("@prefix schema: <http://schema.org/> .")
      expect(ttl[2]).to eq("<https://doi.org/10.7554/elife.01567> a schema:ScholarlyArticle;")
    end

    it "with pages" do
      input = "https://doi.org/10.1155/2012/291294"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      expect(subject.valid?).to be true
      ttl = subject.turtle.split("\n")
      expect(ttl[0]).to eq("@prefix schema: <http://schema.org/> .")
      expect(ttl[2]).to eq("<https://doi.org/10.1155/2012/291294> a schema:ScholarlyArticle;")
    end
  end

  context "get metadata as rdf_xml" do
    it "journal article" do
      input = "10.7554/eLife.01567"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      expect(subject.valid?).to be true
      rdf_xml = Maremma.from_xml(subject.rdf_xml).fetch("RDF", {})
      expect(rdf_xml.dig("ScholarlyArticle", "rdf:about")).to eq("https://doi.org/10.7554/elife.01567")
      expect(rdf_xml.dig("ScholarlyArticle", "name")).to eq("Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
      expect(rdf_xml.dig("ScholarlyArticle", "datePublished", "__content__")).to eq("2014-02-11")
    end

    it "with pages" do
      input = "https://doi.org/10.1155/2012/291294"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      expect(subject.valid?).to be true
      rdf_xml = Maremma.from_xml(subject.rdf_xml).fetch("RDF", {})
      expect(rdf_xml.dig("ScholarlyArticle", "rdf:about")).to eq("https://doi.org/10.1155/2012/291294")
      expect(rdf_xml.dig("ScholarlyArticle", "name")).to eq("Delineating a Retesting Zone Using Receiver Operating Characteristic Analysis on Serial QuantiFERON Tuberculosis Test Results in US Healthcare Workers")
      expect(rdf_xml.dig("ScholarlyArticle", "datePublished", "__content__")).to eq("2012")
      expect(rdf_xml.dig("ScholarlyArticle", "pageStart")).to eq("1")
      expect(rdf_xml.dig("ScholarlyArticle", "pageEnd")).to eq("7")
    end
  end
end
