require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  let(:input) { "https://doi.org/10.5061/DRYAD.8515" }

  subject { Bolognese::Metadata.new(input: input) }

  context "get datacite raw" do
    it "BlogPosting" do
      input = fixture_path + 'datacite.xml'
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.raw).to eq(IO.read(input).strip)
    end
  end

  context "get datacite metadata" do
    it "Dataset" do
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.5061/dryad.8515")
      expect(subject.b_url).to eq("http://datadryad.org/resource/doi:10.5061/dryad.8515")
      expect(subject.type).to eq("Dataset")
      expect(subject.additional_type).to eq("DataPackage")
      expect(subject.resource_type_general).to eq("Dataset")
      expect(subject.ris_type).to eq("DATA")
      expect(subject.citeproc_type).to eq("dataset")
      expect(subject.author.length).to eq(8)
      expect(subject.author.first).to eq("type"=>"Person", "name"=>"Benjamin Ollomo", "givenName"=>"Benjamin", "familyName"=>"Ollomo")
      expect(subject.title).to eq("Data from: A new malaria agent in African hominids.")
      expect(subject.alternate_name).to eq("type"=>"citation", "name"=>"Ollomo B, Durand P, Prugnolle F, Douzery EJP, Arnathau C, Nkoghe D, Leroy E, Renaud F (2009) A new malaria agent in African hominids. PLoS Pathogens 5(5): e1000446.")
      expect(subject.license).to eq("id"=>"http://creativecommons.org/publicdomain/zero/1.0")
      expect(subject.date_published).to eq("2011")
      expect(subject.has_part).to eq([{"type"=>"CreativeWork", "id"=>"https://doi.org/10.5061/dryad.8515/1"}, {"type"=>"CreativeWork", "id"=>"https://doi.org/10.5061/dryad.8515/2"}])
      expect(subject.is_referenced_by).to eq("type"=>"CreativeWork", "id"=>"https://doi.org/10.1371/journal.ppat.1000446")
      expect(subject.publisher).to eq("Dryad Digital Repository")
      expect(subject.service_provider).to eq("DataCite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-4")
    end

    it "BlogPosting" do
      input = "https://doi.org/10.5438/4K3M-NYVG"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(subject.type).to eq("ScholarlyArticle")
      expect(subject.additional_type).to eq("BlogPosting")
      expect(subject.resource_type_general).to eq("Text")
      expect(subject.ris_type).to eq("RPRT")
      expect(subject.citeproc_type).to eq("article-journal")
      expect(subject.author).to eq("type"=>"Person", "id"=>"https://orcid.org/0000-0003-1419-2405", "name"=>"Fenner, Martin", "givenName"=>"Martin", "familyName"=>"Fenner")
      expect(subject.title).to eq("Eating your own Dog Food")
      expect(subject.alternate_name).to eq("type"=>"Local accession number", "name"=>"MS-49-3632-5083")
      expect(subject.description["text"]).to start_with("Eating your own dog food")
      expect(subject.date_published).to eq("2016-12-20")
      expect(subject.date_modified).to eq("2016-12-20")
      expect(subject.is_part_of).to eq("type"=>"CreativeWork", "id"=>"https://doi.org/10.5438/0000-00ss")
      expect(subject.references).to eq([{"type"=>"CreativeWork", "id"=>"https://doi.org/10.5438/0012"}, {"type"=>"CreativeWork", "id"=>"https://doi.org/10.5438/55e5-t5c0"}])
      expect(subject.publisher).to eq("DataCite")
      expect(subject.service_provider).to eq("DataCite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-4")
    end

    it "date" do
      input = "https://doi.org/10.4230/lipics.tqc.2013.93"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.4230/lipics.tqc.2013.93")
      expect(subject.type).to eq("ScholarlyArticle")
      expect(subject.additional_type).to eq("ConferencePaper")
      expect(subject.resource_type_general).to eq("Text")
      expect(subject.author).to eq("type"=>"Person", "name"=>"Nathaniel Johnston", "givenName"=>"Nathaniel", "familyName"=>"Johnston")
      expect(subject.title).to eq("The Minimum Size of Qubit Unextendible Product Bases")
      expect(subject.description["text"]).to start_with("We investigate the problem of constructing unextendible product bases in the qubit case")
      expect(subject.date_published).to eq("2013")
      expect(subject.publisher).to eq("Schloss Dagstuhl - Leibniz-Zentrum fuer Informatik GmbH, Wadern/Saarbruecken, Germany")
      expect(subject.service_provider).to eq("DataCite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-2.1")
    end

    it "multiple licenses" do
      input = "https://doi.org/10.5281/ZENODO.48440"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.5281/zenodo.48440")
      expect(subject.type).to eq("SoftwareSourceCode")
      expect(subject.resource_type_general).to eq("Software")
      expect(subject.ris_type).to eq("COMP")
      expect(subject.citeproc_type).to eq("article")
      expect(subject.author).to eq("type"=>"Person", "name"=>"Kristian Garza", "givenName"=>"Kristian", "familyName"=>"Garza")
      expect(subject.title).to eq("Analysis Tools For Crossover Experiment Of Ui Using Choice Architecture")
      expect(subject.description["text"]).to start_with("This tools are used to analyse the data produced by the Crosssover Experiment")
      expect(subject.license).to eq("name"=>"Open Access")
      expect(subject.date_published).to eq("2016-03-27")
      expect(subject.is_supplement_to).to eq("type"=>"CreativeWork", "id"=>"https://github.com/kjgarza/frame_experiment_analysis/tree/v1.0")
      expect(subject.publisher).to eq("Zenodo")
      expect(subject.service_provider).to eq("DataCite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-3")
    end

    it "is identical to" do
      input = "10.6084/M9.FIGSHARE.4234751.V1"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.6084/m9.figshare.4234751.v1")
      expect(subject.type).to eq("Dataset")
      expect(subject.additional_type).to eq("Dataset")
      expect(subject.resource_type_general).to eq("Dataset")
      expect(subject.author.count).to eq(11)
      expect(subject.author.first).to eq("type"=>"Person", "id"=>"https://orcid.org/0000-0002-2410-9671", "name"=>"Alexander Junge", "givenName"=>"Alexander", "familyName"=>"Junge")
      expect(subject.title).to eq("RAIN v1")
      expect(subject.description["text"]).to start_with("<b>RAIN: RNA–protein Association and Interaction Networks")
      expect(subject.license).to eq("id"=>"https://creativecommons.org/licenses/by/4.0", "name"=>"CC-BY")
      expect(subject.date_published).to eq("2016")
      expect(subject.is_identical_to).to eq("type"=>"CreativeWork", "id"=>"https://doi.org/10.6084/m9.figshare.4234751")
      expect(subject.publisher).to eq("Figshare")
      expect(subject.service_provider).to eq("DataCite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-3")
    end

    it "funding schema version 3" do
      input = "https://doi.org/10.5281/ZENODO.1239"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.5281/zenodo.1239")
      expect(subject.type).to eq("Dataset")
      expect(subject.resource_type_general).to eq("Dataset")
      expect(subject.author.length).to eq(4)
      expect(subject.author.first).to eq("type"=>"Person", "name"=>"Najko Jahn", "givenName"=>"Najko", "familyName"=>"Jahn")
      expect(subject.title).to eq("Publication FP7 Funding Acknowledgment - PLOS OpenAIRE")
      expect(subject.description["text"]).to start_with("The dataset contains a sample of metadata describing papers")
      expect(subject.date_published).to eq("2013-04-03")
      expect(subject.publisher).to eq("OpenAIRE Orphan Record Repository")
      expect(subject.funding).to eq("type"=>"Award", "identifier"=>"246686", "funder"=>{"type"=>"Organization", "id"=>"https://doi.org/10.13039/501100000780", "name"=>"European Commission"})
      expect(subject.service_provider).to eq("DataCite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-3")
    end

    it "author only full name" do
      input = "https://doi.org/10.14457/KMITL.RES.2006.17"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.14457/kmitl.res.2006.17")
      expect(subject.type).to eq("Dataset")
      expect(subject.author.length).to eq(1)
      expect(subject.author.first).to eq(["name", "กัญจนา แซ่เตียว"])
    end

    it "multiple author names in one creatorName" do
      input = "https://doi.org/10.7910/DVN/EQTQYO"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.7910/dvn/eqtqyo")
      expect(subject.type).to eq("Dataset")
      expect(subject.author).to eq("name" => "Enos, Ryan (Harvard University); Fowler, Anthony (University Of Chicago); Vavreck, Lynn (UCLA)")
    end

    it "author with scheme" do
      input = "https://doi.org/10.18429/JACOW-IPAC2016-TUPMY003"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.18429/jacow-ipac2016-tupmy003")
      expect(subject.type).to eq("ScholarlyArticle")
      expect(subject.author.length).to eq(12)
      expect(subject.author.first).to eq("type"=>"Person", "id"=>"http://jacow.org/JACoW-00077389", "name"=>"Masashi Otani", "givenName"=>"Masashi", "familyName"=>"Otani")
    end

    it "author with wrong orcid scheme" do
      input = "https://doi.org/10.2314/COSCV1"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.2314/coscv1")
      expect(subject.type).to eq("ScholarlyArticle")
      expect(subject.author.length).to eq(14)
      expect(subject.author.first).to eq("type"=>"Person", "id"=>"https://orcid.org/0000-0003-0232-7085", "name"=>"Lambert Heller", "givenName"=>"Lambert", "familyName"=>"Heller")
    end

    it "keywords with attributes" do
      input = "https://doi.org/10.21233/n34n5q"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.21233/n34n5q")
      expect(subject.keywords).to eq([{"subject_scheme"=>"Library of Congress", "scheme_uri"=>"http://id.loc.gov/authorities/subjects", "text"=>"Paleoecology"}])
    end

    it "Funding" do
      input = "https://doi.org/10.15125/BATH-00114"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.15125/bath-00114")
      expect(subject.type).to eq("Dataset")
      expect(subject.additional_type).to eq("Dataset")
      expect(subject.resource_type_general).to eq("Dataset")
      expect(subject.author.length).to eq(2)
      expect(subject.author.first).to eq("type"=>"Person", "id"=>"https://orcid.org/0000-0001-8740-8284", "name"=>"Bimbo, Nuno", "givenName"=>"Nuno", "familyName"=>"Bimbo")
      expect(subject.title).to eq("Dataset for \"Direct Evidence for Solid-Like Hydrogen in a Nanoporous Carbon Hydrogen Storage Material at Supercritical Temperatures\"")
      expect(subject.description.first["text"]).to start_with("Dataset for Direct Evidence for Solid-Like Hydrogen")
      expect(subject.date_published).to eq("2015")
      expect(subject.publisher).to eq("University of Bath")
      expect(subject.funding.length).to eq(5)
      expect(subject.funding.first).to eq("type"=>"Award", "name"=>"SUPERGEN Hub Funding", "identifier"=>"EP/J016454/1", "funder" => {"type"=>"Organization", "id"=>"https://doi.org/10.13039/501100000266", "name"=>"Engineering and Physical Sciences Research Council (EPSRC)"})
      expect(subject.service_provider).to eq("DataCite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-4")
    end

    it "Funding schema version 4" do
      input = "https://doi.org/10.5438/6423"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.5438/6423")
      expect(subject.type).to eq("Collection")
      expect(subject.additional_type).to eq("Project")
      expect(subject.resource_type_general).to eq("Collection")
      expect(subject.ris_type).to eq("GEN")
      expect(subject.citeproc_type).to eq("article")
      expect(subject.author.length).to eq(24)
      expect(subject.author.first).to eq("type"=>"Person", "id"=>"https://orcid.org/0000-0001-5331-6592", "name"=>"Farquhar, Adam", "givenName"=>"Adam", "familyName"=>"Farquhar")
      expect(subject.title).to eq("Technical and Human Infrastructure for Open Research (THOR)")
      expect(subject.description["text"]).to start_with("Five years ago, a global infrastructure")
      expect(subject.date_published).to eq("2015")
      expect(subject.publisher).to eq("DataCite")
      expect(subject.funding).to eq("type"=>"Award",
                                    "funder" => {"type"=>"Organization", "id"=>"https://doi.org/10.13039/501100000780", "name"=>"European Commission"},
                                    "identifier" => "654039",
                                    "name" => "THOR – Technical and Human Infrastructure for Open Research",
                                    "url" => "http://cordis.europa.eu/project/rcn/194927_en.html")
      expect(subject.service_provider).to eq("DataCite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-4")
    end

    it "BlogPosting from string" do
      input = fixture_path + "datacite.xml"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(subject.type).to eq("ScholarlyArticle")
      expect(subject.additional_type).to eq("BlogPosting")
      expect(subject.resource_type_general).to eq("Text")
      expect(subject.ris_type).to eq("RPRT")
      expect(subject.citeproc_type).to eq("article-journal")
      expect(subject.author).to eq("type"=>"Person", "id"=>"https://orcid.org/0000-0003-1419-2405", "name"=>"Fenner, Martin", "givenName"=>"Martin", "familyName"=>"Fenner")
      expect(subject.title).to eq("Eating your own Dog Food")
      expect(subject.alternate_name).to eq("type"=>"Local accession number", "name"=>"MS-49-3632-5083")
      expect(subject.date_published).to eq("2016-12-20")
      expect(subject.publication_year).to eq(2016)
      expect(subject.is_part_of).to eq("type"=>"CreativeWork", "id"=>"https://doi.org/10.5438/0000-00ss")
      expect(subject.references).to eq([{"type"=>"CreativeWork", "id"=>"https://doi.org/10.5438/0012"}, {"type"=>"CreativeWork", "id"=>"https://doi.org/10.5438/55e5-t5c0"}])
      expect(subject.service_provider).to eq("DataCite")
    end

    it "Schema 4.1 from string" do
      input = fixture_path + "datacite-example-complicated-v4.1.xml"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.5072/testpub")
      expect(subject.type).to eq("Book")
      expect(subject.additional_type).to eq("Monograph")
      expect(subject.resource_type_general).to eq("Text")
      expect(subject.ris_type).to eq("BOOK")
      expect(subject.citeproc_type).to eq("book")
      expect(subject.author).to eq([{"type"=>"Person", "name"=>"John Smith", "givenName"=>"John", "familyName"=>"Smith"}, {"name"=>"つまらないものですが"}])
      expect(subject.title).to eq(["Właściwości rzutowań podprzestrzeniowych", {"title_type"=>"TranslatedTitle", "text"=>"Translation of Polish titles"}])
      expect(subject.alternate_name).to eq("type"=>"ISBN", "name"=>"937-0-4523-12357-6")
      expect(subject.date_published).to eq("2010")
      expect(subject.publication_year).to eq(2010)
      expect(subject.is_part_of).to eq("type"=>"CreativeWork", "id"=>"https://doi.org/10.5272/oldertestpub")
      expect(subject.license).to eq("id"=>"http://creativecommons.org/licenses/by-nd/2.0", "name"=>"Creative Commons Attribution-NoDerivs 2.0 Generic")
      expect(subject.publisher).to eq("Springer")
      expect(subject.service_provider).to eq("DataCite")
    end

    it "Schema 4.1 from string with doi in options" do
      input = fixture_path + "datacite-example-complicated-v4.1.xml"
      subject = Bolognese::Metadata.new(input: input, doi: "10.5072/testpub2")
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.5072/testpub2")
      expect(subject.type).to eq("Book")
      expect(subject.additional_type).to eq("Monograph")
      expect(subject.resource_type_general).to eq("Text")
      expect(subject.author).to eq([{"type"=>"Person", "name"=>"John Smith", "givenName"=>"John", "familyName"=>"Smith"}, {"name"=>"つまらないものですが"}])
      expect(subject.title).to eq(["Właściwości rzutowań podprzestrzeniowych", {"title_type"=>"TranslatedTitle", "text"=>"Translation of Polish titles"}])
      expect(subject.alternate_name).to eq("type"=>"ISBN", "name"=>"937-0-4523-12357-6")
      expect(subject.date_published).to eq("2010")
      expect(subject.publication_year).to eq(2010)
      expect(subject.is_part_of).to eq("type"=>"CreativeWork", "id"=>"https://doi.org/10.5272/oldertestpub")
      expect(subject.license).to eq("id"=>"http://creativecommons.org/licenses/by-nd/2.0", "name"=>"Creative Commons Attribution-NoDerivs 2.0 Generic")
      expect(subject.publisher).to eq("Springer")
      expect(subject.service_provider).to eq("DataCite")
    end

    it "subject scheme" do
      input = "https://doi.org/10.4232/1.2745"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.4232/1.2745")
      expect(subject.type).to eq("Dataset")
      expect(subject.resource_type_general).to eq("Dataset")
      expect(subject.author).to eq("name"=>"Europäische Kommission")
      expect(subject.title).to eq([{"lang"=>"de", "text"=>"Flash Eurobarometer 54 (Madrid Summit)"}, {"lang"=>"en", "text"=>"Flash Eurobarometer 54 (Madrid Summit)"}, {"title_type"=>"Subtitle","lang"=>"de", "text"=>"The Common European Currency"}, {"title_type"=>"Subtitle", "lang"=>"en", "text"=>"The Common European Currency"}])
      expect(subject.keywords).to eq([{"subject_scheme"=>"ZA", "text"=>"KAT12 International Institutions, Relations, Conditions"}])
      expect(subject.date_published).to eq("1996")
      expect(subject.publisher).to eq("GESIS Data Archive")
      expect(subject.service_provider).to eq("DataCite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-4")
    end

    it "empty subject" do
      input = "https://doi.org/10.18169/PAPDEOTTX00502"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.18169/papdeottx00502")
      expect(subject.type).to eq("Dataset")
      expect(subject.additional_type).to eq("Disclosure")
      expect(subject.resource_type_general).to eq("Dataset")
      expect(subject.author).to eq("name"=>"Anonymous")
      expect(subject.title).to eq( "Messung der Bildunschaerfe in H.264-codierten Bildern und Videosequenzen")
      expect(subject.date_published).to eq("2017")
      expect(subject.publisher).to eq("Siemens AG")
      expect(subject.service_provider).to eq("DataCite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-3")
    end

    it "leading and trailing whitespace" do
      input = "https://doi.org/10.21944/temis-OZONE-MSR2"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.21944/temis-ozone-msr2")
      expect(subject.type).to eq("Dataset")
      expect(subject.additional_type).to eq("Satellite data")
      expect(subject.resource_type_general).to eq("Dataset")
      expect(subject.author).to eq([{"type"=>"Person",
                                     "id"=>"https://orcid.org/0000-0002-0077-5338",
                                     "name"=>"Ronald Van Der A",
                                     "givenName"=>"Ronald",
                                     "familyName"=>"Van Der A"},
                                    {"type"=>"Person",
                                     "name"=>"Marc Allaart",
                                     "givenName"=>"Marc",
                                     "familyName"=>"Allaart"},
                                    {"type"=>"Person",
                                     "id"=>"https://orcid.org/0000-0002-8743-4455",
                                     "name"=>"Henk Eskes",
                                     "givenName"=>"Henk",
                                     "familyName"=>"Eskes"}])
      expect(subject.title).to eq("Multi-Sensor Reanalysis (MSR) of total ozone, version 2")
      expect(subject.b_version).to eq("2")
      expect(subject.date_published).to eq("2015")
      expect(subject.publisher).to eq("Royal Netherlands Meteorological Institute (KNMI)")
      expect(subject.service_provider).to eq("DataCite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-4")
    end

    it "DOI not found" do
      input = "https://doi.org/10.4124/05F6C379-DD68-4CDB-880D-33D3E9576D52/1"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be false
      expect(subject.identifier).to eq("https://doi.org/10.4124/05f6c379-dd68-4cdb-880d-33d3e9576d52/1")
      expect(subject.doi).to eq("10.4124/05f6c379-dd68-4cdb-880d-33d3e9576d52/1")
      expect(subject.service_provider).to eq("DataCite")
      expect(subject.state).to eq("not_found")
    end

    it "DOI in test system" do
      input = "https://handle.test.datacite.org/10.22002/d1.694"
      subject = Bolognese::Metadata.new(input: input, sandbox: true)
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://handle.test.datacite.org/10.22002/d1.694")
      expect(subject.type).to eq("Dataset")
      expect(subject.resource_type_general).to eq("Dataset")
      expect(subject.author).to eq("name"=>"Tester")
      expect(subject.title).to eq("Test license")
      expect(subject.date_published).to eq("2018-01-12")
      expect(subject.publication_year).to eq(2018)
      expect(subject.publisher).to eq("CaltechDATA")
      expect(subject.service_provider).to eq("DataCite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-4")
      expect(subject.state).to eq("findable")
    end

    it "Referee report in test system" do
      input = "10.21956/gatesopenres.530.r190"
      subject = Bolognese::Metadata.new(input: input, sandbox: true)
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://handle.test.datacite.org/10.21956/gatesopenres.530.r190")
      expect(subject.type).to eq("ScholarlyArticle")
      expect(subject.resource_type_general).to eq("Text")
      expect(subject.ris_type).to eq("RPRT")
      expect(subject.citeproc_type).to eq("article-journal")
      expect(subject.author.length).to eq(5)
      expect(subject.author.first).to eq("type"=>"Person", "name"=>"Lina Patel", "givenName"=>"Lina", "familyName"=>"Patel")
      expect(subject.title).to eq("Referee report. For: Gates - add article keywords to the metatags [version 2; referees: 1 approved]")
      expect(subject.date_published).to eq("2018")
      expect(subject.publisher).to eq("Gates Open Research")
      expect(subject.service_provider).to eq("DataCite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-3")
    end

    it "missing creator" do
      input = fixture_path + "datacite_missing_creator.xml"
      subject = Bolognese::Metadata.new(input: input, regenerate: true)
      expect(subject.author).to be_nil
      expect(subject.valid?).to be false
      expect(subject.errors).to eq("4:0: ERROR: Element '{http://datacite.org/schema/kernel-4}creators': Missing child element(s). Expected is ( {http://datacite.org/schema/kernel-4}creator ).")
    end

    it "dissertation" do
      input = "10.3204/desy-2014-01645"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.3204/desy-2014-01645")
      expect(subject.resource_type_general).to eq("Text")
      expect(subject.additional_type).to eq("Dissertation")
      expect(subject.type).to eq("Thesis")
      expect(subject.bibtex_type).to eq("phdthesis")
      expect(subject.citeproc_type).to eq("thesis")
      expect(subject.author).to eq("type"=>"Person", "name"=>"Heiko Conrad", "givenName"=>"Heiko", "familyName"=>"Conrad")
      expect(subject.title).to eq("Dynamics of colloids in molecular glass forming liquids studied via X-ray photon correlation spectroscopy")
      expect(subject.date_published).to eq("2014")
      expect(subject.publisher).to eq("Deutsches Elektronen-Synchrotron, DESY, Hamburg")
      expect(subject.service_provider).to eq("DataCite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-3")
    end
  end

  context "change datacite metadata" do
    it "change title" do
      subject.title = "A new malaria agent in African hominids."
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.5061/dryad.8515")
      expect(subject.doi).to eq("10.5061/dryad.8515")
      expect(subject.b_url).to eq("http://datadryad.org/resource/doi:10.5061/dryad.8515")
      expect(subject.type).to eq("Dataset")
      expect(subject.title).to eq("A new malaria agent in African hominids.")
    end

    it "change state" do
      subject.state = "registered"
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.5061/dryad.8515")
      expect(subject.doi).to eq("10.5061/dryad.8515")
      expect(subject.b_url).to eq("http://datadryad.org/resource/doi:10.5061/dryad.8515")
      expect(subject.type).to eq("Dataset")
      expect(subject.title).to eq("Data from: A new malaria agent in African hominids.")
      expect(subject.state).to eq("registered")
    end
  end

  context "change datacite metadata on input" do
    it "change doi" do
      input = fixture_path + 'datacite.xml'
      doi = "10.5061/dryad.8515"
      subject = Bolognese::Metadata.new(input: input, doi: doi)
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.5061/dryad.8515")
      expect(subject.doi).to eq("10.5061/dryad.8515")
      expect(subject.author).to eq("type"=>"Person", "id"=>"https://orcid.org/0000-0003-1419-2405", "name"=>"Fenner, Martin", "givenName"=>"Martin", "familyName"=>"Fenner")
      expect(subject.title).to eq("Eating your own Dog Food")
      expect(subject.publisher).to eq("DataCite")
      expect(subject.publication_year).to eq(2016)
    end
  end
end
