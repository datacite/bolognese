# frozen_string_literal: true

require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  context "write metadata as datacite xml" do
    it "with data citation" do
      input = "10.7554/eLife.01567"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      expect(subject.valid?).to be true
      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.dig("resourceType", "resourceTypeGeneral")).to eq("Text")
      expect(datacite.dig("titles", "title")).to eq("Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
      expect(datacite.dig("relatedIdentifiers", "relatedIdentifier").length).to eq(27)
      expect(datacite.dig("relatedIdentifiers", "relatedIdentifier").first).to eq("relatedIdentifierType"=>"ISSN", "relationType"=>"IsPartOf", "__content__"=>"2050-084X", "resourceTypeGeneral"=>"Collection")
      expect(datacite.dig("relatedIdentifiers", "relatedIdentifier")[1]).to eq("relatedIdentifierType"=>"DOI", "relationType"=>"References", "__content__"=>"10.1038/nature02100")
      expect(datacite.dig("rightsList", "rights")).to eq("rightsURI"=>"https://creativecommons.org/licenses/by/3.0/legalcode", "rightsIdentifier"=>"cc-by-3.0", "rightsIdentifierScheme"=>"SPDX", "schemeURI"=>"https://spdx.org/licenses/", "__content__"=>"Creative Commons Attribution 3.0 Unported")
      expect(datacite.dig("fundingReferences", "fundingReference").count).to eq(4)
      expect(datacite.dig("fundingReferences", "fundingReference").last).to eq("funderName"=>"University of Lausanne", "funderIdentifier" => {"funderIdentifierType"=>"Crossref Funder ID", "__content__"=>"https://doi.org/10.13039/501100006390"})
    end

    it "with ORCID ID" do
      input = "https://doi.org/10.1155/2012/291294"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      expect(subject.valid?).to be true
      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.dig("resourceType", "resourceTypeGeneral")).to eq("Text")
      expect(datacite.dig("creators", "creator").count).to eq(7)
      expect(datacite.dig("creators", "creator")[2]).to eq("creatorName" => {"__content__"=>"Hernandez, Beatriz", "nameType"=>"Personal"},
        "familyName" => "Hernandez",
        "givenName" => "Beatriz",
        "affiliation" => ["War Related Illness and Injury Study Center (WRIISC) and Mental Illness Research Education and Clinical Center (MIRECC), Department of Veterans Affairs, Palo Alto, CA 94304, USA", "Department of Psychiatry and Behavioral Sciences, Stanford University School of Medicine, Stanford, CA 94304, USA"],
        "nameIdentifier" => {"nameIdentifierScheme"=>"ORCID", "schemeURI"=>"https://orcid.org", "__content__"=>"https://orcid.org/0000-0003-2043-4925"})
    end

    it "with editor" do
      input = "https://doi.org/10.1371/journal.pone.0000030"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      expect(subject.valid?).to be true
      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.dig("contributors", "contributor")).to eq("contributorName"=>{"__content__"=>"Janbon, Guilhem", "nameType"=>"Personal"}, "contributorType"=>"Editor", "familyName"=>"Janbon", "givenName"=>"Guilhem")
    end

    it "Crossref DOI" do
      input = fixture_path + "crossref.bib"
      subject = Bolognese::Metadata.new(input: input, from: "bibtex")
      expect(subject.valid?).to be true
      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.dig("resourceType", "resourceTypeGeneral")).to eq("Text")
      expect(datacite.dig("titles", "title")).to eq("Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
      expect(datacite.dig("descriptions", "description").first).to eq("__content__"=>"eLife, 3", "descriptionType"=>"SeriesInformation")
      expect(datacite.dig("descriptions", "description", 1, "__content__")).to start_with("Among various advantages, their small size makes model organisms preferred subjects of investigation.")
      expect(datacite.dig("creators", "creator").count).to eq(5)
      expect(datacite.dig("creators", "creator").first).to eq("creatorName"=>{"__content__"=>"Sankar, Martial", "nameType"=>"Personal"}, "familyName"=>"Sankar", "givenName"=>"Martial")
    end

    it "BlogPosting Citeproc JSON" do
      input = fixture_path + "citeproc.json"
      subject = Bolognese::Metadata.new(input: input, from: "citeproc")
      expect(subject.valid?).to be true
      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.dig("resourceType", "resourceTypeGeneral")).to eq("Text")
      expect(datacite.dig("titles", "title")).to eq("Eating your own Dog Food")
      expect(datacite.dig("descriptions", "description").first).to eq("__content__"=>"DataCite Blog", "descriptionType"=>"SeriesInformation")
      expect(datacite.dig("descriptions", "description", 1, "__content__")).to start_with("Eating your own dog food")
      expect(datacite.dig("creators", "creator")).to eq("creatorName"=>"Fenner, Martin", "familyName"=>"Fenner", "givenName"=>"Martin")
    end

    it "rdataone" do
      input = fixture_path + 'codemeta.json'
      subject = Bolognese::Metadata.new(input: input, from: "codemeta")
      expect(subject.valid?).to be true
      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.dig("titles", "title")).to eq("R Interface to the DataONE REST API")
      expect(datacite.dig("creators", "creator")).to eq([{"affiliation"=>"NCEAS", "creatorName"=>{"__content__"=>"Jones, Matt", "nameType"=>"Personal"},
                                                          "givenName"=>"Matt",
                                                          "familyName"=>"Jones",
                                                          "nameIdentifier"=>
                                                         {"nameIdentifierScheme"=>"ORCID",
                                                          "schemeURI"=>"https://orcid.org",
                                                          "__content__"=>"https://orcid.org/0000-0003-0077-4738"}},
                                                         {"affiliation"=>"NCEAS", "creatorName"=>{"__content__"=>"Slaughter, Peter", "nameType"=>"Personal"},
                                                           "givenName"=>"Peter",
                                                           "familyName"=>"Slaughter",
                                                          "nameIdentifier"=>
                                                         {"nameIdentifierScheme"=>"ORCID",
                                                          "schemeURI"=>"https://orcid.org",
                                                          "__content__"=>"https://orcid.org/0000-0002-2192-403X"}},
                                                         {"creatorName"=>{"__content__"=>"University Of California, Santa Barbara", "nameType"=>"Organizational"}}])
      expect(datacite.fetch("version")).to eq("2.0.0")
    end

    it "rdataone and codemeta_v2" do
      input = fixture_path + 'codemeta_v2.json'
      subject = Bolognese::Metadata.new(input: input, from: "codemeta")
      expect(subject.valid?).to be true
      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.dig("titles", "title")).to eq("R Interface to the DataONE REST API")
      expect(datacite.dig("creators", "creator")).to eq([{"affiliation"=>"NCEAS", "creatorName"=>{"__content__"=>"Jones, Matt", "nameType"=>"Personal"},
                                                          "givenName"=>"Matt",
                                                          "familyName"=>"Jones",
                                                          "nameIdentifier"=>
                                                         {"nameIdentifierScheme"=>"ORCID",
                                                          "schemeURI"=>"https://orcid.org",
                                                          "__content__"=>"https://orcid.org/0000-0003-0077-4738"}},
                                                         {"affiliation"=>"NCEAS", "creatorName"=>{"__content__"=>"Slaughter, Peter", "nameType"=>"Personal"},
                                                           "givenName"=>"Peter",
                                                           "familyName"=>"Slaughter",
                                                          "nameIdentifier"=>
                                                         {"nameIdentifierScheme"=>"ORCID",
                                                          "schemeURI"=>"https://orcid.org",
                                                          "__content__"=>"https://orcid.org/0000-0002-2192-403X"}},
                                                         {"creatorName"=>{"__content__"=>"University Of California, Santa Barbara", "nameType"=>"Organizational"}}])
      expect(datacite.fetch("version")).to eq("2.0.0")
    end

    it "maremma" do
      input = "https://github.com/datacite/maremma"
      subject = Bolognese::Metadata.new(input: input, from: "codemeta")
      expect(subject.valid?).to be true
      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.dig("titles", "title")).to eq("Maremma: a Ruby library for simplified network calls")
      expect(datacite.dig("creators", "creator")).to eq("affiliation"=>"DataCite", "creatorName"=> {"__content__"=>"Fenner, Martin", "nameType"=>"Personal"}, "givenName"=>"Martin", "familyName"=>"Fenner", "nameIdentifier"=>{"__content__"=>"https://orcid.org/0000-0003-0077-4738", "nameIdentifierScheme"=>"ORCID", "schemeURI"=>"https://orcid.org"})
    end

    it "with version" do
      input = "https://doi.org/10.5281/zenodo.28518"
      subject = Bolognese::Metadata.new(input: input, from: "datacite", regenerate: true)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.5281/zenodo.28518")
      expect(subject.identifiers).to eq([{"identifier"=>"https://zenodo.org/record/28518", "identifierType"=>"URL"}])
      expect(subject.types).to eq("bibtex" => "misc",
        "citeproc" => "article",
        "resourceTypeGeneral" => "Software",
        "ris" => "COMP",
        "schemaOrg" => "SoftwareSourceCode")
      expect(subject.creators.length).to eq(2)
      expect(subject.creators.first).to eq("affiliation" => [{"name"=>"University of Washington"}],
        "familyName" => "Vanderplas",
        "givenName" => "Jake",
        "name" => "Vanderplas, Jake",
        "nameIdentifiers" => [],
        "nameType" => "Personal")
      expect(subject.titles).to eq([{"title"=>"Supersmoother: Minor Bug Fix Release"}])
      expect(subject.rights_list).to eq([{"rights"=>"Open Access", "rightsUri"=>"info:eu-repo/semantics/openAccess"}])
      expect(subject.dates).to eq([{"date"=>"2015-08-19", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2015")
      expect(subject.version_info).to eq("v0.3.2")
      expect(subject.publisher).to eq("Zenodo")
      expect(subject.agency).to eq("datacite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-4")
      expect(subject.datacite).to include("<version>v0.3.2</version>")
    end

    it "Text pass-thru" do
      input = "https://doi.org/10.23640/07243.5153971"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.23640/07243.5153971")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"Paper", "resourceTypeGeneral"=>"Text", "ris"=>"RPRT", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.length).to eq(20)
      expect(subject.creators.first).to eq("nameType"=>"Personal", "familyName" => "Paglione", "givenName" => "Laura", "nameIdentifiers" => [{"nameIdentifier"=>"https://orcid.org/0000-0003-3188-6273", "nameIdentifierScheme"=>"ORCID", "schemeUri"=>"https://orcid.org"}], "name" => "Paglione, Laura", "affiliation" => [])
      expect(subject.titles).to eq([{"title"=>"Recommendation of: ORCID Works Metadata Working Group"}])
      expect(subject.rights_list).to eq([{"rights"=>"Creative Commons Zero v1.0 Universal",
        "rightsIdentifier"=>"cc0-1.0",
        "rightsIdentifierScheme"=>"SPDX",
        "rightsUri"=>"https://creativecommons.org/publicdomain/zero/1.0/legalcode",
        "schemeUri"=>"https://spdx.org/licenses/"}])
      expect(subject.dates).to eq([{"date"=>"2017-06-28", "dateType"=>"Created"}, {"date"=>"2017-06-28", "dateType"=>"Updated"}, {"date"=>"2017", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2017")
      expect(subject.publisher).to eq("Figshare")
      expect(subject.subjects).to eq([{"subject"=>"Information Systems"},
       {"schemeUri"=>"http://www.oecd.org/science/inno/38235147.pdf",
        "subject"=>"FOS: Computer and information sciences",
        "subjectScheme"=>"Fields of Science and Technology (FOS)"}])
      expect(subject.agency).to eq("datacite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-3")
      expect(subject.datacite).to end_with("</resource>")
    end

    it "Text pass-thru with doi in options" do
      input = "https://doi.org/10.23640/07243.5153971"
      subject = Bolognese::Metadata.new(input: input, from: "datacite", doi: "10.5072/07243.5153971")
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.5072/07243.5153971")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"Paper", "resourceTypeGeneral"=>"Text", "ris"=>"RPRT", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.length).to eq(20)
      expect(subject.creators.first).to eq("nameType" => "Personal", "familyName" => "Paglione", "givenName" => "Laura", "name" => "Paglione, Laura", "nameIdentifiers" => [{"nameIdentifier"=>"https://orcid.org/0000-0003-3188-6273", "nameIdentifierScheme"=>"ORCID", "schemeUri"=>"https://orcid.org"}],"affiliation" => [])
      expect(subject.titles).to eq([{"title"=>"Recommendation of: ORCID Works Metadata Working Group"}])
      expect(subject.rights_list).to eq([{"rights"=>"Creative Commons Zero v1.0 Universal",
        "rightsIdentifier"=>"cc0-1.0",
        "rightsIdentifierScheme"=>"SPDX",
        "rightsUri"=>"https://creativecommons.org/publicdomain/zero/1.0/legalcode",
        "schemeUri"=>"https://spdx.org/licenses/"}])
      expect(subject.dates).to eq([{"date"=>"2017-06-28", "dateType"=>"Created"}, {"date"=>"2017-06-28", "dateType"=>"Updated"}, {"date"=>"2017", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2017")
      expect(subject.publisher).to eq("Figshare")
      expect(subject.subjects).to eq([{"subject"=>"Information Systems"},
       {"schemeUri"=>"http://www.oecd.org/science/inno/38235147.pdf",
        "subject"=>"FOS: Computer and information sciences",
        "subjectScheme"=>"Fields of Science and Technology (FOS)"}])
      expect(subject.agency).to eq("datacite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-3")
      expect(subject.datacite).to end_with("</resource>")
    end

    it "Dataset in schema 4.0" do
      input = "https://doi.org/10.5061/DRYAD.8515"
      subject = Bolognese::Metadata.new(input: input, from: "datacite", regenerate: true)
      expect(subject.valid?).to be true
      expect(subject.types).to eq("bibtex"=>"misc", "citeproc"=>"dataset", "resourceType"=>"dataset", "resourceTypeGeneral"=>"Dataset", "ris"=>"DATA", "schemaOrg"=>"Dataset")
      expect(subject.creators.length).to eq(8)
      expect(subject.creators.first).to eq("nameType" => "Personal", "name"=>"Ollomo, Benjamin", "givenName"=>"Benjamin", "familyName"=>"Ollomo", "nameIdentifiers"=>[], "affiliation" => [{"affiliationIdentifier"=>"https://ror.org/01wyqb997", "affiliationIdentifierScheme"=>"ROR", "name"=>"Centre International de Recherches Médicales de Franceville"}])
      expect(subject.titles).to eq([{"title"=>"Data from: A new malaria agent in African hominids."}])
      expect(subject.id).to eq("https://doi.org/10.5061/dryad.8515")
      expect(subject.rights_list).to eq([{"rights"=>"Creative Commons Zero v1.0 Universal",
        "rightsIdentifier"=>"cc0-1.0",
        "rightsIdentifierScheme"=>"SPDX",
        "rightsUri"=>"https://creativecommons.org/publicdomain/zero/1.0/legalcode",
        "schemeUri"=>"https://spdx.org/licenses/"}])
      expect(subject.dates).to eq([{"date"=>"2011-02-01T17:22:41Z", "dateType"=>"Available"}, {"date"=>"2011", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2011")
      expect(subject.related_identifiers.length).to eq(1)
      expect(subject.related_identifiers.last).to eq("relatedIdentifier" => "10.1371/journal.ppat.1000446",
        "relatedIdentifierType" => "DOI","relationType"=>"IsSupplementTo")
      expect(subject.publisher).to eq("Dryad")
      expect(subject.agency).to eq("datacite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-4")

      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.fetch("xsi:schemaLocation", "").split(" ").first).to eq("http://datacite.org/schema/kernel-4")
    end

    it "Affiliation" do
      input = fixture_path + 'datacite-example-geolocation-2.xml'
      doi = "10.6071/Z7WC73"
      subject = Bolognese::Metadata.new(input: input, from: "datacite", regenerate: true)
      expect(subject.valid?).to be true
      expect(subject.types).to eq("bibtex"=>"misc", "citeproc"=>"dataset", "resourceType"=>"dataset", "resourceTypeGeneral"=>"Dataset", "ris"=>"DATA", "schemaOrg"=>"Dataset")
      expect(subject.creators.length).to eq(6)
      expect(subject.creators.first).to eq("affiliation"=>[{"name"=>"UC Merced"}, {"name"=>"NSF"}], "familyName"=>"Bales", "givenName"=>"Roger", "name"=>"Bales, Roger", "nameType"=>"Personal", "nameIdentifiers"=>[])
      expect(subject.titles).to eq([{"title"=>"Southern Sierra Critical Zone Observatory (SSCZO), Providence Creek meteorological data, soil moisture and temperature, snow depth and air temperature"}])
      expect(subject.id).to eq("https://doi.org/10.6071/z7wc73")
      expect(subject.rights_list).to eq([{"rights"=>"Creative Commons Attribution 4.0 International",
        "rightsIdentifier"=>"cc-by-4.0",
        "rightsIdentifierScheme"=>"SPDX",
        "rightsUri"=>"https://creativecommons.org/licenses/by/4.0/legalcode",
        "schemeUri"=>"https://spdx.org/licenses/"}])
      expect(subject.dates).to eq([{"date"=>"2014-10-17", "dateType"=>"Updated"}, {"date"=>"2016-03-14T17:02:02Z", "dateType"=>"Available"}, {"date"=>"2013", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2013")
      expect(subject.publisher).to eq("UC Merced")
      expect(subject.agency).to eq("datacite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-4")

      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.fetch("xsi:schemaLocation", "").split(" ").first).to eq("http://datacite.org/schema/kernel-4")
      expect(datacite.dig("creators", "creator", 0, "affiliation")).to eq(["UC Merced", "NSF"])
    end

    it "with data citation schema.org" do
      input = "https://blog.datacite.org/eating-your-own-dog-food/"
      subject = Bolognese::Metadata.new(input: input, from: "schema_org")
      expect(subject.valid?).to be true
      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.dig("titles", "title")).to eq("Eating your own Dog Food")
      expect(datacite.dig("relatedIdentifiers", "relatedIdentifier").count).to eq(3)
      expect(datacite.dig("relatedIdentifiers", "relatedIdentifier").first).to eq("__content__"=>"10.5438/0000-00ss", "relatedIdentifierType"=>"DOI", "relationType"=>"IsPartOf", "resourceTypeGeneral"=>"Text")
    end

    it "DOI not found" do
      input = "https://doi.org/10.4124/05F6C379-DD68-4CDB-880D-33D3E9576D52/1"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      expect(subject.valid?).to be false
      expect(subject.id).to eq("https://doi.org/10.4124/05f6c379-dd68-4cdb-880d-33d3e9576d52/1")
      expect(subject.doi).to eq("10.4124/05f6c379-dd68-4cdb-880d-33d3e9576d52/1")
      expect(subject.agency).to eq("datacite")
      expect(subject.state).to eq("not_found")
      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite["identifier"]).to eq("identifierType"=>"DOI", "__content__"=>"10.4124/05f6c379-dd68-4cdb-880d-33d3e9576d52/1")
      expect(datacite["xmlns"]).to eq("http://datacite.org/schema/kernel-4")
    end

    it "no input" do
      input = nil
      subject = Bolognese::Metadata.new(input: input, from: "datacite", doi: "10.4124/05f6c379-dd68-4cdb-880d-33d3e9576d52/1")
      expect(subject.valid?).to be false
      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite["identifier"]).to eq("identifierType"=>"DOI", "__content__"=>"10.4124/05f6c379-dd68-4cdb-880d-33d3e9576d52/1")
      expect(datacite["xmlns"]).to eq("http://datacite.org/schema/kernel-4")
    end
  end

  context "change metadata as datacite xml" do
    it "with data citation" do
      input = "10.7554/eLife.01567"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      subject.doi = "10.5061/DRYAD.8515"
      subject.titles = [{ "title" => "Data from: Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth" }]
      subject.types = { "schemaOrg" => "Dataset", "resourceTypeGeneral" => "Dataset" }
      expect(subject.valid?).to be true
      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.dig("identifier", "__content__")).to eq("10.5061/DRYAD.8515")
      expect(datacite.dig("resourceType", "resourceTypeGeneral")).to eq("Dataset")
      expect(datacite.dig("titles", "title")).to eq("Data from: Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
      expect(datacite.dig("relatedIdentifiers", "relatedIdentifier").length).to eq(27)
      expect(datacite.dig("relatedIdentifiers", "relatedIdentifier").first).to eq("__content__"=>"2050-084X", "relatedIdentifierType"=>"ISSN", "relationType"=>"IsPartOf", "resourceTypeGeneral"=>"Collection")
      expect(datacite.dig("relatedIdentifiers", "relatedIdentifier")[1]).to eq("relatedIdentifierType"=>"DOI", "relationType"=>"References", "__content__"=>"10.1038/nature02100")
      expect(datacite.dig("rightsList", "rights")).to eq("rightsURI"=>"https://creativecommons.org/licenses/by/3.0/legalcode", "rightsIdentifier"=>"cc-by-3.0", "rightsIdentifierScheme"=>"SPDX", "schemeURI"=>"https://spdx.org/licenses/", "__content__"=>"Creative Commons Attribution 3.0 Unported")
      expect(datacite.dig("fundingReferences", "fundingReference").count).to eq(4)
      expect(datacite.dig("fundingReferences", "fundingReference").last).to eq("funderName"=>"University of Lausanne", "funderIdentifier" => {"funderIdentifierType"=>"Crossref Funder ID", "__content__"=>"https://doi.org/10.13039/501100006390"})
    end

    it "change description" do
      input = "10.7554/eLife.01567"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      subject.descriptions = { "description" => "This is an abstract." }
      expect(subject.valid?).to be true
      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.dig("descriptions", "description")).to eq( [{"__content__"=>"eLife, 3", "descriptionType"=>"SeriesInformation"}, {"__content__"=>"This is an abstract.", "descriptionType"=>"Abstract"}])
    end

    it "change description no input" do
      input = nil
      subject = Bolognese::Metadata.new(input: input, from: "datacite", doi: "10.4124/05f6c379-dd68-4cdb-880d-33d3e9576d52/1")
      subject.descriptions = "This is an abstract."
      expect(subject.valid?).to be false
      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.dig("descriptions", "description")).to eq("descriptionType"=>"Abstract", "__content__"=>"This is an abstract.")
    end

    it "required metadata no input" do
      input = nil
      subject = Bolognese::Metadata.new(input: input, doi: "10.4124/05f6c379-dd68-4cdb-880d-33d3e9576d52/1")
      subject.creators = [{"creatorName"=>"Fenner, Martin", "givenName"=>"Martin", "familyName"=>"Fenner"}]
      subject.titles = [{ "title" => "Data from: Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth" }]
      subject.types = { "schemaOrg" => "Dataset", "resourceTypeGeneral" => "Dataset" }
      subject.publication_year = "2011"
      subject.state = "findable"
      expect(subject.exists?).to be true
      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.dig("identifier", "__content__")).to eq("10.4124/05f6c379-dd68-4cdb-880d-33d3e9576d52/1")
      expect(datacite.dig("resourceType", "resourceTypeGeneral")).to eq("Dataset")
      expect(datacite.dig("titles", "title")).to eq("Data from: Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
      
    end

    it "change license" do
      input = "10.7554/eLife.01567"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      subject.rights_list = [{ "rights_uri" => "https://creativecommons.org/licenses/by-nc-sa/4.0", "rights" => "Creative Commons Attribution-NonCommercial-ShareAlike" }]
      expect(subject.valid?).to be true
      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.dig("rightsList", "rights")).to eq("Creative Commons Attribution-NonCommercial-ShareAlike")
    end

    it "change license url" do
      input = "10.7554/eLife.01567"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      subject.rights_list = [{ "rightsUri" => "https://creativecommons.org/licenses/by-nc-sa/4.0" }]
      expect(subject.valid?).to be true
      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.dig("rightsList", "rights")).to eq("rightsURI"=>"https://creativecommons.org/licenses/by-nc-sa/4.0")
    end

    it "change license name" do
      input = "10.7554/eLife.01567"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      subject.rights_list = [{ "rights" => "Creative Commons Attribution-NonCommercial-ShareAlike" }]
      expect(subject.valid?).to be true
      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.dig("rightsList", "rights")).to eq("Creative Commons Attribution-NonCommercial-ShareAlike")
    end

    it "change state" do
      input = "10.7554/eLife.01567"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      expect(subject.valid?).to be true
      expect(subject.state).to eq("findable")
      subject.state = "registered"
      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.dig("identifier", "__content__")).to eq("10.7554/elife.01567")
      expect(subject.state).to eq("registered")
    end

    it "change identifiers" do
      input = "10.7554/eLife.01567"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      expect(subject.valid?).to be true
      expect(subject.identifiers).to eq([{"identifier"=>"e01567", "identifierType"=>"article_number"}])
      subject.identifiers = [{ "identifierType" => "article_number", "identifier" => "abc" }]
      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.dig("identifier", "__content__")).to eq("10.7554/elife.01567")
      expect(subject.identifiers).to eq([{"identifier"=>"abc", "identifierType"=>"article_number"}])
    end

    it "validates against schema" do
      input = "10.7554/eLife.01567"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      subject.doi = "123"
      subject.titles = "Data from: Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth"
      subject.types = { "schemaOrg" => "Dataset", "resourceTypeGeneral" => "Dataset" }
      expect(subject.doi).to eq("123")
      expect(subject.valid?).to be true
    end

    it "from schema_org gtex" do
      input = fixture_path + "schema_org_gtex.json"
      subject = Bolognese::Metadata.new(input: input, from: "schema_org")
      expect(subject.valid?).to be true
      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.dig("identifier", "__content__")).to eq("10.25491/d50j-3083")
      expect(datacite.dig("creators", "creator").count).to eq(1)
      expect(datacite.dig("creators", "creator")).to eq("creatorName"=>{"__content__"=>"The GTEx Consortium", "nameType"=>"Organizational"})
      expect(datacite.dig("resourceType", "resourceTypeGeneral")).to eq("Dataset")
      expect(datacite.dig("resourceType", "__content__")).to eq("Gene expression matrices")
      expect(datacite.dig("titles", "title")).to eq("Fully processed, filtered and normalized gene expression matrices (in BED format) for each tissue, which were used as input into FastQTL for eQTL discovery")
      expect(datacite.dig("version")).to eq("v7")
      expect(datacite.dig("publisher")).to eq("GTEx")
      expect(datacite.dig("descriptions", "description")).to eq("__content__"=>"GTEx", "descriptionType"=>"SeriesInformation")
      expect(datacite.dig("publicationYear")).to eq("2017")
      expect(datacite.dig("dates", "date")).to eq("__content__"=>"2017", "dateType"=>"Issued")
      expect(datacite.dig("subjects", "subject")).to eq(["gtex", "annotation", "phenotype", "gene regulation", "transcriptomics"])
      expect(datacite.dig("alternateIdentifiers", "alternateIdentifier")).to eq("__content__"=>"687610993", "alternateIdentifierType"=>"md5")
      expect(datacite.dig("fundingReferences", "fundingReference").count).to eq(7)
      expect(datacite.dig("fundingReferences", "fundingReference").last).to eq("funderIdentifier" => {"__content__"=>"https://doi.org/10.13039/100000065", "funderIdentifierType"=>"Crossref Funder ID"},"funderName" => "National Institute of Neurological Disorders and Stroke (NINDS)")
    end
  end
end
