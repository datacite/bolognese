require 'spec_helper'

describe Bolognese::Datacite, vcr: true do
  let(:id) { "https://doi.org/10.5061/DRYAD.8515" }

  subject { Bolognese::Datacite.new(id: id) }

  context "get metadata" do
    it "Dataset" do
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
      expect(subject.has_part).to eq([{"id"=>"https://doi.org/10.5061/dryad.8515/1", "relationType"=>"HasPart"}, {"id"=>"https://doi.org/10.5061/dryad.8515/2", "relationType"=>"HasPart"}])
      expect(subject.references).to eq("id"=>"https://doi.org/10.1371/journal.ppat.1000446", "relationType"=>"IsReferencedBy")
      expect(subject.publisher).to eq("Dryad Digital Repository")
      expect(subject.provider).to eq("DataCite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-3")
    end

    it "BlogPosting" do
      id = "https://doi.org/10.5438/4K3M-NYVG"
      subject = Bolognese::Datacite.new(id: id)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(subject.type).to eq("ScholarlyArticle")
      expect(subject.additional_type).to eq("BlogPosting")
      expect(subject.resource_type_general).to eq("Text")
      expect(subject.author).to eq("type"=>"Person", "id"=>"http://orcid.org/0000-0003-1419-2405", "name"=>"Fenner, Martin", "givenName"=>"Martin", "familyName"=>"Fenner")
      expect(subject.title).to eq("Eating your own Dog Food")
      expect(subject.alternate_name).to eq("type"=>"Local accession number", "name"=>"MS-49-3632-5083")
      expect(subject.description).to start_with("Eating your own dog food")
      expect(subject.date_published).to eq("2016-12-20")
      expect(subject.date_modified).to eq("2016-12-20")
      expect(subject.is_part_of).to eq("id"=>"https://doi.org/10.5438/0000-00ss", "relationType"=>"IsPartOf")
      expect(subject.references).to eq([{"id"=>"https://doi.org/10.5438/0012", "relationType"=>"References"}, {"id"=>"https://doi.org/10.5438/55e5-t5c0", "relationType"=>"References"}])
      expect(subject.publisher).to eq("DataCite")
      expect(subject.provider).to eq("DataCite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-4")
    end

    it "date" do
      id = "https://doi.org/10.4230/lipics.tqc.2013.93"
      subject = Bolognese::Datacite.new(id: id)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.4230/lipics.tqc.2013.93")
      expect(subject.type).to eq("ScholarlyArticle")
      expect(subject.additional_type).to eq("ConferencePaper")
      expect(subject.resource_type_general).to eq("Text")
      expect(subject.author).to eq("type"=>"Person", "name"=>"Nathaniel Johnston", "givenName"=>"Nathaniel", "familyName"=>"Johnston")
      expect(subject.title).to eq("The Minimum Size of Qubit Unextendible Product Bases")
      expect(subject.description).to start_with("\n\tWe investigate the problem of constructing unextendible product bases in the qubit case")
      expect(subject.date_published).to eq("2013")
      expect(subject.publisher).to eq("Schloss Dagstuhl - Leibniz-Zentrum fuer Informatik GmbH, Wadern/Saarbruecken, Germany")
      expect(subject.provider).to eq("DataCite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-2.1")
    end

    it "multiple licenses" do
      id = "https://doi.org/10.5281/ZENODO.48440"
      subject = Bolognese::Datacite.new(id: id)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.5281/zenodo.48440")
      expect(subject.type).to eq("SoftwareSourceCode")
      expect(subject.additional_type).to eq("Software")
      expect(subject.resource_type_general).to eq("Software")
      expect(subject.author).to eq("type"=>"Person", "name"=>"Kristian Garza", "givenName"=>"Kristian", "familyName"=>"Garza")
      expect(subject.title).to eq("Analysis Tools for Crossover Experiment of UI using Choice Architecture")
      expect(subject.description).to start_with("<p>&nbsp;</p>\n\n<p>This tools are used to analyse the data produced by the Crosssover Experiment")
      expect(subject.license).to eq([{"url"=>"info:eu-repo/semantics/openAccess", "name"=>"Open Access"}, {"url"=>"https://creativecommons.org/licenses/by-nc-sa/4.0/", "name"=>"Creative Commons Attribution-NonCommercial-ShareAlike"}])
      expect(subject.date_published).to eq("2016-03-27")
      expect(subject.references).to eq("id"=>"https://github.com/kjgarza/frame_experiment_analysis/tree/v1.0", "relationType"=>"IsSupplementTo")
      expect(subject.publisher).to eq("Zenodo")
      expect(subject.provider).to eq("DataCite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-3")
    end

    it "is identical to" do
      id = "10.6084/M9.FIGSHARE.4234751.V1"
      subject = Bolognese::Datacite.new(id: id)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.6084/m9.figshare.4234751.v1")
      expect(subject.type).to eq("Dataset")
      expect(subject.additional_type).to eq("Dataset")
      expect(subject.resource_type_general).to eq("Dataset")
      expect(subject.author.count).to eq(11)
      expect(subject.author.first).to eq("type"=>"Person", "id"=>"http://orcid.org/0000-0002-2410-9671", "name"=>"Alexander Junge", "givenName"=>"Alexander", "familyName"=>"Junge")
      expect(subject.title).to eq("RAIN v1")
      expect(subject.description).to start_with("<div><b>RAIN: RNA–protein Association and Interaction Networks")
      expect(subject.license).to eq("url"=>"https://creativecommons.org/licenses/by/4.0/", "name"=>"CC-BY")
      expect(subject.date_published).to eq("2016")
      expect(subject.is_identical_to).to eq("id"=>"https://doi.org/10.6084/m9.figshare.4234751", "relationType"=>"IsIdenticalTo")
      expect(subject.publisher).to eq("Figshare")
      expect(subject.provider).to eq("DataCite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-3")
    end

    it "funding schema version 3" do
      id = "https://doi.org/10.5281/ZENODO.1239"
      subject = Bolognese::Datacite.new(id: id)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.5281/zenodo.1239")
      expect(subject.type).to eq("Dataset")
      expect(subject.additional_type).to eq("Dataset")
      expect(subject.resource_type_general).to eq("Dataset")
      expect(subject.author.length).to eq(4)
      expect(subject.author.first).to eq("type"=>"Person", "name"=>"Najko Jahn", "givenName"=>"Najko", "familyName"=>"Jahn")
      expect(subject.title).to eq("Publication FP7 Funding Acknowledgment - PLOS OpenAIRE")
      expect(subject.description).to start_with("The dataset contains a sample of metadata describing papers")
      expect(subject.date_published).to eq("2013-04-03")
      expect(subject.publisher).to eq("OpenAIRE Orphan Record Repository")
      expect(subject.funder).to eq("name" => "European Commission")
      expect(subject.provider).to eq("DataCite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-3")
    end

    it "Funding schema version 4" do
      id = "https://doi.org/10.5438/6423"
      subject = Bolognese::Datacite.new(id: id)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.5438/6423")
      expect(subject.type).to eq("Collection")
      expect(subject.additional_type).to eq("Project")
      expect(subject.resource_type_general).to eq("Collection")
      expect(subject.author.length).to eq(24)
      expect(subject.author.first).to eq("type"=>"Person", "id"=>"http://orcid.org/0000-0001-5331-6592", "name"=>"Farquhar, Adam", "givenName"=>"Adam", "familyName"=>"Farquhar")
      expect(subject.title).to eq("Technical and Human Infrastructure for Open Research (THOR)")
      expect(subject.description).to start_with("\n<p>Five years ago, a global infrastructure")
      expect(subject.date_published).to eq("2015")
      expect(subject.publisher).to eq("DataCite")
      expect(subject.funder).to eq("identifier"=>"https://doi.org/10.13039/501100000780", "name"=>"European Commission")
      expect(subject.provider).to eq("DataCite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-4")

      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.dig("fundingReferences", "fundingReference")).to eq("awardNumber" => {"awardURI"=>"http://cordis.europa.eu/project/rcn/194927_en.html", "__content__"=>"654039"},
                                                                          "awardTitle" => "THOR – Technical and Human Infrastructure for Open Research",
                                                                          "funderIdentifier" => {"funderIdentifierType"=>"Crossref Funder ID", "__content__"=>"http://dx.doi.org/10.13039/501100000780"},
                                                                          "funderName" => "European Commission")
    end

    it "Schema.org JSON" do
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.5061/dryad.8515")
    end
  end

  context "get metadata as string" do
    it "BlogPosting" do
      string = IO.read(fixture_path + "datacite.xml")
      subject = Bolognese::Datacite.new(string: string)
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

    it "missing creator" do
      string = IO.read(fixture_path + "datacite_missing_creator.xml")
      subject = Bolognese::Datacite.new(string: string)
      expect(subject.valid?).to be false
      expect(subject.id).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(subject.errors).to eq("Element '{http://datacite.org/schema/kernel-4}creators': Missing child element(s). Expected is ( {http://datacite.org/schema/kernel-4}creator ).")
    end
  end

  context "get metadata as datacite xml 4.0" do
    it "Dataset" do
      id = "https://doi.org/10.5061/DRYAD.8515"
      subject = Bolognese::Datacite.new(id: id, regenerate: true)
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
      expect(subject.references).to eq("id"=>"https://doi.org/10.1371/journal.ppat.1000446", "relationType"=>"IsReferencedBy")
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
      subject = Bolognese::Datacite.new(id: id)
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
      subject = Bolognese::Datacite.new(id: id)
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
end
