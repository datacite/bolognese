require 'spec_helper'

describe Bolognese::Crossref, vcr: true do
  let(:id) { "10.7554/eLife.01567" }

  subject { Bolognese::Crossref.new(id: id) }

  context "get metadata" do
    it "DOI with data citation" do
      expect(subject.id).to eq("https://doi.org/10.7554/elife.01567")
      expect(subject.type).to eq("ScholarlyArticle")
      expect(subject.url).to eq("http://elifesciences.org/lookup/doi/10.7554/eLife.01567")
      expect(subject.additional_type).to eq("JournalArticle")
      expect(subject.resource_type_general).to eq("Text")
      expect(subject.author.length).to eq(5)
      expect(subject.author.first).to eq("type"=>"Person", "name"=>"Martial Sankar", "givenName"=>"Martial", "familyName"=>"Sankar")
      expect(subject.license).to eq("url"=>"http://creativecommons.org/licenses/by/3.0/")
      expect(subject.title).to eq("Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
      expect(subject.date_published).to eq("2014-02-11")
      expect(subject.date_modified).to eq("2015-08-11T05:35:02Z")
      expect(subject.is_part_of).to eq("type"=>"Periodical", "name"=>"eLife", "issn"=>"2050-084X")
      expect(subject.references.count).to eq(27)
      expect(subject.references[21]).to eq("id"=>"https://doi.org/10.5061/dryad.b835k", "relationType"=>"Cites", "position"=>"22", "datePublished"=>"2014")
      expect(subject.funder).to eq([{"name"=>"SystemsX"},
                                    {"id"=>"https://doi.org/10.13039/501100003043",
                                     "name"=>"EMBO"},
                                    {"id"=>"https://doi.org/10.13039/501100001711",
                                     "name"=>"Swiss National Science Foundation"},
                                    {"id"=>"https://doi.org/10.13039/501100006390",
                                     "name"=>"University of Lausanne"}])
      expect(subject.provider).to eq("Crossref")
    end

    it "journal article" do
      id = "https://doi.org/10.1371/journal.pone.0000030"
      subject = Bolognese::Crossref.new(id: id)
      expect(subject.id).to eq(id)
      expect(subject.url).to eq("http://dx.plos.org/10.1371/journal.pone.0000030")
      expect(subject.type).to eq("ScholarlyArticle")
      expect(subject.additional_type).to eq("JournalArticle")
      expect(subject.resource_type_general).to eq("Text")
      expect(subject.author.length).to eq(5)
      expect(subject.author.first).to eq("type"=>"Person", "name"=>"Markus Ralser", "givenName"=>"Markus", "familyName"=>"Ralser")
      expect(subject.editor).to eq("type"=>"Person", "name"=>"Guilhem Janbon", "givenName"=>"Guilhem", "familyName"=>"Janbon")
      expect(subject.title).to eq("Triose Phosphate Isomerase Deficiency Is Caused by Altered Dimerization–Not Catalytic Inactivity–of the Mutant Enzymes")
      expect(subject.license).to eq("url"=>"http://creativecommons.org/licenses/by/4.0/")
      expect(subject.date_published).to eq("2006-12-20")
      expect(subject.date_modified).to eq("2016-12-31T21:37:08Z")
      expect(subject.page_start).to eq("e30")
      expect(subject.is_part_of).to eq("type"=>"Periodical", "name"=>"PLoS ONE", "issn"=>"1932-6203")
      expect(subject.provider).to eq("Crossref")
    end

    it "posted_content" do
      id = "https://doi.org/10.1101/097196"
      subject = Bolognese::Crossref.new(id: id)
      expect(subject.id).to eq(id)
      expect(subject.url).to eq("http://biorxiv.org/lookup/doi/10.1101/097196")
      expect(subject.type).to eq("ScholarlyArticle")
      expect(subject.additional_type).to eq("PostedContent")
      expect(subject.resource_type_general).to eq("Text")
      expect(subject.author.count).to eq(10)
      expect(subject.author.last).to eq("type"=>"Person", "id"=>"http://orcid.org/0000-0003-4060-7360", "name"=>"Timothy Clark", "givenName"=>"Timothy", "familyName"=>"Clark")
      expect(subject.title).to eq("A Data Citation Roadmap for Scholarly Data Repositories")
      expect(subject.alternate_name).to eq("biorxiv;097196v1")
      expect(subject.description).to start_with("This article presents a practical roadmap")
      expect(subject.date_published).to eq("2016-12-28")
      expect(subject.date_modified).to eq("2016-12-29T00:10:20Z")
      expect(subject.is_part_of).to be_nil
      expect(subject.provider).to eq("Crossref")
    end

    it "DOI with SICI DOI" do
      id = "https://doi.org/10.1890/0012-9658(2006)87[2832:tiopma]2.0.co;2"
      subject = Bolognese::Crossref.new(id: id)
      expect(subject.id).to eq("https://doi.org/10.1890/0012-9658(2006)87%5B2832:tiopma%5D2.0.co;2")
      expect(subject.url).to eq("http://doi.wiley.com/10.1890/0012-9658(2006)87[2832:TIOPMA]2.0.CO;2")
      expect(subject.type).to eq("ScholarlyArticle")
      expect(subject.additional_type).to eq("JournalArticle")
      expect(subject.resource_type_general).to eq("Text")
      expect(subject.author).to eq([{"type"=>"Person", "name"=>"A. Fenton", "givenName"=>"A.", "familyName"=>"Fenton"}, {"type"=>"Person", "name"=>"S. A. Rands", "givenName"=>"S. A.", "familyName"=>"Rands"}])
      expect(subject.license).to eq("url"=>"http://doi.wiley.com/10.1002/tdm_license_1")
      expect(subject.title).to eq("THE IMPACT OF PARASITE MANIPULATION AND PREDATOR FORAGING BEHAVIOR ON PREDATOR–PREY COMMUNITIES")
      expect(subject.date_published).to eq("2006-11")
      expect(subject.date_modified).to eq("2016-10-04T17:20:17Z")
      expect(subject.page_start).to eq("2832")
      expect(subject.page_end).to eq("2841")
      expect(subject.is_part_of).to eq("type"=>"Periodical", "name"=>"Ecology", "issn"=>"0012-9658")
      expect(subject.provider).to eq("Crossref")
    end

    it "DOI with ORCID ID" do
      id = "https://doi.org/10.1155/2012/291294"
      subject = Bolognese::Crossref.new(id: id)
      expect(subject.id).to eq("https://doi.org/10.1155/2012/291294")
      expect(subject.url).to eq("http://www.hindawi.com/journals/pm/2012/291294/")
      expect(subject.type).to eq("ScholarlyArticle")
      expect(subject.additional_type).to eq("JournalArticle")
      expect(subject.resource_type_general).to eq("Text")
      expect(subject.author.length).to eq(7)
      expect(subject.author[2]).to eq("type"=>"Person", "id"=>"http://orcid.org/0000-0003-2043-4925", "name"=>"Beatriz Hernandez", "givenName"=>"Beatriz", "familyName"=>"Hernandez")
      expect(subject.license).to eq("url"=>"http://creativecommons.org/licenses/by/3.0/")
      expect(subject.title).to eq("Delineating a Retesting Zone Using Receiver Operating Characteristic Analysis on Serial QuantiFERON Tuberculosis Test Results in US Healthcare Workers")
      expect(subject.date_published).to eq("2012")
      expect(subject.date_modified).to eq("2016-08-02T12:42:41Z")
      expect(subject.page_start).to eq("1")
      expect(subject.page_end).to eq("7")
      expect(subject.is_part_of).to eq("type"=>"Periodical", "name"=>"Pulmonary Medicine", "issn"=>["2090-1836", "2090-1844"])
      expect(subject.provider).to eq("Crossref")
    end

    it "date in future" do
      id = "https://doi.org/10.1016/j.ejphar.2015.03.018"
      subject = Bolognese::Crossref.new(id: id)
      expect(subject.id).to eq(id)
      expect(subject.url).to eq("http://linkinghub.elsevier.com/retrieve/pii/S0014299915002332")
      expect(subject.type).to eq("ScholarlyArticle")
      expect(subject.additional_type).to eq("JournalArticle")
      expect(subject.resource_type_general).to eq("Text")
      expect(subject.author.length).to eq(10)
      expect(subject.author.first).to eq("type"=>"Person", "name"=>"Sarah E. Beck", "givenName"=>"Sarah E.", "familyName"=>"Beck")
      expect(subject.title).to eq("Paving the path to HIV neurotherapy: Predicting SIV CNS disease")
      expect(subject.date_published).to eq("2015-07")
      expect(subject.date_modified).to eq("2016-08-20T02:19:38Z")
      expect(subject.is_part_of).to eq("type"=>"Periodical", "name"=>"European Journal of Pharmacology", "issn"=>"00142999")
      expect(subject.provider).to eq("Crossref")
    end

    it "not found error" do
      id = "https://doi.org/10.7554/elife.01567x"
      subject = Bolognese::Crossref.new(id: id)
      expect(subject.id).to be_nil
      expect(subject.exists?).to be false
    end

    it "Schema.org JSON" do
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.7554/elife.01567")
    end
  end

  context "get metadata as string" do
    it "DOI with data citation" do
      id = "10.7554/eLife.01567"
      string = Bolognese::Crossref.new(id: id).crossref

      subject = Bolognese::Crossref.new(string: string)
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
      id = "https://doi.org/10.1155/2012/291294"
      subject = Bolognese::Crossref.new(id: id)
      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.dig("resourceType", "resourceTypeGeneral")).to eq("Text")
      expect(datacite.dig("creators", "creator").count).to eq(7)
      expect(datacite.dig("creators", "creator")[2]).to eq("creatorName" => "Hernandez, Beatriz",
       +"familyName" => "Hernandez",
       +"givenName" => "Beatriz",
        "nameIdentifier" => {"schemeURI"=>"http://orcid.org/", "nameIdentifierScheme"=>"ORCID", "__content__"=>"http://orcid.org/0000-0003-2043-4925"})
    end

    it "with editor" do
      id = "https://doi.org/10.1371/journal.pone.0000030"
      subject = Bolognese::Crossref.new(id: id)
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
      id = "https://doi.org/10.1155/2012/291294"
      subject = Bolognese::Crossref.new(id: id)
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
      id = "10.7554/eLife.01567"
      subject = Bolognese::Crossref.new(id: id)
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
      id = "https://doi.org/10.1155/2012/291294"
      subject = Bolognese::Crossref.new(id: id)
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
      id = "10.7554/eLife.01567"
      subject = Bolognese::Crossref.new(id: id)
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
      id = "https://doi.org/10.1155/2012/291294"
      subject = Bolognese::Crossref.new(id: id)
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
      id = "10.7554/eLife.01567"
      subject = Bolognese::Crossref.new(id: id)
      expect(subject.valid?).to be true
      ttl = subject.turtle.split("\n")
      expect(ttl[0]).to eq("@prefix schema: <http://schema.org/> .")
      expect(ttl[2]).to eq("<https://doi.org/10.7554/elife.01567> a schema:ScholarlyArticle;")
    end

    it "with pages" do
      id = "https://doi.org/10.1155/2012/291294"
      subject = Bolognese::Crossref.new(id: id)
      expect(subject.valid?).to be true
      ttl = subject.turtle.split("\n")
      expect(ttl[0]).to eq("@prefix schema: <http://schema.org/> .")
      expect(ttl[2]).to eq("<https://doi.org/10.1155/2012/291294> a schema:ScholarlyArticle;")
    end
  end

  context "get metadata as rdf_xml" do
    it "journal article" do
      id = "10.7554/eLife.01567"
      subject = Bolognese::Crossref.new(id: id)
      expect(subject.valid?).to be true
      rdf_xml = Maremma.from_xml(subject.rdf_xml).fetch("RDF", {})
      expect(rdf_xml.dig("ScholarlyArticle", "rdf:about")).to eq("https://doi.org/10.7554/elife.01567")
      expect(rdf_xml.dig("ScholarlyArticle", "name")).to eq("Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
      expect(rdf_xml.dig("ScholarlyArticle", "datePublished", "__content__")).to eq("2014-02-11")
    end

    it "with pages" do
      id = "https://doi.org/10.1155/2012/291294"
      subject = Bolognese::Crossref.new(id: id)
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
