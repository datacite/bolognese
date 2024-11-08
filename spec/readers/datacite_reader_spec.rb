# frozen_string_literal: true

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
      expect(subject.url).to eq("http://datadryad.org/stash/dataset/doi:10.5061/dryad.8515")
      expect(subject.types["schemaOrg"]).to eq("Dataset")
      expect(subject.types["resourceType"]).to eq("dataset")
      expect(subject.types["resourceTypeGeneral"]).to eq("Dataset")
      expect(subject.types["ris"]).to eq("DATA")
      expect(subject.types["citeproc"]).to eq("dataset")
      expect(subject.creators.length).to eq(8)
      expect(subject.creators.first).to eq("nameType"=>"Personal", "name"=>"Ollomo, Benjamin", "givenName"=>"Benjamin", "familyName"=>"Ollomo", "nameIdentifiers" => [], "affiliation" => [{"affiliationIdentifier"=>"https://ror.org/01wyqb997", "affiliationIdentifierScheme"=>"ROR", "name"=>"Centre International de Recherches Médicales de Franceville"}])
      expect(subject.titles).to eq([{"title"=>"Data from: A new malaria agent in African hominids."}])
      expect(subject.id).to eq("https://doi.org/10.5061/dryad.8515")
      expect(subject.rights_list).to eq([{"rights"=>"Creative Commons Zero v1.0 Universal",
        "rightsIdentifier"=>"cc0-1.0",
        "rightsIdentifierScheme"=>"SPDX",
        "rightsUri"=>"https://creativecommons.org/publicdomain/zero/1.0/legalcode",
        "schemeUri"=>"https://spdx.org/licenses/"}])
      expect(subject.publication_year).to eq("2011")
      expect(subject.related_identifiers.length).to eq(1)
      expect(subject.related_identifiers.last).to eq("relatedIdentifier" => "10.1371/journal.ppat.1000446",
        "relatedIdentifierType" => "DOI","relationType"=>"Cites")
      expect(subject.subjects).to eq([{"subject"=>"Plasmodium"},
        {"subject"=>"malaria"},
        {"subject"=>"taxonomy"},
        {"subject"=>"mitochondrial genome"},
        {"subject"=>"Parasites"}])
      expect(subject.publisher).to eq({"name"=>"Dryad"})
      expect(subject.agency).to eq("datacite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-4")
    end

    it "BlogPosting" do
      input = "https://doi.org/10.5438/4K3M-NYVG"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.types["schemaOrg"]).to eq("ScholarlyArticle")
      expect(subject.types["resourceType"]).to eq("BlogPosting")
      expect(subject.types["resourceTypeGeneral"]).to eq("Text")
      expect(subject.types["ris"]).to eq("RPRT")
      expect(subject.types["bibtex"]).to eq("article")
      expect(subject.types["citeproc"]).to eq("article-journal")
      expect(subject.creators).to eq([{"nameIdentifiers"=> [{"nameIdentifier"=>"https://orcid.org/0000-0003-1419-2405", "nameIdentifierScheme"=>"ORCID", "schemeUri"=>"https://orcid.org"}], "name"=>"Fenner, Martin", "givenName"=>"Martin", "familyName"=>"Fenner"}])
      expect(subject.titles).to eq([{"title"=>"Eating your own Dog Food"}])
      expect(subject.id).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(subject.descriptions.first["description"]).to start_with("Eating your own dog food")
      expect(subject.dates).to eq([{"date"=>"2016-12-20", "dateType"=>"Created"}, {"date"=>"2016-12-20", "dateType"=>"Issued"}, {"date"=>"2016-12-20", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2016")
      expect(subject.related_identifiers.length).to eq(3)
      expect(subject.related_identifiers.last).to eq("relatedIdentifier"=>"10.5438/0000-00ss", "relatedIdentifierType"=>"DOI", "relationType"=>"IsPartOf")
      expect(subject.publisher).to eq({"name"=>"DataCite"})
      expect(subject.subjects).to eq([{"subject"=>"datacite"},
        {"subject"=>"doi"},
        {"subject"=>"metadata"},
        {"schemeUri"=>"http://www.oecd.org/science/inno",
         "subject"=>"FOS: Computer and information sciences",
         "subjectScheme"=>"Fields of Science and Technology (FOS)",
         "valueUri"=>"http://www.oecd.org/science/inno/38235147.pdf"},
        {"schemeUri"=>"http://www.oecd.org/science/inno/38235147.pdf",
         "subject"=>"FOS: Computer and information sciences",
         "subjectScheme"=>"Fields of Science and Technology (FOS)"}])
      expect(subject.agency).to eq("datacite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-4")
    end

    it "date" do
      input = "https://doi.org/10.4230/lipics.tqc.2013.93"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.types["schemaOrg"]).to eq("ScholarlyArticle")
      expect(subject.types["resourceType"]).to eq("ConferencePaper")
      expect(subject.types["resourceTypeGeneral"]).to eq("Text")
      expect(subject.creators).to eq([{"nameType"=>"Personal", "name"=>"Johnston, Nathaniel", "givenName"=>"Nathaniel", "familyName"=>"Johnston", "nameIdentifiers" => [], "affiliation" => []}])
      expect(subject.titles).to eq([{"title"=>"The Minimum Size of Qubit Unextendible Product Bases"}])
      expect(subject.id).to eq("https://doi.org/10.4230/lipics.tqc.2013.93")
      expect(subject.descriptions.first["description"]).to start_with("We investigate the problem of constructing unextendible product bases in the qubit case")
      expect(subject.dates).to eq([{"date"=>"2013-11-05", "dateType"=>"Available"}, {"date"=>"2013", "dateType"=>"Issued"}])
      expect(subject.subjects).to eq([{"subject"=>"Computer Science"},
       {"subject"=>"000 Computer science, knowledge, general works",
        "subjectScheme"=>"DDC"}])
      expect(subject.publication_year).to eq("2013")
      expect(subject.publisher).to eq({"name"=>"Schloss Dagstuhl - Leibniz-Zentrum fuer Informatik GmbH, Wadern/Saarbruecken, Germany"})
      expect(subject.agency).to eq("datacite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-2.1")
    end

    it "affiliation identifier" do
      input = fixture_path + 'datacite-example-affiliation.xml'
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.types["schemaOrg"]).to eq("SoftwareSourceCode")
      expect(subject.types["resourceType"]).to eq("XML")
      expect(subject.types["resourceTypeGeneral"]).to eq("Software")
      expect(subject.types["ris"]).to eq("COMP")
      expect(subject.types["citeproc"]).to eq("article")
      expect(subject.creators.length).to eq(3)
      expect(subject.creators.first).to eq("nameType"=>"Personal", "affiliation" => [{"affiliationIdentifier"=>"https://ror.org/04wxnsj81", "affiliationIdentifierScheme"=>"ROR", "name"=>"DataCite"}],
        "familyName" => "Miller",
        "givenName" => "Elizabeth",
        "name" => "Miller, Elizabeth",
        "nameIdentifiers" => [{"nameIdentifier"=>"https://orcid.org/0000-0001-5000-0007", "nameIdentifierScheme"=>"ORCID", "schemeUri"=>"https://orcid.org"}],)
      expect(subject.creators.dig(1, "affiliation")).to eq([{"affiliationIdentifier"=>"https://ror.org/05gq02987",
        "affiliationIdentifierScheme"=>"ROR",
        "name"=>"Brown University"},
       {"affiliationIdentifier"=>"https://grid.ac/institutes/grid.268117.b",
        "affiliationIdentifierScheme"=>"GRID",
        "name"=>"Wesleyan University", "schemeUri"=>"https://grid.ac/institutes/"}])
      expect(subject.creators.dig(2, "affiliation")).to eq([{"affiliationIdentifier"=>"https://ror.org/05gq02987",
        "affiliationIdentifierScheme"=>"ROR", "name"=>"Brown University"}])
      expect(subject.titles).to eq([{"lang"=>"en-US", "title"=>"Full DataCite XML Example"}, {"lang"=>"en-US", "title"=>"Demonstration of DataCite Properties.", "titleType"=>"Subtitle"}])
      expect(subject.id).to eq("https://doi.org/10.5072/example-full")
      expect(subject.identifiers).to eq([{"identifier"=>
           "https://schema.datacite.org/meta/kernel-4.2/example/datacite-example-full-v4.2.xml",
           "identifierType"=>"URL"}])
      expect(subject.rights_list).to eq([{"lang"=>"en-US", "rights"=>"Creative Commons Zero v1.0 Universal", "rightsIdentifier"=>"cc0-1.0", "rightsIdentifierScheme"=>"SPDX", "rightsUri"=>"https://creativecommons.org/publicdomain/zero/1.0/legalcode", "schemeUri"=>"https://spdx.org/licenses/"}])
      expect(subject.publication_year).to eq("2014")
      expect(subject.contributors).to eq([{"name"=>"Starr, Joan", "givenName"=>"Joan", "familyName"=>"Starr", "nameIdentifiers"=>[{"nameIdentifier"=>"https://orcid.org/0000-0002-7285-027X", "schemeUri"=>"https://orcid.org", "nameIdentifierScheme"=>"ORCID"}], "affiliation"=>
        [{"affiliationIdentifier"=>"https://ror.org/03yrm5c26",
          "affiliationIdentifierScheme"=>"ROR",
          "name"=>"California Digital Library"}], "contributorType"=>"ProjectLeader"}])
      expect(subject.subjects).to eq([{"lang"=>"en-US", "schemeUri"=>"http://dewey.info/", "subject"=>"000 computer science", "subjectScheme"=>"dewey"}])
      expect(subject.dates).to eq([{"date"=>"2017-09-13", "dateInformation"=>"Updated with 4.2 properties", "dateType"=>"Updated"}, {"date"=>"2014", "dateType"=>"Issued"}])
      expect(subject.funding_references).to eq([{"awardNumber"=>"CBET-106",
        "awardTitle"=>"Full DataCite XML Example",
        "funderIdentifier"=>"https://doi.org/10.13039/100000001",
        "funderIdentifierType"=>"Crossref Funder ID",
        "schemeUri"=>"https://doi.org/",
        "funderName"=>"National Science Foundation"}])
      expect(subject.related_identifiers.length).to eq(2)
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"https://data.datacite.org/application/citeproc+json/10.5072/example-full", "relatedIdentifierType"=>"URL", "relationType"=>"HasMetadata", "relatedMetadataScheme"=>"citeproc+json", "schemeUri"=>"https://github.com/citation-style-language/schema/raw/master/csl-data.json")
      expect(subject.related_identifiers.last).to eq("relatedIdentifier"=>"arXiv:0706.0001", "relatedIdentifierType"=>"arXiv", "relationType"=>"IsReviewedBy", "resourceTypeGeneral"=>"Text")
      expect(subject.language).to eq("en-US")
      expect(subject.sizes).to eq(["4 kB"])
      expect(subject.formats).to eq(["application/xml"])
      expect(subject.publisher).to eq(
        {
          "name"=>"DataCite",
          "lang"=>"en",
        }
      )
      expect(subject.agency).to eq("datacite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-4")
    end

    it "xs:string attributes" do
      input = fixture_path + 'pure.xml'
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.types["schemaOrg"]).to eq("Dataset")
      expect(subject.types["resourceType"]).to eq("Dataset")
      expect(subject.types["resourceTypeGeneral"]).to eq("Audiovisual")
      expect(subject.creators.length).to eq(14)
      expect(subject.creators.first).to eq("name"=>"Haywood, Raphaelle Dawn", "givenName"=>"Raphaelle Dawn", "familyName"=>"Haywood", "affiliation" => [{"name"=>"School of Physics and Astronomy"}])
      expect(subject.titles).to eq([{"lang"=>"en", "title"=>"Data underpinning - The Sun as a planet-host star: Proxies from SDO images for HARPS radial-velocity variations"}])
      expect(subject.dates).to eq([{"date"=>"2016-01-20", "dateType"=>"Available"}, {"date"=>"2016", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2016")
      expect(subject.publisher).to eq({"name"=>"University of St Andrews"})
      expect(subject.agency).to eq("datacite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-4")
    end

    it "empty sizes and dates attributes" do
      input = fixture_path + 'datacite-empty-sizes.xml'
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.types["schemaOrg"]).to eq("Dataset")
      expect(subject.types["resourceType"]).to be_nil
      expect(subject.types["resourceTypeGeneral"]).to eq("Dataset")
      expect(subject.creators.length).to eq(1)
      expect(subject.creators.first).to eq("affiliation"=>[], "name"=>"EvK2 CNR Committee", "nameIdentifiers"=>[])
      expect(subject.titles).to eq([{"title"=>"SHARE (Stations at High Altitude for Research on the Environment) Network"}, {"title"=>"Urdukas (Baltoro Glacier, Baltistan - Pakistan)", "titleType"=>"Subtitle"}])
      expect(subject.dates).to eq([{"date"=>"2011", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2011")
      expect(subject.sizes).to eq([])
      expect(subject.subjects).to eq([{"subject"=>"Environmental research"}])
      expect(subject.publisher).to eq({"name"=>"EvK2 CNR Committee"})
      expect(subject.agency).to eq("datacite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-2.2")
    end

    it "multiple licenses" do
      input = "https://doi.org/10.5281/ZENODO.48440"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.5281/zenodo.48440")
      expect(subject.identifiers).to eq([{"identifier"=>"https://zenodo.org/record/48440", "identifierType"=>"URL"}])
      expect(subject.types["schemaOrg"]).to eq("SoftwareSourceCode")
      expect(subject.types["resourceTypeGeneral"]).to eq("Software")
      expect(subject.types["ris"]).to eq("COMP")
      expect(subject.types["citeproc"]).to eq("article")
      expect(subject.creators).to eq([{"nameType"=>"Personal", "name"=>"Garza, Kristian", "givenName"=>"Kristian", "familyName"=>"Garza", "nameIdentifiers" => [], "affiliation" => []}])
      expect(subject.titles).to eq([{"title"=>"Analysis Tools For Crossover Experiment Of Ui Using Choice Architecture"}])
      expect(subject.descriptions.first["description"]).to start_with(" \n\nThis tools are used to analyse the data produced by the Crosssover Experiment I designed to test Choice Architecture techniques as UI interventions in a SEEk4Science data catalogue. It contains:\n\n- Data structures for the experimental data.<br>\n- Visualisation functions<br>\n- Analysis functions\n\n## Installation\n\n- R<br>\n- python<br>\n- ipython 4\n\nClone and use.\n\n## Usage\n\n<br>\n```python<br>\nsource('parallel_plot.r')<br>\nwith(z, parallelset(trt,response, freq=count, alpha=0.2))<br>\n```\n\n<br>\n## Contributing\n\n1. Fork it!<br>\n2. Create your feature branch: `git checkout -b my-new-feature`<br>\n3. Commit your changes: `git commit -am 'Add some feature'`<br>\n4. Push to the branch: `git push origin my-new-feature`<br>\n5. Submit a pull request :D\n\n<br>\n## License\n\nThis work supports my PhD Thesis at University of Manchester.")
      expect(subject.rights_list).to eq([{"rights"=>
        "Creative Commons Attribution Non Commercial Share Alike 4.0 International",
        "rightsIdentifier"=>"cc-by-nc-sa-4.0",
        "rightsIdentifierScheme"=>"SPDX",
        "rightsUri"=>"https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode",
        "schemeUri"=>"https://spdx.org/licenses/"},
       {"rights"=>"Open Access", "rightsUri"=>"info:eu-repo/semantics/openAccess"}])
      expect(subject.dates).to eq([{"date"=>"2016-03-27", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2016")
      expect(subject.related_identifiers.length).to eq(1)
      expect(subject.related_identifiers.last).to eq("relatedIdentifier"=>"https://github.com/kjgarza/frame_experiment_analysis/tree/v1.0", "relatedIdentifierType"=>"URL", "relationType"=>"IsSupplementTo")
      expect(subject.subjects).to eq([{"subject"=>"choice architecture"},
        {"subject"=>"crossover experiment"},
        {"subject"=>"hci"}])
      expect(subject.publisher).to eq({"name"=>"Zenodo"})
      expect(subject.agency).to eq("datacite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-4")
    end

    it "is identical to" do
      input = "10.6084/M9.FIGSHARE.4234751.V1"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifiers).to be_empty
      expect(subject.types["schemaOrg"]).to eq("Dataset")
      expect(subject.types["resourceType"]).to eq("Dataset")
      expect(subject.types["resourceTypeGeneral"]).to eq("Dataset")
      expect(subject.creators.count).to eq(11)
      expect(subject.creators.first).to eq("nameType"=>"Personal", "nameIdentifiers" => [{"nameIdentifier"=>"https://orcid.org/0000-0002-2410-9671", "nameIdentifierScheme"=>"ORCID", "schemeUri"=>"https://orcid.org"}], "name"=>"Junge, Alexander", "givenName"=>"Alexander", "familyName"=>"Junge", "affiliation" => [])
      expect(subject.titles).to eq([{"title"=>"RAIN v1"}])
      expect(subject.descriptions.first["description"]).to start_with("<b>RAIN: RNA–protein Association and Interaction Networks")
      expect(subject.rights_list).to eq([{"rights"=>"Creative Commons Attribution 4.0 International",
        "rightsIdentifier"=>"cc-by-4.0",
        "rightsIdentifierScheme"=>"SPDX",
        "rightsUri"=>"https://creativecommons.org/licenses/by/4.0/legalcode",
        "schemeUri"=>"https://spdx.org/licenses/"}])
      expect(subject.dates).to eq([{"date"=>"2016-11-16", "dateType"=>"Created"}, {"date"=>"2016-11-16", "dateType"=>"Updated"}, {"date"=>"2016", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2016")
      expect(subject.related_identifiers.length).to eq(1)
      expect(subject.related_identifiers.last).to eq("relatedIdentifier"=>"10.6084/m9.figshare.4234751", "relatedIdentifierType"=>"DOI", "relationType"=>"IsIdenticalTo")
      expect(subject.publisher).to eq({"name"=>"figshare"})
      expect(subject.subjects).to eq([
        {"schemeUri"=>
          "http://www.abs.gov.au/ausstats/abs@.nsf/0/6BB427AB9696C225CA2574180004463E",
          "subject"=>"60102 Bioinformatics",
          "subjectScheme"=>"FOR"},
            {"schemeUri"=>"http://www.oecd.org/science/inno/38235147.pdf",
             "subject"=>"FOS: Computer and information sciences",
             "subjectScheme"=>"Fields of Science and Technology (FOS)"},
            {"subject"=>"Computational Biology"},
         {"schemeUri"=>
          "http://www.abs.gov.au/ausstats/abs@.nsf/0/6BB427AB9696C225CA2574180004463E",
          "subject"=>"60114 Systems Biology",
          "subjectScheme"=>"FOR"},
         {"schemeUri"=>"http://www.oecd.org/science/inno/38235147.pdf",
          "subject"=>"FOS: Biological sciences",
          "subjectScheme"=>"Fields of Science and Technology (FOS)"}])
      expect(subject.agency).to eq("datacite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-4")
    end

    it "subject scheme FOR" do
      input = "10.6084/m9.figshare.1449060"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.6084/m9.figshare.1449060")
      expect(subject.types["schemaOrg"]).to eq("Dataset")
      expect(subject.types["resourceType"]).to eq("Dataset")
      expect(subject.types["resourceTypeGeneral"]).to eq("Dataset")
      expect(subject.creators.count).to eq(4)
      expect(subject.creators.first).to eq("nameType"=>"Personal", "familyName" => "Dworkin",
        "givenName" => "Ian",
        "name" => "Dworkin, Ian",
        "nameIdentifiers" => [{"nameIdentifier"=>"https://orcid.org/0000-0002-2874-287X", "nameIdentifierScheme"=>"ORCID", "schemeUri"=>"https://orcid.org"}], "affiliation" => [])
      expect(subject.titles).to eq([{"title"=>"Drosophila melanogaster wing images from low and high altitude populations in Ethiopia and Zambia."}])
      expect(subject.descriptions.first["description"]).to start_with("These are raw wing images from <i>Drosophila melanogaster</i>")
      expect(subject.rights_list).to eq([{"rights"=>"Creative Commons Attribution 4.0 International",
        "rightsIdentifier"=>"cc-by-4.0",
        "rightsIdentifierScheme"=>"SPDX",
        "rightsUri"=>"https://creativecommons.org/licenses/by/4.0/legalcode",
        "schemeUri"=>"https://spdx.org/licenses/"}])
      expect(subject.dates).to eq([{"date"=>"2015-06-14", "dateType"=>"Created"}, {"date"=>"2020-06-02", "dateType"=>"Updated"}, {"date"=>"2020", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2020")
      expect(subject.publisher).to eq({"name"=>"figshare"})
      expect(subject.subjects).to eq([{"subject"=>"Evolutionary Biology"},
        {"subject"=>"FOS: Biological sciences", "subjectScheme"=>"Fields of Science and Technology (FOS)", "schemeUri"=>"http://www.oecd.org/science/inno/38235147.pdf"},
        {"subject"=>"60412 Quantitative Genetics (incl. Disease and Trait Mapping Genetics)", "subjectScheme"=>"FOR", "schemeUri"=>"http://www.abs.gov.au/ausstats/abs@.nsf/0/6BB427AB9696C225CA2574180004463E"}])
      expect(subject.agency).to eq("datacite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-4")
    end

    it "more subject scheme FOR" do
      input = "10.4225/03/5a6931f57c654"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.subjects).to eq([{"subject"=>"90301 Biomaterials", "subjectScheme"=>"FOR", "schemeUri"=>"http://www.abs.gov.au/ausstats/abs@.nsf/0/6BB427AB9696C225CA2574180004463E"},
        {"subject"=>"FOS: Medical engineering", "subjectScheme"=>"Fields of Science and Technology (FOS)", "schemeUri"=>"http://www.oecd.org/science/inno/38235147.pdf"}])
    end

    it "even more subject scheme FOR" do
      input = "10.4225/03/5a31ec65634ef"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.subjects).to eq([{"subject"=>"130103 Higher Education", "subjectScheme"=>"FOR", "schemeUri"=>"http://www.abs.gov.au/ausstats/abs@.nsf/0/6BB427AB9696C225CA2574180004463E"},
        {"subject"=>"FOS: Educational sciences", "subjectScheme"=>"Fields of Science and Technology (FOS)", "schemeUri"=>"http://www.oecd.org/science/inno/38235147.pdf"},
        {"subject"=>"130313 Teacher Education and Professional Development of Educators", "subjectScheme"=>"FOR", "schemeUri"=>"http://www.abs.gov.au/ausstats/abs@.nsf/0/6BB427AB9696C225CA2574180004463E"},
        {"subject"=>"80799 Library and Information Studies not elsewhere classified", "subjectScheme"=>"FOR", "schemeUri"=>"http://www.abs.gov.au/ausstats/abs@.nsf/0/6BB427AB9696C225CA2574180004463E"},
        {"subject"=>"FOS: Media and communications", "subjectScheme"=>"Fields of Science and Technology (FOS)", "schemeUri"=>"http://www.oecd.org/science/inno/38235147.pdf"}, {"subject"=>"Library and Information Studies"}])
    end

    it "cc-by 3.0 us" do
      input = "10.6084/m9.figshare.1286826.v1"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.rights_list).to eq([{"rights"=>"Creative Commons Attribution 4.0 International",
        "rightsIdentifier"=>"cc-by-4.0",
        "rightsIdentifierScheme"=>"SPDX",
        "rightsUri"=>"https://creativecommons.org/licenses/by/4.0/legalcode",
        "schemeUri"=>"https://spdx.org/licenses/"}])
    end

    it "funding schema version 3" do
      input = "https://doi.org/10.5281/ZENODO.1239"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.5281/zenodo.1239")
      expect(subject.identifiers).to eq([{"identifier"=>"https://zenodo.org/record/1239", "identifierType"=>"URL"}])
      expect(subject.types["schemaOrg"]).to eq("Dataset")
      expect(subject.types["resourceTypeGeneral"]).to eq("Dataset")
      expect(subject.creators.length).to eq(4)
      expect(subject.creators.first).to eq("name"=>"Jahn, Najko", "givenName"=>"Najko", "familyName"=>"Jahn", "affiliation"=>[{"name"=>"Bielefeld University Library"}])
      expect(subject.titles).to eq([{"title"=>"Publication Fp7 Funding Acknowledgment - Plos Openaire"}])
      expect(subject.descriptions.first["description"]).to start_with("The dataset contains a sample of metadata describing papers")
      expect(subject.dates).to eq([{"date"=>"2013-04-03", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2013")
      expect(subject.publisher).to eq({"name"=>"Zenodo"})
      expect(subject.funding_references).to eq([{"awardNumber"=>"246686",
        "awardTitle"=>"Open Access Infrastructure for Research in Europe",
        "awardUri"=>"info:eu-repo/grantAgreement/EC/FP7/246686/",
        "funderIdentifier"=>"https://doi.org/10.13039/501100000780",
        "funderIdentifierType"=>"Crossref Funder ID",
        "funderName"=>"European Commission"}])
      expect(subject.subjects).to eq([{"subject"=>"Article-Level Metrics"},
        {"subject"=>"Data mining"},
        {"subject"=>"Statistical Computing Language R"},
        {"subject"=>"funded research publications"}])
      expect(subject.agency).to eq("datacite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-4")
    end

    it "from attributes" do
      subject = Bolognese::Metadata.new(input: nil,
        from: "datacite",
        doi: "10.5281/zenodo.1239",
        creators: [{"nameType"=>"Personal", "name"=>"Jahn, Najko", "givenName"=>"Najko", "familyName"=>"Jahn"}],
        titles: [{ "title" => "Publication Fp7 Funding Acknowledgment - Plos Openaire" }],
        descriptions: [{ "description" => "The dataset contains a sample of metadata describing papers" }],
        publisher: "Zenodo",
        publication_year: "2013",
        dates: [{"date"=>"2013-04-03", "dateType"=>"Issued"}],
        funding_references: [{"awardNumber"=>"246686",
          "awardTitle"=>"Open Access Infrastructure for Research in Europe",
          "awardUri"=>"info:eu-repo/grantAgreement/EC/FP7/246686/",
          "funderIdentifier"=>"https://doi.org/10.13039/501100000780",
          "funderIdentifierType"=>"Crossref Funder ID",
          "funderName"=>"European Commission"}],
        types: { "resourceTypeGeneral" => "Dataset", "schemaOrg" => "Dataset" },
        "identifiers" => [{ "identifierType"=>"Repository ID", "identifier"=>"123" }])

      expect(subject.valid?).to be true
      expect(subject.doi).to eq("10.5281/zenodo.1239")
      expect(subject.id).to eq("https://doi.org/10.5281/zenodo.1239")
      expect(subject.types["schemaOrg"]).to eq("Dataset")
      expect(subject.types["resourceTypeGeneral"]).to eq("Dataset")
      expect(subject.creators).to eq([{"familyName"=>"Jahn", "givenName"=>"Najko", "name"=>"Jahn, Najko", "nameType"=>"Personal"}])
      expect(subject.titles).to eq([{"title"=>"Publication Fp7 Funding Acknowledgment - Plos Openaire"}])
      expect(subject.descriptions.first["description"]).to start_with("The dataset contains a sample of metadata describing papers")
      expect(subject.dates).to eq([{"date"=>"2013-04-03", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2013")
      expect(subject.publisher).to eq({"name"=>"Zenodo"})
      expect(subject.funding_references).to eq([{"awardNumber"=>"246686",
        "awardTitle"=>"Open Access Infrastructure for Research in Europe",
        "awardUri"=>"info:eu-repo/grantAgreement/EC/FP7/246686/",
        "funderIdentifier"=>"https://doi.org/10.13039/501100000780",
        "funderIdentifierType"=>"Crossref Funder ID",
        "funderName"=>"European Commission"}])
      expect(subject.identifiers).to eq([{"identifier"=>"123", "identifierType"=>"Repository ID"}])
      expect(subject.agency).to eq("datacite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-4")
      expect(subject.state).to eq("findable")
    end

    it "missing resource_type_general" do
      input = fixture_path + 'vivli.xml'
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.types["schemaOrg"]).to eq("CreativeWork")
      expect(subject.types["resourceTypeGeneral"]).to be_nil
      expect(subject.valid?).to be false
      expect(subject.errors).to eq("2:0: ERROR: Element '{http://datacite.org/schema/kernel-4}resource': Missing child element(s). Expected is one of ( {http://datacite.org/schema/kernel-4}resourceType, {http://datacite.org/schema/kernel-4}subjects, {http://datacite.org/schema/kernel-4}contributors, {http://datacite.org/schema/kernel-4}language, {http://datacite.org/schema/kernel-4}alternateIdentifiers, {http://datacite.org/schema/kernel-4}relatedIdentifiers, {http://datacite.org/schema/kernel-4}sizes, {http://datacite.org/schema/kernel-4}formats, {http://datacite.org/schema/kernel-4}rightsList, {http://datacite.org/schema/kernel-4}descriptions ).")
    end

    it "multiple languages" do
      input = fixture_path + 'datacite-multiple-language.xml'
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.types["schemaOrg"]).to eq("Collection")
      expect(subject.language).to eq("de")
      expect(subject.publisher).to eq({"name"=>"Universitätsbibliothek Tübingen"})
      expect(subject.publication_year).to eq("2015")
      expect(subject.valid?).to be false
      expect(subject.errors).to eq("13:0: ERROR: Element '{http://datacite.org/schema/kernel-2.2}publisher': This element is not expected. Expected is ( {http://datacite.org/schema/kernel-2.2}publicationYear ).")
    end

    it "funder identifier with different http scheme" do
      input = fixture_path + 'datacite-funderIdentifier.xml'
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.funding_references.first).to eq({
        "funderIdentifier"=>"http://www.isni.org/isni/0000000119587073",
        "funderIdentifierType"=>"ISNI",
        "schemeUri"=>"http://www.isni.org/isni/",
        "funderName"=>"National Science Foundation (NSF)"})
      expect(subject.funding_references[2]).to eq({
        "funderIdentifier"=>"https://doi.org/10.13039/501100000780",
        "funderIdentifierType"=>"Crossref Funder ID",
        "schemeUri"=>"https://doi.org/",
        "funderName"=>"European Commission"})
      expect(subject.funding_references[1]).to eq({
          "funderIdentifier"=>"1234",
          "funderIdentifierType"=>"Other",
          "funderName"=>"Acme Inc"})
    end

    it "funder identifier with normalized identifiers and non-normalized identifiers" do
      input = fixture_path + 'datacite-funderIdentifier.xml'
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.funding_references[3]).to eq({
        "funderIdentifier"=>"0000 0001 2298 6657",
        "funderIdentifierType"=>"ISNI",
        "schemeUri"=>"http://www.isni.org/isni/",
        "funderName"=>"University of Washington"})
      expect(subject.funding_references[4]).to eq({
        "funderIdentifier"=>"127467345",
        "funderIdentifierType"=>"Other",
        "schemeUri"=>"http://viaf.org/viaf/",
        "funderName"=>"National Library of Ireland."})
      expect(subject.funding_references[5]).to eq({
          "funderIdentifier"=>"https://ror.org/04wxnsj81",
          "funderIdentifierType"=>"ROR",
          "schemeUri"=>"https://ror.org",
          "funderName"=>"DataCite"})
      expect(subject.funding_references[6]).to eq({
          "funderIdentifier"=>"https://ror.org/038wwg650",
          "funderIdentifierType"=>"ROR",
          "schemeUri"=>"https://ror.org",
          "funderName"=>"Department of Agriculture"})
      expect(subject.funding_references[7]).to eq({
        "funderIdentifier"=>"https://doi.org/10.13039/501100005695",
        "funderIdentifierType"=>"Crossref Funder ID",
        "funderName"=>"Tottori University"})
    end

    it "geo_location empty" do
      input = fixture_path + 'datacite-geolocation-empty.xml'
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.types["schemaOrg"]).to eq("Dataset")
      expect(subject.geo_locations).to eq([{"geoLocationPoint"=>{"pointLatitude"=>"-11.64583333", "pointLongitude"=>"-68.2975"}}])
    end

    it "geo_location in separate input" do
      input = fixture_path + 'datacite-geolocation-empty.xml'
      geo_locations = [{"geoLocationPoint"=>{"pointLatitude"=>"49.0850736", "pointLongitude"=>"-123.3300992"}}]
      subject = Bolognese::Metadata.new(input: input, geo_locations: geo_locations)
      expect(subject.valid?).to be true
      expect(subject.types["schemaOrg"]).to eq("Dataset")
      expect(subject.geo_locations).to eq(geo_locations)

      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.dig("geoLocations")).to eq("geoLocation"=>{"geoLocationPoint"=>{"pointLatitude"=>"49.0850736", "pointLongitude"=>"-123.3300992"}})
    end

    it "xml:lang attribute" do
      input = fixture_path + 'datacite-xml-lang.xml'
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.types["schemaOrg"]).to eq("Collection")
      expect(subject.titles).to eq([{"lang"=>"en", "title"=>"DOI Test 2 title content"}, {"lang"=>"en", "title"=>"AAPP"}])
      expect(subject.descriptions).to eq([{"description"=>"This is the DOI TEST 2 product where this is the description field content.", "descriptionType"=>"Methods", "lang"=>"en"}])
      expect(subject.geo_locations).to eq([{"geoLocationBox"=>{"eastBoundLongitude"=>"70.0", "northBoundLatitude"=>"70.0", "southBoundLatitude"=>"-70.0", "westBoundLongitude"=>"-70.0"}}, {"geoLocationPlace"=>"Regional"}])
    end

    it "wrong attributes" do
      input = fixture_path + 'nist.xml'
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.id).to eq("https://doi.org/10.5072/m32163")
      expect(subject.titles).to eq([{"title"=>"Peter Auto Dataset 501"}])
      expect(subject.descriptions).to eq([{"description"=>"This is to overturn Einstein's Relativity Theory.", "descriptionType"=>"Abstract"}])
      expect(subject.valid?).to be false
      expect(subject.errors.length).to eq(4)
      expect(subject.errors.last).to eq("32:0: ERROR: Element '{http://datacite.org/schema/kernel-3}alternateIdentifier': The attribute 'alternateIdentifierType' is required but missing.")
    end

    it "schema 4.0" do
      input = fixture_path + 'schema_4.0.xml'
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.6071/z7wc73")
      expect(subject.types["schemaOrg"]).to eq("Dataset")
      expect(subject.types["resourceType"]).to eq("dataset")
      expect(subject.types["resourceTypeGeneral"]).to eq("Dataset")
      expect(subject.creators.length).to eq(6)
      expect(subject.creators.first).to eq("familyName"=>"Bales", "givenName"=>"Roger", "name"=>"Bales, Roger", "nameType"=>"Personal", "affiliation"=>[{"name"=>"UC Merced"}], "nameIdentifiers" => [])
      expect(subject.subjects).to eq([{"subject"=>"Earth sciences"},
        {"subject"=>"soil moisture"},
        {"subject"=>"soil temperature"},
        {"subject"=>"snow depth"},
        {"subject"=>"air temperature"},
        {"subject"=>"water balance"},
        {"subject"=>"Nevada, Sierra (mountain range)"}])
    end

    it "series_information" do
      input = fixture_path + 'datacite-seriesinformation.xml'
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(subject.identifiers).to eq([{"identifier"=>"MS-49-3632-5083", "identifierType"=>"Local accession number"}])
      expect(subject.creators.length).to eq(1)
      expect(subject.creators.first).to eq("familyName"=>"Fenner", "givenName"=>"Martin", "nameIdentifiers" => [{"nameIdentifier"=>"https://orcid.org/0000-0003-1419-2405", "nameIdentifierScheme"=>"ORCID", "schemeUri"=>"https://orcid.org"}], "name"=>"Fenner, Martin")
      expect(subject.titles).to eq([{"title"=>"Eating your own Dog Food"}])
      expect(subject.publisher).to eq({"name"=>"DataCite"})
      expect(subject.publication_year).to eq("2016")
      expect(subject.related_identifiers).to eq([{"relatedIdentifier"=>"10.5438/0012",
        "relatedIdentifierType"=>"DOI",
        "relationType"=>"References"},
       {"relatedIdentifier"=>"10.5438/55e5-t5c0",
        "relatedIdentifierType"=>"DOI",
        "relationType"=>"References"},
       {"relatedIdentifier"=>"10.5438/0000-00ss",
        "relatedIdentifierType"=>"DOI",
        "relationType"=>"IsPartOf"}])
      expect(subject.descriptions).to eq([{"description"=>"DataCite Blog, 2(9), 3-4",
        "descriptionType"=>"SeriesInformation",
        "lang"=>"en"},
       {"description"=>
        "Eating your own dog food is a slang term to \n describe that an organization should itself use the products and services it provides. \n For DataCite this means that we should use DOIs with appropriate metadata and strategies for long-term preservation for...\n • Unicode Bullet Point: This is an example of a bullet point.\\u2605\n ■ Unicode Black Square: This is an example of a black square.",
        "descriptionType"=>"Abstract"}])
      expect(subject.container).to eq("firstPage"=>"3", "identifier"=>"10.5438/0000-00SS", "identifierType"=>"DOI", "issue"=>"9", "lastPage"=>"4", "title"=>"DataCite Blog", "type"=>"Series", "volume"=>"2")
    end

    it "geo_location" do
      input = fixture_path + 'datacite-example-geolocation.xml'
      doi = "10.5072/geoPointExample"
      subject = Bolognese::Metadata.new(input: input, doi: doi)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.5072/geopointexample")
      expect(subject.doi).to eq("10.5072/geopointexample")
      expect(subject.creators.length).to eq(3)
      expect(subject.creators.first).to eq("familyName"=>"Schumann", "givenName"=>"Kai", "name"=>"Schumann, Kai", "nameType"=>"Personal", "nameIdentifiers" => [], "affiliation" => [])
      expect(subject.titles).to eq([{"title"=>"Gridded results of swath bathymetric mapping of Disko Bay, Western Greenland, 2007-2008"}])
      expect(subject.publisher).to eq({"name"=>"PANGAEA - Data Publisher for Earth & Environmental Science"})
      expect(subject.publication_year).to eq("2011")
      expect(subject.related_identifiers).to eq([{"relatedIdentifier"=>"10.5072/timeseries", "relatedIdentifierType"=>"DOI", "relationType"=>"Continues"}])
      expect(subject.geo_locations).to eq([{"geoLocationPlace"=>"Disko Bay", "geoLocationPoint"=>{"pointLatitude"=>"69.000000", "pointLongitude"=>"-52.000000"}}])
      expect(subject.subjects).to eq([{"subject"=>"551 Geology, hydrology, meteorology", "subjectScheme"=>"DDC"}])
    end

    it "geo_location_box" do
      input = fixture_path + 'datacite-example-geolocation-2.xml'
      doi = "10.6071/Z7WC73"
      subject = Bolognese::Metadata.new(input: input, doi: doi)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.6071/z7wc73")
      expect(subject.doi).to eq("10.6071/z7wc73")
      expect(subject.creators.length).to eq(6)
      expect(subject.creators.first).to eq("familyName"=>"Bales", "givenName"=>"Roger", "name"=>"Bales, Roger", "nameType"=>"Personal", "affiliation" => [{"name"=>"UC Merced"}, {"name"=>"NSF"}], "nameIdentifiers" => [])
      expect(subject.titles).to eq([{"title"=>"Southern Sierra Critical Zone Observatory (SSCZO), Providence Creek meteorological data, soil moisture and temperature, snow depth and air temperature"}])
      expect(subject.publisher).to eq({"name"=>"UC Merced"})
      expect(subject.dates).to eq([{"date"=>"2014-10-17", "dateType"=>"Updated"}, {"date"=>"2016-03-14T17:02:02Z", "dateType"=>"Available"}, {"date"=>"2013", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2013")
      expect(subject.subjects).to eq([{"subject"=>"Earth sciences"},
        {"subject"=>"soil moisture"},
        {"subject"=>"soil temperature"},
        {"subject"=>"snow depth"},
        {"subject"=>"air temperature"},
        {"subject"=>"water balance"},
        {"subject"=>"Nevada, Sierra (mountain range)"}])
      expect(subject.geo_locations).to eq([{"geoLocationBox"=>
        {"eastBoundLongitude"=>"-119.182",
         "northBoundLatitude"=>"37.075",
         "southBoundLatitude"=>"37.046",
         "westBoundLongitude"=>"-119.211"},
         "geoLocationPlace"=>"Providence Creek (Lower, Upper and P301)",
         "geoLocationPoint"=>  {"pointLatitude"=>"37.047756", "pointLongitude"=>"-119.221094"}}])
    end

    it "author only full name" do
      input = "https://doi.org/10.14457/KMITL.RES.2006.17"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.14457/kmitl.res.2006.17")
      expect(subject.types["schemaOrg"]).to eq("Dataset")
      expect(subject.creators.length).to eq(1)
      expect(subject.creators.first).to eq("name" => "กัญจนา แซ่เตียว", "nameIdentifiers" => [], "affiliation" => [])
    end

    it "multiple author names in one creatorsName" do
      input = "https://doi.org/10.7910/DVN/EQTQYO"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.7910/dvn/eqtqyo")
      expect(subject.types["schemaOrg"]).to eq("Dataset")
      expect(subject.creators).to eq([{"name" => "Enos, Ryan (Harvard University); Fowler, Anthony (University Of Chicago); Vavreck, Lynn (UCLA)", "nameIdentifiers" => [], "affiliation" => []}])
    end

    it "author with scheme" do
      input = "https://doi.org/10.18429/JACOW-IPAC2016-TUPMY003"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.18429/jacow-ipac2016-tupmy003")
      expect(subject.types["schemaOrg"]).to eq("ScholarlyArticle")
      expect(subject.creators.length).to eq(12)
      expect(subject.creators.first).to eq("nameType"=>"Personal", "nameIdentifiers" => [{"nameIdentifier"=>"JACoW-00077389", "nameIdentifierScheme"=>"JACoW-ID", "schemeUri"=>"http://jacow.org/"}], "name"=>"Otani, Masashi", "givenName"=>"Masashi", "familyName"=>"Otani", "affiliation" => [{"name"=>"KEK, Tsukuba, Japan"}])
    end

    it "author with wrong orcid scheme" do
      input = "https://doi.org/10.2314/COSCV1"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.2314/coscv1")
      expect(subject.types["schemaOrg"]).to eq("ScholarlyArticle")
      expect(subject.creators.length).to eq(14)
      expect(subject.creators.first).to include("nameType"=>"Personal", "nameIdentifiers" => [{"nameIdentifier"=>"https://orcid.org/0000-0003-0232-7085", "nameIdentifierScheme"=>"ORCID", "schemeUri"=>"https://orcid.org"}], "name"=>"Heller, Lambert", "givenName"=>"Lambert", "familyName"=>"Heller")
    end

    it "keywords with attributes" do
      input = "https://doi.org/10.21233/n34n5q"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.21233/n34n5q")
      expect(subject.subjects).to eq([{"schemeUri"=>"http://id.loc.gov/authorities/subjects", "subject"=>"Paleoecology", "subjectScheme"=>"Library of Congress"}])
    end

    it "Funding" do
      input = "https://doi.org/10.15125/BATH-00114"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.15125/bath-00114")
      expect(subject.identifiers).to eq([{"identifier"=>"http://researchdata.bath.ac.uk/114/", "identifierType"=>"URL"}])
      expect(subject.types["schemaOrg"]).to eq("Dataset")
      expect(subject.types["resourceType"]).to eq("Dataset")
      expect(subject.types["resourceTypeGeneral"]).to eq("Dataset")
      expect(subject.creators.length).to eq(2)
      expect(subject.creators.first).to eq("nameIdentifiers" => [{"nameIdentifier"=>"https://orcid.org/0000-0001-8740-8284", "nameIdentifierScheme"=>"ORCID", "schemeUri"=>"https://orcid.org"}], "name"=>"Bimbo, Nuno", "givenName"=>"Nuno", "familyName"=>"Bimbo")
      expect(subject.titles).to eq([{"title"=>"Dataset for \"Direct Evidence for Solid-Like Hydrogen in a Nanoporous Carbon Hydrogen Storage Material at Supercritical Temperatures\""}])
      expect(subject.descriptions.first["description"]).to start_with("Dataset for Direct Evidence for Solid-Like Hydrogen")
      expect(subject.publication_year).to eq("2015")
      expect(subject.publisher).to eq({"name"=>"University of Bath"})
      expect(subject.funding_references.length).to eq(5)
      expect(subject.funding_references.first).to eq("awardNumber" => "EP/J016454/1",
        "awardTitle" => "SUPERGEN Hub Funding",
        "funderIdentifier" => "https://doi.org/10.13039/501100000266",
        "funderIdentifierType" => "Crossref Funder ID",
        "funderName" => "Engineering and Physical Sciences Research Council (EPSRC)")
      expect(subject.subjects).to eq([{"schemeUri"=>
        "http://www.rcuk.ac.uk/research/efficiency/researchadmin/harmonisation/",
        "subject"=>"Energy Storage",
        "subjectScheme"=>"RCUK Research Classifications"},
       {"schemeUri"=>
        "http://www.rcuk.ac.uk/research/efficiency/researchadmin/harmonisation/",
        "subject"=>"Materials Characterisation",
        "subjectScheme"=>"RCUK Research Classifications"}])
      expect(subject.agency).to eq("datacite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-4")
    end

    it "Funding schema version 4" do
      input = "https://doi.org/10.5438/6423"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.5438/6423")
      expect(subject.types["schemaOrg"]).to eq("Collection")
      expect(subject.types["resourceType"]).to eq("Project")
      expect(subject.types["resourceTypeGeneral"]).to eq("Collection")
      expect(subject.types["ris"]).to eq("GEN")
      expect(subject.types["citeproc"]).to eq("article")
      expect(subject.creators.length).to eq(24)
      expect(subject.creators.first).to eq("nameIdentifiers" => [{"nameIdentifier"=>"https://orcid.org/0000-0001-5331-6592", "nameIdentifierScheme"=>"ORCID", "schemeUri"=>"https://orcid.org"}], "name"=>"Farquhar, Adam", "givenName"=>"Adam", "familyName"=>"Farquhar", "affiliation" => [{"name"=>"British Library"}])
      expect(subject.titles).to eq([{"title"=>"Technical and Human Infrastructure for Open Research (THOR)"}])
      expect(subject.descriptions.first["description"]).to start_with("Five years ago, a global infrastructure")
      expect(subject.publication_year).to eq("2015")
      expect(subject.publisher).to eq({"name"=>"DataCite"})
      expect(subject.funding_references).to eq([{"awardNumber"=>"654039",
        "awardTitle"=>"THOR – Technical and Human Infrastructure for Open Research",
        "awardUri"=>"http://cordis.europa.eu/project/rcn/194927_en.html",
        "funderIdentifier"=>"https://doi.org/10.13039/501100000780",
        "funderIdentifierType"=>"Crossref Funder ID",
        "funderName"=>"European Commission"}])
      expect(subject.agency).to eq("datacite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-4")
    end

    it "Funding empty awardTitle" do
      input = "https://doi.org/10.26102/2310-6018/2019.24.1.006"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.26102/2310-6018/2019.24.1.006")
      expect(subject.types["schemaOrg"]).to eq("ScholarlyArticle")
      expect(subject.types["resourceType"]).to eq("Journal Article")
      expect(subject.types["resourceTypeGeneral"]).to eq("Text")
      expect(subject.creators.length).to eq(2)
      expect(subject.creators.first).to eq("affiliation"=>[{"name"=>"Тверская государственная сельскохозяйственная академия"}], "familyName"=>"Ганичева", "givenName"=>"А.В.", "name"=>"Ганичева, А.В.", "nameType"=>"Personal", "nameIdentifiers" => [])
      expect(subject.titles).to eq([{"title"=>"МОДЕЛЬ СИСТЕМНОЙ ДИНАМИКИ ПРОЦЕССА ОБУЧЕНИЯ"}, {"title"=>"MODEL OF SYSTEM DYNAMICS OF PROCESS OF TRAINING", "titleType"=>"TranslatedTitle"}])
      expect(subject.descriptions.first["description"]).to start_with("Актуальность данной работы обусловлена важностью учета в учебном процессе личностных качеств обучаем")
      expect(subject.publication_year).to eq("2019")
      expect(subject.publisher).to eq({"name"=>"МОДЕЛИРОВАНИЕ, ОПТИМИЗАЦИЯ И ИНФОРМАЦИОННЫЕ ТЕХНОЛОГИИ"})
      expect(subject.funding_references.length).to eq(1)
      expect(subject.funding_references.first).to eq("awardNumber"=>"проект № 170100728", "funderName"=>"РФФИ")
      expect(subject.agency).to eq("datacite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-4")
    end

    it "BlogPosting from string" do
      input = fixture_path + "datacite.xml"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.types["schemaOrg"]).to eq("ScholarlyArticle")
      expect(subject.types["resourceType"]).to eq("BlogPosting")
      expect(subject.types["resourceTypeGeneral"]).to eq("Text")
      expect(subject.types["ris"]).to eq("RPRT")
      expect(subject.types["citeproc"]).to eq("article-journal")
      expect(subject.creators).to eq([{"nameIdentifiers"=> [{"nameIdentifier"=>"https://orcid.org/0000-0003-1419-2405", "nameIdentifierScheme"=>"ORCID", "schemeUri"=>"https://orcid.org"}], "name"=>"Fenner, Martin", "givenName"=>"Martin", "familyName"=>"Fenner"}])
      expect(subject.titles).to eq([{"title"=>"Eating your own Dog Food"}])
      expect(subject.id).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(subject.identifiers).to eq([{"identifier"=>"MS-49-3632-5083", "identifierType"=>"Local accession number"}])
      expect(subject.dates).to eq([{"date"=>"2016-12-20", "dateType"=>"Created"}, {"date"=>"2016-12-20", "dateType"=>"Issued"}, {"date"=>"2016-12-20", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2016")
      expect(subject.related_identifiers.length).to eq(3)
      expect(subject.related_identifiers.last).to eq("relatedIdentifier"=>"10.5438/0000-00ss", "relatedIdentifierType"=>"DOI", "relationType"=>"IsPartOf")
      expect(subject.agency).to eq("datacite")
    end

    it "Schema 4.1 from string" do
      input = fixture_path + "datacite-example-complicated-v4.1.xml"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.types["schemaOrg"]).to eq("Book")
      expect(subject.types["resourceType"]).to eq("Monograph")
      expect(subject.types["resourceTypeGeneral"]).to eq("Text")
      expect(subject.types["ris"]).to eq("BOOK")
      expect(subject.types["citeproc"]).to eq("book")
      expect(subject.creators).to eq([{"nameType"=>"Personal", "name"=>"Smith, John", "givenName"=>"John", "familyName"=>"Smith", "nameIdentifiers" => [], "affiliation" => []}, {"name"=>"つまらないものですが","nameIdentifiers"=>
        [{"nameIdentifier"=>"0000000134596520",
          "nameIdentifierScheme"=>"ISNI",
          "schemeUri"=>"http://isni.org/isni/"}],
          "affiliation" => []}])
      expect(subject.titles).to eq([{"title"=>"Właściwości rzutowań podprzestrzeniowych"}, {"title"=>"Translation of Polish titles", "titleType"=>"TranslatedTitle"}])
      expect(subject.identifiers).to eq([{"identifier"=>"937-0-4523-12357-6", "identifierType"=>"ISBN"}])
      expect(subject.dates).to eq([{"date"=>"2012-12-13", "dateInformation"=>"Correction", "dateType"=>"Other"}, {"date"=>"2010", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2010")
      expect(subject.related_identifiers.length).to eq(1)
      expect(subject.related_identifiers.last).to eq("relatedIdentifier"=>"10.5272/oldertestpub", "relatedIdentifierType"=>"DOI", "relationType"=>"IsPartOf", "resourceTypeGeneral"=>"Text")
      expect(subject.rights_list).to eq([{"lang"=>"eng",
        "rights"=>"Creative Commons Attribution No Derivatives 2.0 Generic",
        "rightsIdentifier"=>"cc-by-nd-2.0",
        "rightsIdentifierScheme"=>"SPDX",
        "rightsUri"=>"https://creativecommons.org/licenses/by-nd/2.0/legalcode",
        "schemeUri"=>"https://spdx.org/licenses/"}])
      expect(subject.publisher).to eq({"name"=>"Springer"})
      expect(subject.agency).to eq("datacite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-4")
    end

    it "Schema 4.0 from string" do
      input = fixture_path + "datacite-example-complicated-v4.0.xml"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.types["schemaOrg"]).to eq("Book")
      expect(subject.types["resourceType"]).to eq("Monograph")
      expect(subject.types["resourceTypeGeneral"]).to eq("Text")
      expect(subject.types["ris"]).to eq("BOOK")
      expect(subject.types["citeproc"]).to eq("book")
      expect(subject.creators).to eq([{"nameType"=>"Personal", "name"=>"Smith, John", "givenName"=>"John", "familyName"=>"Smith", "nameIdentifiers" => [], "affiliation" => []}, {"name"=>"つまらないものですが","nameIdentifiers"=>
        [{"nameIdentifier"=>"0000000134596520",
          "nameIdentifierScheme"=>"ISNI",
          "schemeUri"=>"http://isni.org/isni/"}],
          "affiliation" => []}])
      expect(subject.titles).to eq([{"title"=>"Właściwości rzutowań podprzestrzeniowych"}, {"title"=>"Translation of Polish titles", "titleType"=>"TranslatedTitle"}])
      expect(subject.id).to eq("https://doi.org/10.5072/testpub")
      expect(subject.identifiers).to eq([{"identifier"=>"937-0-4523-12357-6", "identifierType"=>"ISBN"}])
      expect(subject.publication_year).to eq("2010")
      expect(subject.related_identifiers.length).to eq(1)
      expect(subject.related_identifiers.last).to eq("relatedIdentifier"=>"10.5272/oldertestpub", "relatedIdentifierType"=>"DOI", "relationType"=>"IsPartOf")
      expect(subject.rights_list).to eq([{"rights"=>"Creative Commons Attribution No Derivatives 2.0 Generic",
        "rightsIdentifier"=>"cc-by-nd-2.0",
        "rightsIdentifierScheme"=>"SPDX",
        "rightsUri"=>"https://creativecommons.org/licenses/by-nd/2.0/legalcode",
        "schemeUri"=>"https://spdx.org/licenses/"}])
      expect(subject.publisher).to eq({"name"=>"Springer"})
      expect(subject.agency).to eq("datacite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-4.0")
    end

    it "Schema 3 from string" do
      input = fixture_path + "datacite_schema_3.xml"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.types["schemaOrg"]).to eq("Dataset")
      expect(subject.types["resourceType"]).to eq("DataPackage")
      expect(subject.types["resourceTypeGeneral"]).to eq("Dataset")
      expect(subject.types["ris"]).to eq("DATA")
      expect(subject.types["citeproc"]).to eq("dataset")
      expect(subject.creators.length).to eq(8)
      expect(subject.creators.last).to eq("familyName"=>"Renaud", "givenName"=>"François", "name"=>"Renaud, François", "nameType"=>"Personal", "nameIdentifiers" => [], "affiliation" => [])
      expect(subject.titles).to eq([{"title"=>"Data from: A new malaria agent in African hominids."}])
      expect(subject.id).to eq("https://doi.org/10.5061/dryad.8515")
      expect(subject.identifiers).to eq([{"identifier"=>
        "Ollomo B, Durand P, Prugnolle F, Douzery EJP, Arnathau C, Nkoghe D, Leroy E, Renaud F (2009) A new malaria agent in African hominids. PLoS Pathogens 5(5): e1000446.",
        "identifierType"=>"citation"}])
      expect(subject.publication_year).to eq("2011")
      expect(subject.related_identifiers.length).to eq(4)
      expect(subject.related_identifiers.last).to eq("relatedIdentifier"=>"19478877", "relatedIdentifierType"=>"PMID", "relationType"=>"IsReferencedBy")
      expect(subject.rights_list).to eq([{"rights"=>"Creative Commons Zero v1.0 Universal",
        "rightsIdentifier"=>"cc0-1.0",
        "rightsIdentifierScheme"=>"SPDX",
        "rightsUri"=>"https://creativecommons.org/publicdomain/zero/1.0/legalcode",
        "schemeUri"=>"https://spdx.org/licenses/"}])
      expect(subject.publisher).to eq({"name"=>"Dryad Digital Repository"})
      expect(subject.agency).to eq("datacite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-3")
    end

    it "Schema 3.0 from string" do
      input = fixture_path + "datacite-example-complicated-v3.0.xml"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.types["schemaOrg"]).to eq("Book")
      expect(subject.types["resourceType"]).to eq("Monograph")
      expect(subject.types["resourceTypeGeneral"]).to eq("Text")
      expect(subject.types["ris"]).to eq("BOOK")
      expect(subject.types["citeproc"]).to eq("book")
      expect(subject.creators).to eq([{"nameType"=>"Personal", "name"=>"Smith, John", "givenName"=>"John", "familyName"=>"Smith", "nameIdentifiers" => [], "affiliation" => []}, {"name"=>"つまらないものですが","nameIdentifiers"=>
        [{"nameIdentifier"=>"0000000134596520",
          "nameIdentifierScheme"=>"ISNI",
          "schemeUri"=>"http://isni.org/isni/"}],
          "affiliation" => []}])
      expect(subject.titles).to eq([{"title"=>"Właściwości rzutowań podprzestrzeniowych"}, {"title"=>"Translation of Polish titles", "titleType"=>"TranslatedTitle"}])
      expect(subject.id).to eq("https://doi.org/10.5072/testpub")
      expect(subject.identifiers).to eq([{"identifier"=>"937-0-4523-12357-6", "identifierType"=>"ISBN"}])
      expect(subject.publication_year).to eq("2010")
      expect(subject.related_identifiers.length).to eq(1)
      expect(subject.related_identifiers.last).to eq("relatedIdentifier"=>"10.5272/oldertestpub", "relatedIdentifierType"=>"DOI", "relationType"=>"IsPartOf")
      expect(subject.rights_list).to eq([{"rights"=>"Creative Commons Attribution No Derivatives 2.0 Generic",
        "rightsIdentifier"=>"cc-by-nd-2.0",
        "rightsIdentifierScheme"=>"SPDX",
        "rightsUri"=>"https://creativecommons.org/licenses/by-nd/2.0/legalcode",
        "schemeUri"=>"https://spdx.org/licenses/"}])
      expect(subject.publisher).to eq({"name"=>"Springer"})
      expect(subject.agency).to eq("datacite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-3.0")
    end

    it "Schema 2.2 from string" do
      input = fixture_path + "datacite-metadata-sample-complicated-v2.2.xml"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.types["schemaOrg"]).to eq("Book")
      expect(subject.types["resourceType"]).to eq("Monograph")
      expect(subject.types["resourceTypeGeneral"]).to eq("Text")
      expect(subject.types["ris"]).to eq("BOOK")
      expect(subject.types["citeproc"]).to eq("book")
      expect(subject.creators).to eq([{"nameType"=>"Personal", "name"=>"Smith, John", "givenName"=>"John", "familyName"=>"Smith", "nameIdentifiers" => [], "affiliation" => []}, {"name"=>"つまらないものですが", "nameIdentifiers"=>
        [{"nameIdentifier"=>"abc123",
          "nameIdentifierScheme"=>"ISNI"}],
          "affiliation" => []}])
      expect(subject.titles).to eq([{"title"=>"Właściwości rzutowań podprzestrzeniowych"}, {"title"=>"Translation of Polish titles", "titleType"=>"TranslatedTitle"}])
      expect(subject.identifiers).to eq([{"identifier"=>"937-0-4523-12357-6", "identifierType"=>"ISBN"}])
      expect(subject.dates).to eq([{"date"=>"2009-04-29", "dateType"=>"StartDate"}, {"date"=>"2010-01-05", "dateType"=>"EndDate"}, {"date"=>"2010", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2010")
      expect(subject.related_identifiers.length).to eq(1)
      expect(subject.related_identifiers.last).to eq("relatedIdentifier"=>"10.5272/oldertestpub", "relatedIdentifierType"=>"DOI", "relationType"=>"IsPartOf")
      expect(subject.publisher).to eq({"name"=>"Springer"})
      expect(subject.agency).to eq("datacite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-2.2")
    end

    it "Schema 4.1 from string with doi in options" do
      input = fixture_path + "datacite-example-complicated-v4.1.xml"
      subject = Bolognese::Metadata.new(input: input, doi: "10.5072/testpub2", content_url: "https://example.org/report.pdf")
      expect(subject.valid?).to be true
      expect(subject.types["schemaOrg"]).to eq("Book")
      expect(subject.types["resourceType"]).to eq("Monograph")
      expect(subject.types["resourceTypeGeneral"]).to eq("Text")
      expect(subject.creators).to eq([{"nameType"=>"Personal", "name"=>"Smith, John", "givenName"=>"John", "familyName"=>"Smith", "nameIdentifiers" => [], "affiliation" => []}, {"name"=>"つまらないものですが","nameIdentifiers"=>
        [{"nameIdentifier"=>"0000000134596520",
          "nameIdentifierScheme"=>"ISNI",
          "schemeUri"=>"http://isni.org/isni/"}],
          "affiliation" => []}])
      expect(subject.titles).to eq([{"title"=>"Właściwości rzutowań podprzestrzeniowych"}, {"title"=>"Translation of Polish titles", "titleType"=>"TranslatedTitle"}])
      expect(subject.id).to eq("https://doi.org/10.5072/testpub2")
      expect(subject.identifiers).to eq([{"identifier"=>"937-0-4523-12357-6", "identifierType"=>"ISBN"}])
      expect(subject.dates).to eq([{"date"=>"2012-12-13", "dateInformation"=>"Correction", "dateType"=>"Other"}, {"date"=>"2010", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2010")
      expect(subject.sizes).to eq(["256 pages"])
      expect(subject.formats).to eq(["pdf"])
      expect(subject.content_url).to eq("https://example.org/report.pdf")
      expect(subject.publication_year).to eq("2010")
      expect(subject.related_identifiers.length).to eq(1)
      expect(subject.related_identifiers.last).to eq("relatedIdentifier"=>"10.5272/oldertestpub", "relatedIdentifierType"=>"DOI", "relationType"=>"IsPartOf", "resourceTypeGeneral"=>"Text")
      expect(subject.rights_list).to eq([{"lang"=>"eng",
        "rights"=>"Creative Commons Attribution No Derivatives 2.0 Generic",
        "rightsIdentifier"=>"cc-by-nd-2.0",
        "rightsIdentifierScheme"=>"SPDX",
        "rightsUri"=>"https://creativecommons.org/licenses/by-nd/2.0/legalcode",
        "schemeUri"=>"https://spdx.org/licenses/"}])
      expect(subject.publisher).to eq({"name"=>"Springer"})
      expect(subject.agency).to eq("datacite")
    end

    it "namespaced xml from string" do
      input = fixture_path + "ns0.xml"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.4231/d38g8fk8b")
      expect(subject.types["schemaOrg"]).to eq("SoftwareSourceCode")
      expect(subject.types["resourceType"]).to eq("Simulation Tool")
      expect(subject.types["resourceTypeGeneral"]).to eq("Software")
      expect(subject.creators.length).to eq(5)
      expect(subject.creators.first).to eq("nameType"=>"Personal", "name"=>"PatiÃ±O, Carlos", "givenName"=>"Carlos", "familyName"=>"PatiÃ±O", "nameIdentifiers" => [], "affiliation" => [])
      expect(subject.titles).to eq([{"title"=>"LAMMPS Data-File Generator"}])
      expect(subject.dates).to eq([{"date"=>"2018-07-18", "dateType"=>"Valid"}, {"date"=>"2018-07-18", "dateType"=>"Accepted"}, {"date"=>"2018", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2018")
      expect(subject.publisher).to eq({"name"=>"nanoHUB"})
      expect(subject.agency).to eq("datacite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-2.2")
    end

    it "Schema.org type" do
      input = "https://doi.org/10.25318/3410014001-fra"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.25318/3410014001-fra")
      expect(subject.types["schemaOrg"]).to eq("Dataset")
      expect(subject.types["resourceType"]).to be_nil
      expect(subject.types["resourceTypeGeneral"]).to eq("Dataset")
      expect(subject.types["ris"]).to eq("DATA")
      expect(subject.types["bibtex"]).to eq("misc")
      expect(subject.creators.length).to eq(1)
      expect(subject.creators.first).to eq("affiliation" => [{"affiliationIdentifier"=>"https://ror.org/04zt3wx35", "affiliationIdentifierScheme"=>"ROR", "name"=>"Canada Mortgage and Housing Corporation", "schemeUri"=>"https://ror.org"}],
        "name" => "Statistique Canada",
         "nameIdentifiers" => [],
        "nameType" => "Organizational")
    end

    it "doi with + sign" do
      input = "10.5067/terra+aqua/ceres/cldtyphist_l3.004"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.5067/terra+aqua/ceres/cldtyphist_l3.004")
      expect(subject.types["schemaOrg"]).to eq("Dataset")
      expect(subject.types["resourceTypeGeneral"]).to eq("Dataset")
      expect(subject.creators).to eq([{"familyName"=>"Wong", "givenName"=>"Takmeng", "name"=>"Wong, Takmeng"}])
      expect(subject.titles).to eq([{"title"=>"CERES Level 3 Cloud Type Historgram Terra+Aqua HDF file - Edition4"}])
      expect(subject.publication_year).to eq("2016")
      expect(subject.publisher).to eq({"name"=>"NASA Langley Atmospheric Science Data Center DAAC"})
      expect(subject.agency).to eq("datacite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-4")
    end

    it "subject scheme" do
      input = "https://doi.org/10.4232/1.2745"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.4232/1.2745")
      expect(subject.identifiers).to eq([{"identifier"=>"ZA2745", "identifierType"=>"ZA-No."},
        {"identifier"=>"Internationale Umfrageprogramme", "identifierType"=>"FDZ"}])
      expect(subject.types["schemaOrg"]).to eq("Dataset")
      expect(subject.types["resourceTypeGeneral"]).to eq("Dataset")
      expect(subject.creators).to eq([{"nameType"=>"Organizational", "name"=>"Europäische Kommission", "nameIdentifiers" => [], "affiliation" => []}])
      expect(subject.contributors.length).to eq(18)
      expect(subject.contributors.first).to eq("affiliation"=>[{"name"=>"Europäische Kommission, Brüssel"}], "contributorType"=>"Researcher", "familyName"=>"Reif", "givenName"=>"Karlheinz", "name"=>"Reif, Karlheinz", "nameType"=>"Personal", "nameIdentifiers" => [])
      expect(subject.titles).to eq([{"lang"=>"de", "title"=>"Flash Eurobarometer 54 (Madrid Summit)"}, {"lang"=>"en", "title"=>"Flash Eurobarometer 54 (Madrid Summit)"}, {"titleType"=>"Subtitle","lang"=>"de", "title"=>"The Common European Currency"}, {"titleType"=>"Subtitle", "lang"=>"en", "title"=>"The Common European Currency"}])
      expect(subject.subjects).to eq([{"lang"=>"en",
        "subject"=>"KAT12 International Institutions, Relations, Conditions",
        "subjectScheme"=>"ZA"},
       {"lang"=>"de",
        "subject"=>"Internationale Politik und Institutionen",
        "subjectScheme"=>"CESSDA Topic Classification"},
       {"lang"=>"de",
        "subject"=>"Regierung, politische Systeme, Parteien und Verbände",
        "subjectScheme"=>"CESSDA Topic Classification"},
       {"lang"=>"de",
        "subject"=>"Wirtschaftssysteme und wirtschaftliche Entwicklung",
        "subjectScheme"=>"CESSDA Topic Classification"},
       {"lang"=>"en",
        "subject"=>"International politics and organisation",
        "subjectScheme"=>"CESSDA Topic Classification"},
       {"lang"=>"en",
        "subject"=>"Government, political systems and organisation",
        "subjectScheme"=>"CESSDA Topic Classification"},
       {"lang"=>"en",
        "subject"=>"Economic systems and development",
        "subjectScheme"=>"CESSDA Topic Classification"}])
      expect(subject.dates).to eq([{"date"=>"1995-12", "dateType"=>"Collected"}, {"date"=>"1996", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("1996")
      expect(subject.publisher).to eq({"name"=>"GESIS Data Archive"})
      expect(subject.agency).to eq("datacite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-4")
    end

    it "series-information" do
      input = "https://doi.org/10.4229/23RDEUPVSEC2008-5CO.8.3"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.4229/23rdeupvsec2008-5co.8.3")
      expect(subject.identifiers).to eq([{"identifier"=>"3-936338-24-8", "identifierType"=>"ISBN"}])
      expect(subject.types["schemaOrg"]).to eq("ScholarlyArticle")
      expect(subject.types["resourceType"]).to eq("Article")
      expect(subject.types["resourceTypeGeneral"]).to eq("Text")
      expect(subject.creators.length).to eq(3)
      expect(subject.creators.first).to eq("nameType"=>"Personal", "name"=>"Llamas, P.", "givenName"=>"P.", "familyName"=>"Llamas", "nameIdentifiers" => [], "affiliation" => [])
      expect(subject.titles).to eq([{"title"=>"Rural Electrification With Hybrid Power Systems Based on Renewables - Technical System Configurations From the Point of View of the European Industry"}])
      expect(subject.dates).to eq([{"date"=>"2008-11-01", "dateType"=>"Valid"}, {"date"=>"2008", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2008")
      expect(subject.container).to eq("firstPage"=>"Spain; 3353", "lastPage"=>"3356", "title"=>"23rd European Photovoltaic Solar Energy Conference and Exhibition", "type"=>"Series", "volume"=>"1-5 September 2008")
      expect(subject.descriptions[1]["description"]).to start_with("Aim of this paper is the presentation")
      expect(subject.subjects).to eq([{"subject"=>"PV Systems"}, {"subject"=>"Off-grid Applications"}])
      expect(subject.publisher).to eq({"name"=>"WIP-Munich"})
      expect(subject.agency).to eq("datacite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-2.2")
    end

    it "content url" do
      input = "10.23725/8na3-9s47"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.doi).to eq("10.23725/8na3-9s47")
      expect(subject.id).to eq("https://doi.org/10.23725/8na3-9s47")
      expect(subject.identifiers).to eq([{"identifier"=>"ark:/99999/fk41CrU4eszeLUDe", "identifierType"=>"minid"},
        {"identifier"=>"dg.4503/c3d66dc9-58da-411c-83c4-dd656aa3c4b7",
         "identifierType"=>"dataguid"},
        {"identifier"=>"3b33f6b9338fccab0901b7d317577ea3", "identifierType"=>"md5"}])
      expect(subject.content_url).to include("s3://cgp-commons-public/topmed_open_access/197bc047-e917-55ed-852d-d563cdbc50e4/NWD165827.recab.cram", "gs://topmed-irc-share/public/NWD165827.recab.cram")
    end

    it "empty subject" do
      input = "https://doi.org/10.18169/PAPDEOTTX00502"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.18169/papdeottx00502")
      expect(subject.identifiers).to eq([{"identifier"=>"http://www.priorartregister.com/resolve.php?disclosure=OTTX00502", "identifierType"=>"URL"}])
      expect(subject.types["schemaOrg"]).to eq("Dataset")
      expect(subject.types["resourceType"]).to eq("Disclosure")
      expect(subject.types["resourceTypeGeneral"]).to eq("Dataset")
      expect(subject.creators).to eq([{"name"=>"Anonymous", "nameIdentifiers" => [], "affiliation" => []}])
      expect(subject.titles).to eq([{"title"=>"Messung der Bildunschaerfe in H.264-codierten Bildern und Videosequenzen"}])
      expect(subject.dates).to eq([{"date"=>"2017", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2017")
      expect(subject.publisher).to eq({"name"=>"Siemens AG"})
      expect(subject.agency).to eq("datacite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-3")
    end

    it "leading and trailing whitespace" do
      input = "https://doi.org/10.21944/temis-OZONE-MSR2"
      subject = Bolognese::Metadata.new(input: input)

      expect(subject.valid?).to be true
      #expect(subject.errors.length).to eq(2)
      #expect(subject.errors.last).to eq("33:0: ERROR: Element '{http://datacite.org/schema/kernel-4}date': '1970-04-01 / (:tba)' is not a valid value of the atomic type '{http://datacite.org/schema/kernel-4}edtf'.")
      expect(subject.id).to eq("https://doi.org/10.21944/temis-ozone-msr2")
      expect(subject.types["schemaOrg"]).to eq("Dataset")
      expect(subject.types["resourceType"]).to eq("Satellite data")
      expect(subject.types["resourceTypeGeneral"]).to eq("Dataset")
      expect(subject.creators).to eq([{"nameType"=>"Personal",
                                       "nameIdentifiers"=>
                                         [{"nameIdentifier"=>"https://orcid.org/0000-0002-0077-5338",
                                           "nameIdentifierScheme"=>"ORCID", "schemeUri"=>"https://orcid.org"}],
                                     "name"=>"Van Der A, Ronald",
                                     "givenName"=>"Ronald",
                                     "familyName"=>"Van Der A",
                                     "affiliation"=>[{"name"=>"Royal Netherlands Meteorological Institute (KNMI)"}]},
                                    {"nameType"=>"Personal",
                                     "name"=>"Allaart, Marc",
                                     "givenName"=>"Marc",
                                     "familyName"=>"Allaart",
                                     "affiliation"=>[{"name"=>"Royal Netherlands Meteorological Institute (KNMI)"}],
                                     "nameIdentifiers" => []},
                                    {"nameType"=>"Personal",
                                     "name"=>"Eskes, Henk",
                                     "givenName"=>"Henk",
                                     "familyName"=>"Eskes",
                                     "nameIdentifiers"=> [{"nameIdentifier"=>"https://orcid.org/0000-0002-8743-4455", "nameIdentifierScheme"=>"ORCID", "schemeUri"=>"https://orcid.org"}],
                                     "affiliation"=>[{"name"=>"Royal Netherlands Meteorological Institute (KNMI)"}]}])
      expect(subject.titles).to eq([{"title"=>"Multi-Sensor Reanalysis (MSR) of total ozone, version 2"}])
      expect(subject.version_info).to eq("2")
      expect(subject.dates).to eq([{"date"=>"2014-04-25", "dateType"=>"Available"}, {"date"=>"2015", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2015")
      expect(subject.publisher).to eq({"name"=>"Royal Netherlands Meteorological Institute (KNMI)"})
      expect(subject.agency).to eq("datacite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-4")
    end

    it "DOI not found" do
      input = "https://doi.org/10.4124/05F6C379-DD68-4CDB-880D-33D3E9576D52/1"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be false
      expect(subject.id).to eq("https://doi.org/10.4124/05f6c379-dd68-4cdb-880d-33d3e9576d52/1")
      expect(subject.doi).to eq("10.4124/05f6c379-dd68-4cdb-880d-33d3e9576d52/1")
      expect(subject.agency).to eq("datacite")
      expect(subject.state).to eq("not_found")
    end

    it "DOI in staging system" do
      input = "https://handle.stage.datacite.org/10.22002/d1.694"
      subject = Bolognese::Metadata.new(input: input, sandbox: true)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://handle.stage.datacite.org/10.22002/d1.694")
      expect(subject.types["schemaOrg"]).to eq("Dataset")
      expect(subject.types["resourceTypeGeneral"]).to eq("Dataset")
      expect(subject.creators).to eq([{"affiliation"=>[{"name"=>"Caltech"}], "name"=>"Tester", "nameIdentifiers" => []}])
      expect(subject.titles).to eq([{"title"=>"Test license"}])
      expect(subject.dates).to eq([{"date"=>"2018-01-12", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2018")
      expect(subject.publisher).to eq({"name"=>"CaltechDATA"})
      expect(subject.agency).to eq("datacite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-4")
      expect(subject.state).to eq("findable")
    end

    it "DOI in staging system schema 3" do
      input = "10.21956/wellcomeopenres.25947.r17364"
      subject = Bolognese::Metadata.new(input: input, doi: input, sandbox: true)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://handle.stage.datacite.org/10.21956/wellcomeopenres.25947.r17364")
      expect(subject.types["schemaOrg"]).to eq("ScholarlyArticle")
      expect(subject.types["resourceTypeGeneral"]).to eq("Text")
      expect(subject.creators).to eq([{"name"=>"Fran2 Levy", "nameIdentifiers" => [], "affiliation" => []}])
      expect(subject.titles).to eq([{"title"=>"Referee report. For: FL Regression Wellcome [version 1; referees: retracted]"}])
      expect(subject.dates).to eq([{"date"=>"2018", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2018")
      expect(subject.publisher).to eq({"name"=>"F1000 Research Limited"})
      expect(subject.agency).to eq("datacite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-3")
      expect(subject.state).to eq("findable")
    end

    it "Referee report in staging system" do
      input = "10.21956/gatesopenres.530.r190"
      subject = Bolognese::Metadata.new(input: input, sandbox: true)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://handle.stage.datacite.org/10.21956/gatesopenres.530.r190")
      expect(subject.types["schemaOrg"]).to eq("ScholarlyArticle")
      expect(subject.types["resourceTypeGeneral"]).to eq("Text")
      expect(subject.types["ris"]).to eq("RPRT")
      expect(subject.types["citeproc"]).to eq("article-journal")
      expect(subject.creators.length).to eq(5)
      expect(subject.creators.first).to eq("nameType"=>"Personal", "name"=>"Patel, Lina", "givenName"=>"Lina", "familyName"=>"Patel", "nameIdentifiers" => [], "affiliation" => [])
      expect(subject.titles).to eq([{"title"=>"Referee report. For: Gates - add article keywords to the metatags [version 2; referees: 1 approved]"}])
      expect(subject.publication_year).to eq("2018")
      expect(subject.publisher).to eq({"name"=>"Gates Open Research"})
      expect(subject.agency).to eq("datacite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-3")
    end

    it "multiple rights" do
      input = fixture_path + "datacite-multiple-rights.xml"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.rights_list).to eq([{"rights"=>"info:eu-repo/semantics/openAccess"}, {"rights"=>"Open Access", "rightsUri"=>"info:eu-repo/semantics/openAccess"}])
    end

    it ":tba" do
      input = fixture_path + "datacite-example-complicated-tba.xml"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.titles).to eq([{"title"=>":unav"}])
      expect(subject.formats).to eq([":null"])
      expect(subject.dates).to eq([{"date"=>":tba", "dateInformation"=>"Correction", "dateType"=>"Other"}, {"date"=>"2010", "dateType"=>"Issued"}])
    end

    it "ancient-dates" do
      input = fixture_path + "datacite-example-ancientdates-v4.3.xml"
      subject = Bolognese::Metadata.new(input: input)
      #expect(subject.valid?).to be true
      expect(subject.dates).to eq([{"date"=>"-0024/-0022", "dateInformation"=>"from 25 BC to 23 BC", "dateType"=>"Created"}, {"date"=>"2010", "dateType"=>"Issued"}])
    end

    # TODO properly handle escaped text
    it "escaped text" do
      input = fixture_path + "datacite-example-escaped-text.xml"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.titles).to eq([{"title"=>"Some initial text"}])
    end

    it "missing creators" do
      input = fixture_path + "datacite_missing_creator.xml"
      subject = Bolognese::Metadata.new(input: input, regenerate: true)
      expect(subject.creators).to be_blank
      expect(subject.valid?).to be false
      expect(subject.errors).to eq("4:0: ERROR: Element '{http://datacite.org/schema/kernel-4}creators': Missing child element(s). Expected is ( {http://datacite.org/schema/kernel-4}creator ).")
    end

    it "malformed creators" do
      input = fixture_path + "datacite_malformed_creator.xml"
      subject = Bolognese::Metadata.new(input: input, regenerate: false)
      expect(subject.creators).to be_blank
      expect(subject.valid?).to be false
      expect(subject.errors).to eq("16:0: ERROR: Element '{http://datacite.org/schema/kernel-4}creatorName': This element is not expected. Expected is ( {http://datacite.org/schema/kernel-4}affiliation ).")
    end

    it "empty funding references" do
      input = fixture_path + "funding_reference.xml"
      subject = Bolognese::Metadata.new(input: input, regenerate: false)
      expect(subject.valid?).to be false
      expect(subject.funding_references).to eq([{"funderName"=>"Agency for Science, Technology and Research (Singapore)"}])
      expect(subject.errors.first).to eq("31:0: ERROR: Element '{http://datacite.org/schema/kernel-4}fundingReference': Missing child element(s). Expected is one of ( {http://datacite.org/schema/kernel-4}funderName, {http://datacite.org/schema/kernel-4}funderIdentifier, {http://datacite.org/schema/kernel-4}awardNumber, {http://datacite.org/schema/kernel-4}awardTitle ).")
    end

    it "space in sizes" do
      input = fixture_path + "datacite-space-in-sizes.xml"
      subject = Bolognese::Metadata.new(input: input, regenerate: false)
      expect(subject.valid?).to be true
      expect(subject.sizes).to be_empty
      expect(subject.related_identifiers).to eq([{"relatedIdentifier"=>"10.1016/s0040-1951(03)00197-5",
        "relatedIdentifierType"=>"DOI",
        "relationType"=>"IsCitedBy"}])
    end

    it "formats with xs" do
      input = fixture_path + "datacite-formats-with-xs.xml"
      subject = Bolognese::Metadata.new(input: input, regenerate: false)
      expect(subject.valid?).to be true
      expect(subject.formats).to eq(["PDF"])
    end

    it "dissertation" do
      input = "10.3204/desy-2014-01645"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.3204/desy-2014-01645")
      expect(subject.types["resourceTypeGeneral"]).to eq("Text")
      expect(subject.types["resourceType"]).to eq("Dissertation")
      expect(subject.types["schemaOrg"]).to eq("Thesis")
      expect(subject.types["bibtex"]).to eq("phdthesis")
      expect(subject.types["citeproc"]).to eq("thesis")
      expect(subject.creators).to eq([{"nameType"=>"Personal", "name"=>"Conrad, Heiko", "givenName"=>"Heiko", "familyName"=>"Conrad", "nameIdentifiers" => [], "affiliation" => []}])
      expect(subject.titles).to eq([{"title"=>"Dynamics of colloids in molecular glass forming liquids studied via X-ray photon correlation spectroscopy"}])
      expect(subject.dates).to eq([{"date"=>"2014", "dateType"=>"Issued"},
        {"date"=>"2014", "dateType"=>"Copyrighted"},
        {"date"=>"2009-10-01/2014-01-23", "dateType"=>"Created"}])
      expect(subject.publication_year).to eq("2014")
      expect(subject.publisher).to eq({"name"=>"Deutsches Elektronen-Synchrotron, DESY, Hamburg"})
      expect(subject.agency).to eq("datacite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-3")
    end

    it "funding references" do
      input = "10.26102/2310-6018/2019.24.1.006"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.26102/2310-6018/2019.24.1.006")
      expect(subject.types["resourceTypeGeneral"]).to eq("Text")
      expect(subject.types["resourceType"]).to eq("Journal Article")
      expect(subject.types["schemaOrg"]).to eq("ScholarlyArticle")
      expect(subject.types["bibtex"]).to eq("article")
      expect(subject.types["citeproc"]).to eq("article-journal")
      expect(subject.creators.length).to eq(2)
      expect(subject.creators.first).to eq("affiliation" => [{"name"=>"Тверская государственная сельскохозяйственная академия"}],
        "familyName" => "Ганичева",
        "givenName" => "А.В.",
        "name" => "Ганичева, А.В.",
        "nameIdentifiers" => [],
        "nameType" => "Personal")
      expect(subject.titles.last).to eq("title"=>"MODEL OF SYSTEM DYNAMICS OF PROCESS OF TRAINING", "titleType"=>"TranslatedTitle")
      expect(subject.dates).to eq([{"date"=>"2019-02-09", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2019")
      expect(subject.publisher).to eq({"name"=>"МОДЕЛИРОВАНИЕ, ОПТИМИЗАЦИЯ И ИНФОРМАЦИОННЫЕ ТЕХНОЛОГИИ"})
      expect(subject.funding_references.count).to eq(1)
      expect(subject.funding_references.first).to eq("awardNumber"=>"проект № 170100728", "funderName"=>"РФФИ")
      expect(subject.agency).to eq("datacite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-4")
    end

    it "DOI in with related id system" do
      input = "https://doi.org/10.4121/uuid:3926db30-f712-4394-aebc-75976070e91f"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.4121/uuid:3926db30-f712-4394-aebc-75976070e91f")
      expect(subject.types["schemaOrg"]).to eq("Dataset")
      expect(subject.types["resourceTypeGeneral"]).to eq("Dataset")
      expect(subject.titles).to eq([{"title"=>"BPI Challenge 2012"}])
      expect(subject.dates).to eq([{"date"=>"2012-04-23", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2012")
      expect(subject.state).to eq("findable")
    end
  end

  context "change datacite metadata" do
    it "change title" do
      subject.titles = [{"title"=> "A new malaria agent in African hominids." }]
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.5061/dryad.8515")
      expect(subject.doi).to eq("10.5061/dryad.8515")
      expect(subject.url).to eq("http://datadryad.org/stash/dataset/doi:10.5061/dryad.8515")
      expect(subject.types["schemaOrg"]).to eq("Dataset")
      expect(subject.titles).to eq([{"title"=> "A new malaria agent in African hominids." }])
    end

    it "change state" do
      subject.state = "registered"
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.5061/dryad.8515")
      expect(subject.doi).to eq("10.5061/dryad.8515")
      expect(subject.url).to eq("http://datadryad.org/stash/dataset/doi:10.5061/dryad.8515")
      expect(subject.types["schemaOrg"]).to eq("Dataset")
      expect(subject.titles).to eq([{"title"=>"Data from: A new malaria agent in African hominids."}])
      expect(subject.state).to eq("registered")
    end
  end

  context "change datacite metadata on input" do
    it "change doi" do
      input = fixture_path + 'datacite.xml'
      doi = "10.5061/dryad.8515"
      subject = Bolognese::Metadata.new(input: input, doi: doi)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.5061/dryad.8515")
      expect(subject.identifiers).to eq([{"identifier"=>"MS-49-3632-5083", "identifierType"=>"Local accession number"}])
      expect(subject.doi).to eq("10.5061/dryad.8515")
      expect(subject.creators).to eq([{"nameIdentifiers"=> [{"nameIdentifier"=>"https://orcid.org/0000-0003-1419-2405", "nameIdentifierScheme"=>"ORCID", "schemeUri"=>"https://orcid.org"}], "name"=>"Fenner, Martin", "givenName"=>"Martin", "familyName"=>"Fenner"}])
      expect(subject.titles).to eq([{"title"=>"Eating your own Dog Food"}])
      expect(subject.publisher).to eq({"name"=>"DataCite"})
      expect(subject.publication_year).to eq("2016")
    end
  end

  it "GTEx dataset" do
    input = fixture_path + 'gtex.xml'
    url = "https://ors.datacite.org/doi:/10.25491/9hx8-ke93"
    content_url = "https://storage.googleapis.com/gtex_analysis_v7/single_tissue_eqtl_data/GTEx_Analysis_v7_eQTL_expression_matrices.tar.gz"
    subject = Bolognese::Metadata.new(input: input, from: 'datacite', url: url, content_url: content_url)

    expect(subject.valid?).to be true
    expect(subject.id).to eq("https://doi.org/10.25491/9hx8-ke93")
    expect(subject.url).to eq("https://ors.datacite.org/doi:/10.25491/9hx8-ke93")
    expect(subject.content_url).to eq("https://storage.googleapis.com/gtex_analysis_v7/single_tissue_eqtl_data/GTEx_Analysis_v7_eQTL_expression_matrices.tar.gz")
    expect(subject.types["schemaOrg"]).to eq("Dataset")
    expect(subject.types["resourceType"]).to eq("DroNc-seq data")
    expect(subject.creators).to eq([{"name"=>"The GTEx Consortium", "nameType"=>"Organizational", "nameIdentifiers" => [], "affiliation" => []}])
    expect(subject.titles).to eq([{"title"=>"DroNc-seq data"}])
    expect(subject.subjects).to eq([{"subject"=>"gtex"}, {"subject"=>"annotation"}, {"subject"=>"phenotype"}, {"subject"=>"gene regulation"}, {"subject"=>"transcriptomics"}])
    expect(subject.dates).to eq([{"date"=>"2017", "dateType"=>"Issued"}])
    expect(subject.publication_year).to eq("2017")
    expect(subject.related_identifiers.length).to eq(4)
    expect(subject.related_identifiers.last).to eq("relatedIdentifier"=>"https://www.ebi.ac.uk/miriam/main/datatypes/MIR:00000663", "relatedIdentifierType"=>"URL", "relationType"=>"IsPartOf")
    expect(subject.formats).to eq(["application/tar"])
    expect(subject.sizes).to eq(["15.7M"])
    expect(subject.container).to eq("identifier"=>"https://www.ebi.ac.uk/miriam/main/datatypes/MIR:00000663", "identifierType"=>"URL", "title"=>"GTEx", "type"=>"DataRepository")
    expect(subject.publisher).to eq({"name"=>"GTEx"})
    expect(subject.funding_references.count).to eq(7)
    expect(subject.funding_references.first).to eq("funderIdentifier"=>"https://doi.org/10.13039/100000052", "funderIdentifierType"=>"Crossref Funder ID", "funderName"=>"Common Fund of the Office of the Director of the NIH")
  end

  it "geo_location_polygon" do
    input = fixture_path + 'datacite-example-polygon-v4.1.xml'
    subject = Bolognese::Metadata.new(input: input)
    expect(subject.id).to eq("https://doi.org/10.5072/example-polygon")
    expect(subject.types["schemaOrg"]).to eq("Dataset")
    expect(subject.types["resourceType"]).to eq("Dataset")
    expect(subject.types["resourceTypeGeneral"]).to eq("Dataset")
    expect(subject.types["ris"]).to eq("DATA")
    expect(subject.types["citeproc"]).to eq("dataset")
    expect(subject.creators.first).to eq("familyName"=>"Den Heijer", "givenName"=>"C", "name"=>"Den Heijer, C", "nameType"=>"Personal", "nameIdentifiers" => [], "affiliation" => [])
    expect(subject.titles).to eq([{"lang"=>"en", "title"=>"Meteo measurements at the Sand Motor"}])
    expect(subject.publication_year).to eq("2017")
    expect(subject.publisher).to eq({"name"=>"4TU.Centre for Research Data"})
    expect(subject.agency).to eq("datacite")
    expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-4")
    expect(subject.geo_locations.first["geoLocationPlace"]).to eq("Zandmotor, sand suppletion area on the Dutch coast.")
    expect(subject.geo_locations.first["geoLocationPolygon"].first).to eq("polygonPoint"=>{"pointLatitude"=>"52.03913926329928", "pointLongitude"=>"4.1738852605822"})
  end

  it "Schema 4.4 from string" do
    input = fixture_path + "datacite-example-full-v4.4.xml"
    subject = Bolognese::Metadata.new(input: input)
    expect(subject.valid?).to be true
    expect(subject.types["schemaOrg"]).to eq("SoftwareSourceCode")
    expect(subject.types["resourceType"]).to eq("XML")
    expect(subject.types["resourceTypeGeneral"]).to eq("Software")
    expect(subject.creators).to eq(
      [
        {
          "name"=>"Miller, Elizabeth", "givenName"=>"Elizabeth", "familyName"=>"Miller",
          "nameType" => "Personal",
          "nameIdentifiers"=> [{"nameIdentifier"=>"https://orcid.org/0000-0001-5000-0007",
             "schemeUri"=>"https://orcid.org",
             "nameIdentifierScheme"=>"ORCID"}],
          "affiliation" => [{ "name" => "DataCite" }]
        }
      ]
    )
    expect(subject.titles).to eq(
      [
        {"title"=>"Full DataCite XML Example", "lang"=>"en-US"},
        {"title"=>"Demonstration of DataCite Properties.", "titleType"=>"Subtitle", "lang"=>"en-US"}
      ]
    )
    expect(subject.identifiers).to eq([{"identifier"=>"https://schema.datacite.org/meta/kernel-4.4/example/datacite-example-full-v4.4.xml", "identifierType"=>"URL"}])
    expect(subject.dates).to eq(
      [
        {"date"=>"2021-01-26", "dateInformation"=>"Updated with 4.4 properties", "dateType"=>"Updated"},
        {"date"=>"2014", "dateType"=>"Issued"}
      ]
    )
    expect(subject.publication_year).to eq("2014")
    expect(subject.subjects).to eq(
      [{
        "subject"=>"computer science",
        "subjectScheme"=>"dewey",
        "schemeUri"=>"http://dewey.info/",
        "lang"=>"en-US",
        "classificationCode"=>"000"
      }]
    )
    expect(subject.related_identifiers.length).to eq(2)
    expect(subject.related_identifiers.last).to eq(
      "relatedIdentifier"=>"arXiv:0706.0001",
      "relatedIdentifierType"=>"arXiv",
      "relationType"=>"IsReviewedBy",
      "resourceTypeGeneral"=>"Text"
    )
    expect(subject.rights_list).to eq([
      {
      "lang"=>"en-US",
      "rights"=>"Creative Commons Zero v1.0 Universal",
      "rightsIdentifier"=>"cc0-1.0",
      "rightsIdentifierScheme"=>"SPDX",
      "rightsUri"=>"https://creativecommons.org/publicdomain/zero/1.0/legalcode",
      "schemeUri"=>"https://spdx.org/licenses/"
      }
    ])
    expect(subject.publisher).to eq(
      {
        "name"=>"DataCite",
        "lang"=>"en",
        }
      )
    expect(subject.agency).to eq("datacite")
    expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-4")
    expect(subject.related_items.last).to eq(
      {
        "relatedItemType"=>"Journal",
        "relationType"=>"IsPublishedIn",
        "relatedItemIdentifier"=>
        {
          "relatedItemIdentifier"=>"10.1016/j.physletb.2017.11.044",
          "relatedItemIdentifierType"=>"DOI",
        },
        "titles"=>
        [
          {"title"=>"Physics letters / B"},
        ],
        "volume"=>"776",
        "firstPage"=>"249",
        "lastPage"=>"264",
        "publicationYear"=>"2018",
        "contributors"=>[],
        "creators"=>[],
      }
    )
  end

  it "Schema 4.4 related items from string" do
    input = fixture_path + "datacite-example-relateditems.xml"
    subject = Bolognese::Metadata.new(input: input)
    expect(subject.valid?).to be true

    expect(subject.related_items.last).to eq(
      {
        "relatedItemType"=>"Journal",
        "relationType"=>"IsPublishedIn",
        "relatedItemIdentifier"=>
        {
          "relatedItemIdentifier"=>"10.5072/john-smiths-1234",
          "relatedItemIdentifierType"=>"DOI",
          "relatedMetadataScheme"=>"citeproc+json",
          "schemeURI"=>"https://github.com/citation-style-language/schema/raw/master/csl-data.json",
          "schemeType"=>"URL"
        },
        "creators" =>
        [
          {"nameType"=>"Personal", "name"=>"Smith, John", "givenName"=>"John", "familyName"=>"Smith"}
        ],
        "titles"=>
        [
          {"title"=>"Understanding the fictional John Smith"},
          {"title"=>"A detailed look", "titleType"=>"Subtitle"}
        ],
        "volume"=>"776",
        "issue"=>"1",
        "number"=>"1",
        "numberType"=>"Chapter",
        "firstPage"=>"50",
        "lastPage"=>"60",
        "publisher"=>"Example Inc",
        "publicationYear"=>"1776",
        "edition"=>"1",
        "contributors"=>
        [
          {"name"=>"Hallett, Richard", "givenName"=>"Richard", "familyName"=>"Hallett", "contributorType"=>"ProjectLeader"}
        ]
      }
    )
  end


  it "Schema 4.4 related items from string minus relatedIdentifier" do
    input = fixture_path + "datacite-example-relateditems.xml"

    # Remove relatedItemIdentifier from raw input
    @doc = File.open(input) { |f| Nokogiri::XML(f) }
    @doc.xpath("//xmlns:relatedItemIdentifier").each {|x| x.remove}

    subject = Bolognese::Metadata.new(input: @doc.to_s)
    expect(subject.valid?).to be true

    expect(subject.related_items.last).to eq(
      {
        "relatedItemType"=>"Journal",
        "relationType"=>"IsPublishedIn",
        "creators" =>
        [
          {"nameType"=>"Personal", "name"=>"Smith, John", "givenName"=>"John", "familyName"=>"Smith"}
        ],
        "titles"=>
        [
          {"title"=>"Understanding the fictional John Smith"},
          {"title"=>"A detailed look", "titleType"=>"Subtitle"}
        ],
        "volume"=>"776",
        "issue"=>"1",
        "number"=>"1",
        "numberType"=>"Chapter",
        "firstPage"=>"50",
        "lastPage"=>"60",
        "publisher"=>"Example Inc",
        "publicationYear"=>"1776",
        "edition"=>"1",
        "contributors"=>
        [
          {"name"=>"Hallett, Richard", "givenName"=>"Richard", "familyName"=>"Hallett", "contributorType"=>"ProjectLeader"}
        ]
      }
    )
  end

  it "Schema 4.4 related items from string with attributes" do
    input = fixture_path + "datacite-example-relateditems-with-attributes.xml"
    subject = Bolognese::Metadata.new(input: input)
    expect(subject.valid?).to be true

    expect(subject.related_items.last).to eq(
      {
        "relatedItemType"=>"Journal",
        "relationType"=>"IsPublishedIn",
        "relatedItemIdentifier"=>
        {
          "relatedItemIdentifier"=>"10.5072/john-smiths-1234",
          "relatedItemIdentifierType"=>"DOI",
          "relatedMetadataScheme"=>"citeproc+json",
          "schemeURI"=>"https://github.com/citation-style-language/schema/raw/master/csl-data.json",
          "schemeType"=>"URL"
        },
        "creators" =>
        [
          {"nameType"=>"Personal", "name"=>"Smith, John", "givenName"=>"John", "familyName"=>"Smith"}
        ],
        "titles"=>
        [
          {"title"=>"Understanding the fictional John Smith"},
          {"title"=>"A detailed look", "titleType"=>"Subtitle"}
        ],
        "volume"=>"776",
        "issue"=>"1",
        "number"=>"1",
        "numberType"=>"Chapter",
        "firstPage"=>"50",
        "lastPage"=>"60",
        "publisher"=>"Example Inc",
        "publicationYear"=>"1776",
        "edition"=>"1",
        "contributors"=>
        [
          {"name"=>"Hallett, Richard", "givenName"=>"Richard", "familyName"=>"Hallett", "contributorType"=>"ProjectLeader"}
        ]
      }
    )
  end

  it "Schema 4.4 dissertation from string" do
    input = fixture_path + "datacite-example-dissertation-v4.4.xml"
    subject = Bolognese::Metadata.new(input: input)
    expect(subject.valid?).to be true
    expect(subject.types["resourceType"]).to eq(nil)
    expect(subject.types["resourceTypeGeneral"]).to eq("Dissertation")
    expect(subject.types["schemaOrg"]).to eq("Thesis")
    expect(subject.types["ris"]).to eq("THES")
    expect(subject.types["citeproc"]).to eq("thesis")
    expect(subject.creators).to eq(
      [
        {
          "name"=>"Luo, R",
          "familyName"=>"Luo",
          "givenName"=>"R",
          "nameIdentifiers"=>[],
          "affiliation"=>[],
          "nameType" => "Personal"
        },
        {
          "name"=>"Liu, B",
          "familyName"=>"Liu",
          "givenName"=>"B",
          "nameIdentifiers"=>[],
          "affiliation"=>[],
          "nameType" => "Personal"
        },
        {
          "name"=>"Xie, Y",
          "familyName"=>"Xie",
          "givenName"=>"Y",
          "nameIdentifiers"=>[],
          "affiliation"=>[],
          "nameType" => "Personal"
        },
        {
          "name"=>"Li, Z",
          "familyName"=>"Li",
          "givenName"=>"Z",
          "nameIdentifiers"=>[],
          "affiliation"=>[],
          "nameType" => "Personal"
        }
      ]
    )
    expect(subject.titles).to eq(
      [
        {"title"=>"Software and supporting material for \"SOAPdenovo2: An empirically improved memory-efficient short read de novo assembly\"", "lang"=>"en"},
      ]
    )
    expect(subject.dates).to eq(
      [
        {"date"=>"2012-12-13", "dateType"=>"Available"},
        {"date"=>"2012", "dateType"=>"Issued"}
      ]
    )
    expect(subject.publication_year).to eq("2012")
    expect(subject.subjects).to eq(
      [
        {
        "subject"=>"DNA (Genetics)",
        "lang"=>"en"
        },
        {
        "subject"=>"Computer Program",
        "lang"=>"en"
        }
      ]
    )
    expect(subject.related_identifiers).to eq(
      [
        {"relatedIdentifier"=>"10.5072/2047-217x-1-1", "relatedIdentifierType"=>"DOI", "relationType"=>"IsReferencedBy"},
        {"relatedIdentifier"=>"10.5072/100038", "relatedIdentifierType"=>"DOI", "relationType"=>"Compiles"}
      ]
    )
    expect(subject.rights_list).to eq([
      {
      "lang"=>"en-US",
      "rights"=>"Creative Commons Zero v1.0 Universal",
      "rightsIdentifier"=>"cc0-1.0",
      "rightsIdentifierScheme"=>"SPDX",
      "rightsUri"=>"https://creativecommons.org/publicdomain/zero/1.0/legalcode",
      "schemeUri"=>"https://spdx.org/licenses/"
      }
    ])
    expect(subject.publisher).to eq(
      {
        "name"=>"GigaScience Database",
        "lang"=>"en",
      }
    )
    expect(subject.agency).to eq("datacite")
    expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-4")
  end


  it "Parsing xs-string attribute correctly" do
    input = fixture_path + "datacite-example-xs-string.xml"
    subject = Bolognese::Metadata.new(input: input)
    expect(subject.valid?).to be true
    expect(subject.id).to eq("https://doi.org/10.4225/13/511c71f8612c3")
    expect(subject.sizes.first).to eq("1.7 GB")
    expect(subject.formats.first).to eq("application/xml")
  end

  it "Parsing multiple geolocationpolygon elements" do
    input = fixture_path + "datacite-geolocationpolygons-multiple.xml"
    subject = Bolognese::Metadata.new(input: input)
    expect(subject.valid?).to be true
    expect(subject.id).to eq("https://doi.org/10.5072/multiplegeopolygons")
    expect(subject.geo_locations).to eq([
      { "geoLocationPolygon"=> [
        [ {"polygonPoint"=>{"pointLatitude"=>"71", "pointLongitude"=>"41"}},
          {"polygonPoint"=>{"pointLatitude"=>"75", "pointLongitude"=>"45"}},
          {"polygonPoint"=>{"pointLatitude"=>"85", "pointLongitude"=>"55"}},
          {"polygonPoint"=>{"pointLatitude"=>"71", "pointLongitude"=>"41"}}],
        [
          {"polygonPoint"=>{"pointLatitude"=>"80", "pointLongitude"=>"65"}},
          {"polygonPoint"=>{"pointLatitude"=>"75", "pointLongitude"=>"55"}},
          {"polygonPoint"=>{"pointLatitude"=>"73", "pointLongitude"=>"45"}},
          {"polygonPoint"=>{"pointLatitude"=>"80", "pointLongitude"=>"65"}}
        ]
      ] },
      { "geoLocationPolygon"=>
        [
          {"polygonPoint"=>{"pointLatitude"=>"80", "pointLongitude"=>"65"}},
          {"polygonPoint"=>{"pointLatitude"=>"75", "pointLongitude"=>"55"}},
          {"polygonPoint"=>{"pointLatitude"=>"73", "pointLongitude"=>"45"}},
          {"polygonPoint"=>{"pointLatitude"=>"80", "pointLongitude"=>"65"}}
        ]
      }
      ]
    )
  end

  describe "Schema 4.5" do
    it "publisher with attributes" do
      input = fixture_path + "datacite-example-full-v4.5.xml"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.publisher).to eq( 
        {
          "name" => "Example Publisher",
          "publisherIdentifier" => "https://ror.org/04z8jg394",
          "publisherIdentifierScheme" => "ROR",
          "schemeUri" => "https://ror.org/",
          "lang" => "en",
        }
      )
    end
  end

  it "blank nameIdentifier" do
    input = fixture_path + "datacite_blank_name_identifier.xml"
    subject = Bolognese::Metadata.new(input: input)
    expect(subject.creators).to eq(
      [
        {
          "nameType" => "Personal",
          "name" => "KARST, SNO",
          "givenName" => "SNO",
          "familyName" => "KARST",
          "nameIdentifiers" =>
            [
              {
                "schemeUri" => "https://orcid.org",
                "nameIdentifierScheme" => "ORCID"
              }
            ],
          "affiliation" => []
        }
      ]
    )
    expect(subject.contributors).to eq(
      [
        {
          "nameType" => "Personal",
          "name" => "Manche, Yannick",
          "givenName" => "Yannick",
          "familyName" => "Manche",
          "nameIdentifiers" =>
            [
              {
                "schemeUri" => "https://orcid.org",
                "nameIdentifierScheme" => "ORCID"
              }
            ],
          "affiliation" => [],
          "contributorType" => "ProjectMember"
        }
      ]
    )
  end

  it "blank publisher" do
    input = fixture_path + "datacite_blank_publisher.xml"
    subject = Bolognese::Metadata.new(input: input)
    expect(subject.publisher).to eq(
      { "publisherIdentifier" => "https://ror.org/04wxnsj81" }
    )
  end

  describe "DataCite Schema 4.6" do
    it "handles all DataCite 4.6 features in one XML" do
      input = fixture_path + 'datacite-example-full-v4.6.xml'
      subject = Bolognese::Metadata.new(input: input)

      puts "Validation Errors: #{subject.errors.inspect}"

      expect(subject.valid?).to be true

      # Test resourceTypeGeneral for Project
      expect(subject.types["resourceTypeGeneral"]).to eq("Project")
      expect(subject.types["resourceType"]).to eq("Research Project")

      # Test relatedIdentifiers for RRID and CSTR
      expect(subject.related_identifiers.length).to eq(4)
      expect(subject.related_identifiers).to include(
        { "relatedIdentifier" => "RRID:AB_90755", "relatedIdentifierType" => "RRID", "relationType" => "References" },
        { "relatedIdentifier" => "CSTR:AB_12345", "relatedIdentifierType" => "CSTR", "relationType" => "References" }
      )

      # Test relationType HasTranslation and IsTranslationOf
      expect(subject.related_identifiers).to include(
        { "relatedIdentifier" => "10.1234/translated-version", "relatedIdentifierType" => "DOI", "relationType" => "HasTranslation" },
        { "relatedIdentifier" => "10.1234/other-version", "relatedIdentifierType" => "DOI", "relationType" => "IsTranslationOf" }
      )

      # Test contributorType for Translator
      expect(subject.contributors.length).to eq(2)
      expect(subject.contributors.first).to include(
        "contributorType" => "Translator",
        "familyName" => "Doe",
        "givenName" => "Jane"
      )

      # Test dateType for Coverage
      expect(subject.dates).to include(
        { "dateType" => "Coverage", "date" => "2020-01-01" }
      )

    end
  end
end

