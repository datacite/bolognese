# frozen_string_literal: true

require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  let(:input) { "10.7554/eLife.01567" }

  subject { Bolognese::Metadata.new(input: input) }

  context "get crossref raw" do
    it "journal article" do
      input = fixture_path + 'crossref.xml'
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.raw).to eq(IO.read(input).strip)
    end
  end

  context "get crossref metadata" do
    it "DOI with data citation" do
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.7554/elife.01567")
      expect(subject.identifiers).to eq([{"identifier"=>"e01567", "identifierType"=>"article_number"}])
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"JournalArticle", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.url).to eq("https://elifesciences.org/articles/01567")
      expect(subject.creators.length).to eq(5)
      expect(subject.creators.first).to eq("nameType"=>"Personal", "name"=>"Sankar, Martial", "givenName"=>"Martial", "familyName"=>"Sankar", "affiliation" => [{"name"=>"Department of Plant Molecular Biology, University of Lausanne, Lausanne, Switzerland"}])
      expect(subject.rights_list).to eq([{"rights"=>"Creative Commons Attribution 3.0 Unported",
        "rightsIdentifier"=>"cc-by-3.0",
        "rightsIdentifierScheme"=>"SPDX",
        "rightsUri"=>"https://creativecommons.org/licenses/by/3.0/legalcode",
        "schemeUri"=>"https://spdx.org/licenses/"}])
      expect(subject.titles).to eq([{"title"=>"Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth"}])
      expect(subject.dates).to eq([{"date"=>"2014-02-11", "dateType"=>"Issued"}, {"date"=>"2018-08-23T09:41:49Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2014")
      expect(subject.publisher).to eq({"name"=>"eLife Sciences Publications, Ltd"})
      expect(subject.container).to eq("firstPage" => "e01567", "identifier"=>"2050-084X", "identifierType"=>"ISSN", "title"=>"eLife", "type"=>"Journal", "volume"=>"3")
      expect(subject.related_identifiers.length).to eq(27)
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"2050-084X", "relatedIdentifierType"=>"ISSN", "relationType"=>"IsPartOf", "resourceTypeGeneral"=>"Collection")
      expect(subject.related_identifiers.last).to eq("relatedIdentifier"=>"10.1038/ncb2764", "relatedIdentifierType"=>"DOI", "relationType"=>"References")
      expect(subject.funding_references).to eq([{"funderName"=>"SystemsX"},
        {"funderIdentifier"=>"https://doi.org/10.13039/501100003043",
         "funderIdentifierType"=>"Crossref Funder ID",
         "funderName"=>"EMBO"},
        {"funderIdentifier"=>"https://doi.org/10.13039/501100001711",
         "funderIdentifierType"=>"Crossref Funder ID",
         "funderName"=>"Swiss National Science Foundation"},
        {"funderIdentifier"=>"https://doi.org/10.13039/501100006390",
         "funderIdentifierType"=>"Crossref Funder ID",
         "funderName"=>"University of Lausanne"}])
      expect(subject.agency).to eq("crossref")
    end

    it "journal article" do
      input = "https://doi.org/10.1371/journal.pone.0000030"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1371/journal.pone.0000030")
      expect(subject.identifiers).to eq([{"identifier"=>"10.1371/journal.pone.0000030", "identifierType"=>"Publisher ID"}])
      expect(subject.url).to eq("https://dx.plos.org/10.1371/journal.pone.0000030")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"JournalArticle", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.length).to eq(5)
      expect(subject.creators.first).to eq("nameType"=>"Personal", "name"=>"Ralser, Markus", "givenName"=>"Markus", "familyName"=>"Ralser")
      expect(subject.contributors).to eq([{"contributorType"=>"Editor", "familyName"=>"Janbon", "givenName"=>"Guilhem", "name"=>"Janbon, Guilhem", "nameType"=>"Personal"}])
      expect(subject.titles).to eq([{"title"=>"Triose Phosphate Isomerase Deficiency Is Caused by Altered Dimerization???Not Catalytic Inactivity???of the Mutant Enzymes"}])
      expect(subject.rights_list).to eq([{"rights"=>"Creative Commons Attribution 4.0 International",
        "rightsIdentifier"=>"cc-by-4.0",
        "rightsIdentifierScheme"=>"SPDX",
        "rightsUri"=>"https://creativecommons.org/licenses/by/4.0/legalcode",
        "schemeUri"=>"https://spdx.org/licenses/"}])
      expect(subject.dates).to eq([{"date"=>"2006-12-20", "dateType"=>"Issued"}, {"date"=>"2020-05-09T09:35:17Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2006")
      expect(subject.publisher).to eq({"name"=>"Public Library of Science (PLoS)"})
      expect(subject.related_identifiers.length).to eq(64)
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"1932-6203", "relatedIdentifierType"=>"ISSN", "relationType"=>"IsPartOf", "resourceTypeGeneral"=>"Collection")
      expect(subject.related_identifiers.last).to eq("relatedIdentifier"=>"10.1056/nejm199109123251104", "relatedIdentifierType"=>"DOI", "relationType"=>"References")
      expect(subject.container).to eq("firstPage"=>"e30", "identifier"=>"1932-6203", "identifierType"=>"ISSN", "issue"=>"1", "title"=>"PLoS ONE", "type"=>"Journal", "volume"=>"1")
      expect(subject.agency).to eq("crossref")
    end

    it "journal article with funding" do
      input = "https://doi.org/10.3389/fpls.2019.00816"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.3389/fpls.2019.00816")
      expect(subject.identifiers).to eq([{"identifier"=>"816", "identifierType"=>"article_number"}])
      expect(subject.url).to eq("https://www.frontiersin.org/article/10.3389/fpls.2019.00816/full")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"JournalArticle", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.length).to eq(4)
      expect(subject.creators.first).to eq("familyName"=>"Fortes", "givenName"=>"Ana Margarida", "name"=>"Fortes, Ana Margarida", "nameType"=>"Personal")
      expect(subject.titles).to eq([{"title"=>"Transcriptional Modulation of Polyamine Metabolism in Fruit Species Under Abiotic and Biotic Stress"}])
      expect(subject.rights_list).to eq([{"rights"=>"Creative Commons Attribution 4.0 International",
        "rightsIdentifier"=>"cc-by-4.0",
        "rightsIdentifierScheme"=>"SPDX",
        "rightsUri"=>"https://creativecommons.org/licenses/by/4.0/legalcode",
        "schemeUri"=>"https://spdx.org/licenses/"}])
      expect(subject.dates).to eq([{"date"=>"2019-07-02", "dateType"=>"Issued"}, {"date"=>"2019-09-22T06:40:23Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2019")
      expect(subject.publisher).to eq({"name"=>"Frontiers Media SA"})
      expect(subject.funding_references).to eq([{"awardNumber"=>"CA17111", "funderIdentifier"=>"https://doi.org/10.13039/501100000921", "funderIdentifierType"=>"Crossref Funder ID", "funderName"=>"COST (European Cooperation in Science and Technology)"}])
      expect(subject.related_identifiers.length).to eq(70)
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"1664-462X", "relatedIdentifierType"=>"ISSN", "relationType"=>"IsPartOf", "resourceTypeGeneral"=>"Collection")
      expect(subject.related_identifiers.last).to eq("relatedIdentifier"=>"10.17660/actahortic.2004.632.41", "relatedIdentifierType"=>"DOI", "relationType"=>"References")
      expect(subject.container).to eq("firstPage" => "816", "identifier"=>"1664-462X", "identifierType"=>"ISSN", "title"=>"Frontiers in Plant Science", "type"=>"Journal", "volume"=>"10")
      expect(subject.agency).to eq("crossref")
    end

    it "journal article original language title" do
      input = "https://doi.org/10.7600/jspfsm.56.60"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.7600/jspfsm.56.60")
      expect(subject.url).to eq("https://www.jstage.jst.go.jp/article/jspfsm/56/1/56_1_60/_article/-char/ja/")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"JournalArticle", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators).to eq([{"name"=>":(unav)", "nameType"=>"Organizational"}])
      expect(subject.titles).to eq([{"lang"=>"ja", "title"=>"??????????????????????????????"}])
      expect(subject.dates).to include({"date"=>"2007", "dateType"=>"Issued"})
      expect(subject.publication_year).to eq("2007")
      expect(subject.publisher).to eq({"name"=>"The Japanese Society of Physical Fitness and Sports Medicine"})
      expect(subject.related_identifiers.length).to eq(1)
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"1881-4751", "relatedIdentifierType"=>"ISSN", "relationType"=>"IsPartOf", "resourceTypeGeneral"=>"Collection")
      expect(subject.container).to eq("firstPage"=>"60", "identifier"=>"1881-4751", "identifierType"=>"ISSN", "issue"=>"1", "lastPage"=>"60", "title"=>"Japanese Journal of Physical Fitness and Sports Medicine", "type"=>"Journal", "volume"=>"56")
      expect(subject.agency).to eq("crossref")
    end

    it "journal article with RDF for container" do
      input = "https://doi.org/10.1163/1937240X-00002096"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1163/1937240x-00002096")
      expect(subject.url).to eq("https://academic.oup.com/jcb/article-lookup/doi/10.1163/1937240X-00002096")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"JournalArticle", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.length).to eq(8)
      expect(subject.creators.first).to eq("familyName"=>"Mesquita-Joanes", "givenName"=>"Francesc", "name"=>"Mesquita-Joanes, Francesc", "nameType"=>"Personal")
      expect(subject.titles).to eq([{"title"=>"Global distribution of Fabaeformiscandona subacuta: an??exotic??invasive Ostracoda on the Iberian Peninsula?"}])
      expect(subject.dates).to include({"date"=>"2012-01-01", "dateType"=>"Issued"})
      expect(subject.publication_year).to eq("2012")
      expect(subject.publisher).to eq({"name"=>"Oxford University Press (OUP)"})
      expect(subject.related_identifiers.length).to eq(44)
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"1937-240X", "relatedIdentifierType"=>"ISSN", "relationType"=>"IsPartOf", "resourceTypeGeneral"=>"Collection")
      expect(subject.related_identifiers.last).to eq("relatedIdentifier"=>"10.1002/aqc.1122", "relatedIdentifierType"=>"DOI", "relationType"=>"References")
      expect(subject.container).to eq("firstPage"=>"949", "identifier"=>"1937-240X", "identifierType"=>"ISSN", "issue"=>"6", "lastPage"=>"961", "title"=>"Journal of Crustacean Biology", "type"=>"Journal", "volume"=>"32")
      expect(subject.agency).to eq("crossref")
    end

    it "book chapter with RDF for container" do
      input = "10.1007/978-3-642-33191-6_49"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1007/978-3-642-33191-6_49")
      expect(subject.url).to eq("http://link.springer.com/10.1007/978-3-642-33191-6_49")
      expect(subject.types).to eq("bibtex"=>"inbook", "citeproc"=>"chapter", "resourceType"=>"BookChapter", "resourceTypeGeneral"=>"BookChapter", "ris"=>"CHAP", "schemaOrg"=>"Chapter")
      expect(subject.creators.length).to eq(3)
      expect(subject.creators.first).to eq("familyName"=>"Chen", "givenName"=>"Lili", "name"=>"Chen, Lili", "nameType"=>"Personal")
      expect(subject.titles).to eq([{"title"=>"Human Body Orientation Estimation in Multiview Scenarios"}])
      expect(subject.dates).to eq([{"date"=>"2012", "dateType"=>"Issued"}, {"date"=>"2020-11-24T03:11:32Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2012")
      expect(subject.publisher).to eq({"name"=>"Springer Science and Business Media LLC"})
      expect(subject.related_identifiers.length).to eq(7)
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"10.1007/978-3-540-24670-1_3", "relatedIdentifierType"=>"DOI", "relationType"=>"References")
      expect(subject.container).to eq("identifier"=>"1611-3349", "identifierType"=>"ISSN", "title"=>"Lecture Notes in Computer Science", "type"=>"Book Series")
      expect(subject.agency).to eq("crossref")
    end

    it "posted_content" do
      input = "https://doi.org/10.1101/097196"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.url).to eq("http://biorxiv.org/lookup/doi/10.1101/097196")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"PostedContent", "resourceTypeGeneral"=>"JournalArticle", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.count).to eq(11)
      expect(subject.creators.last).to eq("nameType"=>"Personal", "nameIdentifiers" => [{"nameIdentifier"=>"https://orcid.org/0000-0003-4060-7360", "nameIdentifierScheme"=>"ORCID", "schemeUri"=>"https://orcid.org"}], "name"=>"Clark, Timothy", "givenName"=>"Timothy", "familyName"=>"Clark")
      expect(subject.titles).to eq([{"title"=>"A Data Citation Roadmap for Scholarly Data Repositories"}])
      expect(subject.id).to eq("https://doi.org/10.1101/097196")
      expect(subject.identifiers).to eq([{"identifier"=>"biorxiv;097196v2", "identifierType"=>"Publisher ID"}])
      expect(subject.descriptions.first["description"]).to start_with("This article presents a practical roadmap")
      expect(subject.dates).to include({"date"=>"2017-10-09", "dateType"=>"Issued"})
      expect(subject.publication_year).to eq("2017")
      expect(subject.publisher).to eq({"name"=>"Cold Spring Harbor Laboratory"})
      expect(subject.agency).to eq("crossref")
    end

    it "peer review" do
      input = "https://doi.org/10.7554/elife.55167.sa2"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.url).to eq("https://elifesciences.org/articles/55167#sa2")
      expect(subject.types).to eq("bibtex"=>"misc", "citeproc"=>"article-journal", "resourceType"=>"PeerReview", "resourceTypeGeneral"=>"PeerReview", "ris"=>"JOUR", "schemaOrg"=>"Review")
      expect(subject.creators.count).to eq(8)
      expect(subject.creators.last).to eq("affiliation" => [{"name"=>"Center for Computational Mathematics, Flatiron Institute, New York, United States"}],
        "familyName" => "Barnett",
        "givenName" => "Alex H",
        "name" => "Barnett, Alex H",
        "nameType" => "Personal")
      expect(subject.titles).to eq([{"title"=>"Author response: SpikeForest, reproducible web-facing ground-truth validation of automated neural spike sorters"}])
      expect(subject.id).to eq("https://doi.org/10.7554/elife.55167.sa2")
      expect(subject.identifiers).to be_empty
      expect(subject.descriptions).to be_empty
      expect(subject.dates).to include({"date"=>"2020-05-19", "dateType"=>"Issued"})
      expect(subject.publication_year).to eq("2020")
      expect(subject.publisher).to eq({"name"=>"eLife Sciences Publications, Ltd"})
      expect(subject.agency).to eq("crossref")
    end

    it "dissertation" do
      input = "https://doi.org/10.14264/uql.2020.791"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.url).to eq("http://espace.library.uq.edu.au/view/UQ:23a1e74")
      expect(subject.types).to eq("bibtex"=>"phdthesis", "citeproc"=>"thesis", "resourceType"=>"Dissertation", "resourceTypeGeneral"=>"Dissertation", "ris"=>"THES", "schemaOrg"=>"Thesis")
      expect(subject.creators).to eq([{"familyName"=>"Collingwood",
        "givenName"=>"Patricia Maree",
        "name"=>"Collingwood, Patricia Maree",
        "nameIdentifiers"=>
          [{"nameIdentifier"=>"https://orcid.org/0000-0003-3086-4443",
            "nameIdentifierScheme"=>"ORCID",
           "schemeUri"=>"https://orcid.org"}],
           "nameType"=>"Personal"}])
      expect(subject.titles).to eq([{"title"=>"School truancy and financial independence during emerging adulthood: a longitudinal analysis of receipt of and reliance on cash transfers"}])
      expect(subject.id).to eq("https://doi.org/10.14264/uql.2020.791")
      expect(subject.identifiers).to be_empty
      expect(subject.descriptions).to be_empty
      expect(subject.dates).to include({"date"=>"2020-06-08", "dateType"=>"Issued"})
      expect(subject.publication_year).to eq("2020")
      expect(subject.publisher).to eq({"name"=>"University of Queensland Library"})
      expect(subject.agency).to eq("crossref")
    end

    it "DOI with SICI DOI" do
      input = "https://doi.org/10.1890/0012-9658(2006)87[2832:tiopma]2.0.co;2"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1890/0012-9658(2006)87%255b2832:tiopma%255d2.0.co;2")
      expect(subject.url).to eq("http://doi.wiley.com/10.1890/0012-9658(2006)87[2832:TIOPMA]2.0.CO;2")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"JournalArticle", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators).to eq([{"nameType"=>"Personal", "name"=>"Fenton, A.", "givenName"=>"A.", "familyName"=>"Fenton"}, {"nameType"=>"Personal", "name"=>"Rands, S. A.", "givenName"=>"S. A.", "familyName"=>"Rands"}])
      expect(subject.rights_list).to eq([{"rightsUri"=>"http://doi.wiley.com/10.1002/tdm_license_1.1"}])
      expect(subject.titles).to eq([{"title"=>"THE IMPACT OF PARASITE MANIPULATION AND PREDATOR FORAGING BEHAVIOR ON PREDATOR???PREY COMMUNITIES"}])
      expect(subject.dates).to eq([{"date"=>"2006-11", "dateType"=>"Issued"}, {"date"=>"2019-04-28T17:51:50Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2006")
      expect(subject.publisher).to eq({"name"=>"Wiley"})
      expect(subject.related_identifiers.length).to eq(35)
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"0012-9658", "relatedIdentifierType"=>"ISSN", "relationType"=>"IsPartOf", "resourceTypeGeneral"=>"Collection")
      expect(subject.related_identifiers.last).to eq("relatedIdentifier"=>"10.1098/rspb.2002.2213", "relatedIdentifierType"=>"DOI", "relationType"=>"References")
      expect(subject.container).to eq("firstPage"=>"2832", "identifier"=>"0012-9658", "identifierType"=>"ISSN", "issue"=>"11", "lastPage"=>"2841", "title"=>"Ecology", "type"=>"Journal", "volume"=>"87")
      expect(subject.agency).to eq("crossref")
    end

    it "DOI with ORCID ID" do
      input = "https://doi.org/10.1155/2012/291294"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1155/2012/291294")
      expect(subject.url).to eq("http://www.hindawi.com/journals/pm/2012/291294/")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"JournalArticle", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.length).to eq(7)
      expect(subject.creators[2]).to eq("nameType"=>"Personal", "nameIdentifiers" => [{"nameIdentifier"=>"https://orcid.org/0000-0003-2043-4925", "nameIdentifierScheme"=>"ORCID", "schemeUri"=>"https://orcid.org"}], "name"=>"Hernandez, Beatriz", "givenName"=>"Beatriz", "familyName"=>"Hernandez", "affiliation" => [{"name"=>"War Related Illness and Injury Study Center (WRIISC) and Mental Illness Research Education and Clinical Center (MIRECC), Department of Veterans Affairs, Palo Alto, CA 94304, USA"}, {"name"=>"Department of Psychiatry and Behavioral Sciences, Stanford University School of Medicine, Stanford, CA 94304, USA"}])
      expect(subject.rights_list).to eq([{"rights"=>"Creative Commons Attribution 3.0 Unported",
        "rightsIdentifier"=>"cc-by-3.0",
        "rightsIdentifierScheme"=>"SPDX",
        "rightsUri"=>"https://creativecommons.org/licenses/by/3.0/legalcode",
        "schemeUri"=>"https://spdx.org/licenses/"}])
      expect(subject.titles).to eq([{"title"=>"Delineating a Retesting Zone Using Receiver Operating Characteristic Analysis on Serial QuantiFERON Tuberculosis Test Results in US Healthcare Workers"}])
      expect(subject.dates).to include({"date"=>"2012", "dateType"=>"Issued"})
      expect(subject.publication_year).to eq("2012")
      expect(subject.publisher).to eq({"name"=>"Hindawi Limited"})
      expect(subject.related_identifiers.length).to eq(18)
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"2090-1844", "relatedIdentifierType"=>"ISSN", "relationType"=>"IsPartOf", "resourceTypeGeneral"=>"Collection")
      expect(subject.related_identifiers.last).to eq("relatedIdentifier"=>"10.1378/chest.12-0045", "relatedIdentifierType"=>"DOI", "relationType"=>"References")
      expect(subject.container).to eq("firstPage"=>"1", "identifier"=>"2090-1844", "identifierType"=>"ISSN", "lastPage"=>"7", "title"=>"Pulmonary Medicine", "type"=>"Journal", "volume"=>"2012")
      expect(subject.agency).to eq("crossref")
    end

    it "date in future" do
      input = "https://doi.org/10.1016/j.ejphar.2015.03.018"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1016/j.ejphar.2015.03.018")
      expect(subject.identifiers).to eq([{"identifier"=>"S0014299915002332", "identifierType"=>"sequence-number"}])
      expect(subject.url).to eq("https://linkinghub.elsevier.com/retrieve/pii/S0014299915002332")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"JournalArticle", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.length).to eq(10)
      expect(subject.creators.first).to eq("nameType"=>"Personal", "name"=>"Beck, Sarah E.", "givenName"=>"Sarah E.", "familyName"=>"Beck")
      expect(subject.titles).to eq([{"title"=>"Paving the path to HIV neurotherapy: Predicting SIV CNS disease"}])
      expect(subject.dates).to include({"date"=>"2015-07", "dateType"=>"Issued"})
      expect(subject.publication_year).to eq("2015")
      expect(subject.publisher).to eq({"name"=>"Elsevier BV"})
      expect(subject.related_identifiers).to eq([{"relatedIdentifier"=>"0014-2999", "relatedIdentifierType"=>"ISSN", "relationType"=>"IsPartOf", "resourceTypeGeneral"=>"Collection"},
        {"relatedIdentifier"=>"10.1212/01.wnl.0000287431.88658.8b",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1182/blood-2010-09-308684",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1007/s13365-015-0313-7",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1016/j.jneuroim.2006.04.017",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1086/514001",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1002/ana.410310403",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1093/infdis/jir214",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1097/qad.0b013e32836010bd",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1261/rna.036863.112",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.4103/0019-5359.107389",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.3233/jad-2008-14103",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1126/science.287.5455.959",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1097/01.qai.0000165799.59322.f5",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1002/ana.410420503",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1089/ars.2012.4834",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1111/j.1600-0404.1987.tb05458.x",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1097/00002030-198905000-00006",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1002/ana.410200304",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1186/1742-6405-2-6",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1111/j.1600-0684.1993.tb00649.x",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1186/1742-6405-7-15",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1212/wnl.0b013e318200d727",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1089/aid.2006.0292",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1126/science.3646751",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1002/ajmg.b.32071",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1186/1756-6606-6-40",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1086/344938",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1128/jvi.71.8.6055-6060.1997",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1016/j.jneuroim.2004.08.031",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1371/journal.pone.0003603",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1093/jnen/61.1.85",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1097/qad.0b013e32832c4af0",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.3389/fgene.2013.00083",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1080/13550280390194109",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1002/ana.410420504",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1001/archneur.61.11.1687",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1212/01.wnl.0000277635.05973.55",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1038/nmeth.3014",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1097/qai.0000000000000048",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1093/infdis/jit278",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1007/s13365-014-0283-1",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1097/00002030-199905280-00010",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1097/qco.0b013e32834ef586",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.4049/jimmunol.169.6.3438",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.2174/1389200024605082",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1126/science.1546323",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1016/s1474-4422(14)70137-1",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1016/j.jns.2009.06.043",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1128/jvi.77.16.9029-9040.2003",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1002/jcp.24254",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1128/jvi.76.1.292-302.2002",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1182/blood-2012-03-414706",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1016/j.jneuroim.2013.11.004",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1038/nrg3198",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1016/s0140-6736(96)10178-1",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1128/jvi.00366-11",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1007/s13365-011-0053-2",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1083/jcb.201211138",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1111/j.1600-0684.2011.00475.x",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1038/srep05915",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1096/fj.09-143503",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1542/peds.111.2.e168",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.2174/1566524013363555",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1126/science.283.5403.857",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1212/01.wnl.0000145763.68284.15",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1002/ana.410230727",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1186/1742-4690-10-95",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1128/jvi.79.2.684-695.2005",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1111/j.1600-0684.2005.00126.x",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1186/1756-8722-6-6",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1016/j.jmb.2013.12.017",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1590/s0037-86822012000600002",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1080/13550280390218715",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1111/j.1468-1331.2012.03777.x",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.3233/jad-2010-090649",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1080/13550280500516484",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1080/13550280390218751",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1189/jlb.0811394",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1007/s11481-011-9330-3",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1080/13550280802074539",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1086/650743",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1371/journal.pone.0008129",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1128/jvi.80.10.5074-5077.2006",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1186/1742-2094-10-62",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1086/323478",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1128/jvi.73.12.10480-10488.1999",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"},
        {"relatedIdentifier"=>"10.1111/hiv.12134",
         "relatedIdentifierType"=>"DOI",
         "relationType"=>"References"}])
      expect(subject.container).to eq("firstPage"=>"303", "identifier"=>"0014-2999", "identifierType"=>"ISSN", "lastPage"=>"312", "title"=>"European Journal of Pharmacology", "type"=>"Journal", "volume"=>"759")
      expect(subject.agency).to eq("crossref")
    end

    it "vor with url" do
      input = "https://doi.org/10.1038/hdy.2013.26"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1038/hdy.2013.26")
      expect(subject.url).to eq("http://www.nature.com/articles/hdy201326")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"JournalArticle", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.length).to eq(2)
      expect(subject.creators.first).to eq("familyName"=>"Gross", "givenName"=>"J B", "name"=>"Gross, J B", "nameType"=>"Personal")
      expect(subject.titles).to eq([{"title"=>"Albinism in phylogenetically and geographically distinct populations of Astyanax cavefish arises through the same loss-of-function Oca2 allele"}])
      expect(subject.dates).to include({"date"=>"2013-04-10", "dateType"=>"Issued"})
      expect(subject.publication_year).to eq("2013")
      expect(subject.publisher).to eq({"name"=>"Springer Science and Business Media LLC"})
      expect(subject.related_identifiers.size).to eq(35)
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"1365-2540", "relatedIdentifierType"=>"ISSN", "relationType"=>"IsPartOf", "resourceTypeGeneral"=>"Collection")
      expect(subject.container).to eq("firstPage"=>"122", "identifier"=>"1365-2540", "identifierType"=>"ISSN", "issue"=>"2", "lastPage"=>"130", "title"=>"Heredity", "type"=>"Journal", "volume"=>"111")
      expect(subject.agency).to eq("crossref")
    end

    it "dataset" do
      input = "10.2210/pdb4hhb/pdb"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.2210/pdb4hhb/pdb")
      expect(subject.url).to eq("https://www.wwpdb.org/pdb?id=pdb_00004hhb")
      expect(subject.types).to eq("bibtex"=>"misc", "citeproc"=>"article-journal", "resourceType"=>"SaComponent", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.length).to eq(2)
      expect(subject.creators.first).to eq("nameType"=>"Personal", "name"=>"Fermi, G.", "givenName"=>"G.", "familyName"=>"Fermi")
      expect(subject.titles).to eq([{"title"=>"THE CRYSTAL STRUCTURE OF HUMAN DEOXYHAEMOGLOBIN AT 1.74 ANGSTROMS RESOLUTION"}])
      expect(subject.descriptions).to eq([{"description"=>"x-ray diffraction structure", "descriptionType"=>"Other"}])
      expect(subject.dates).to include({"date"=>"1984-07-17", "dateType"=>"Issued"})
      expect(subject.publication_year).to eq("1984")
      expect(subject.publisher).to eq({"name"=>"Worldwide Protein Data Bank"})
      expect(subject.agency).to eq("crossref")
    end

    it "component" do
      input = "10.1371/journal.pmed.0030277.g001"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1371/journal.pmed.0030277.g001")
      expect(subject.url).to eq("https://dx.plos.org/10.1371/journal.pmed.0030277.g001")
      expect(subject.types).to eq("bibtex"=>"misc", "citeproc"=>"article-journal", "resourceType"=>"SaComponent", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators).to eq([{"name"=>":(unav)", "nameType"=>"Organizational"}])
      expect(subject.titles).to eq([{"title"=>":(unav)"}])
      expect(subject.descriptions).to be_empty
      expect(subject.dates).to eq([{"date"=>"2015-10-20", "dateType"=>"Issued"}, {"date"=>"2018-10-19T21:13:42Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2015")
      expect(subject.publisher).to eq({"name"=>"Public Library of Science (PLoS)"})
      expect(subject.agency).to eq("crossref")
    end

    it "dataset usda" do
      input = "https://doi.org/10.2737/RDS-2018-0001"
      subject = Bolognese::Metadata.new(input: input)
      #expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.2737/rds-2018-0001")
      expect(subject.url).to eq("https://www.fs.usda.gov/rds/archive/Catalog/RDS-2018-0001")
      expect(subject.types).to eq("bibtex"=>"misc", "citeproc"=>"dataset", "resourceType"=>"Dataset", "resourceTypeGeneral"=>"Dataset", "ris"=>"DATA", "schemaOrg"=>"Dataset")
      expect(subject.creators.length).to eq(4)
      expect(subject.creators.first).to eq("familyName" => "Ribic","givenName" => "Christine A.","name" => "Ribic, Christine A.","affiliation" => [{"name"=>"U.S. Geological Survey"}],"nameIdentifiers" => [{"nameIdentifier"=>"https://orcid.org/0000-0003-2583-1778", "nameIdentifierScheme"=>"ORCID", "schemeUri"=>"https://orcid.org"}],"nameType" => "Personal")
      expect(subject.titles).to eq([{"title"=>"Fledging times of grassland birds"}])
      expect(subject.descriptions).to be_empty
      expect(subject.dates).to eq([{"date"=>"2017-08-09", "dateType"=>"Issued"}, {"date"=>"2020-06-04T21:31:55Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2017")
      expect(subject.publisher).to eq({"name"=>"USDA Forest Service"})
      expect(subject.agency).to eq("crossref")
    end

    it "book chapter" do
      input = "https://doi.org/10.1007/978-3-662-46370-3_13"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1007/978-3-662-46370-3_13")
      expect(subject.url).to eq("http://link.springer.com/10.1007/978-3-662-46370-3_13")
      expect(subject.types).to eq("bibtex"=>"inbook", "citeproc"=>"chapter", "resourceType"=>"BookChapter", "resourceTypeGeneral"=>"BookChapter", "ris"=>"CHAP", "schemaOrg"=>"Chapter")
      expect(subject.creators.length).to eq(2)
      expect(subject.creators.first).to eq("nameType"=>"Personal", "name"=>"Diercks, Ronald L.", "givenName"=>"Ronald L.", "familyName"=>"Diercks")
      expect(subject.titles).to eq([{"title"=>"Clinical Symptoms and Physical Examinations"}])
      expect(subject.dates).to eq([{"date"=>"2015", "dateType"=>"Issued"}, {"date"=>"2015-04-14T02:31:13Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2015")
      expect(subject.publisher).to eq({"name"=>"Springer Science and Business Media LLC"})
      expect(subject.agency).to eq("crossref")
      expect(subject.container["type"]).to eq("Book")
      expect(subject.container["title"]).to eq("Shoulder Stiffness")
      expect(subject.container["firstPage"]).to eq("155")
      expect(subject.container["lastPage"]).to eq("158")
      expect(subject.container["identifiers"]).to eq([{"identifier"=>"978-3-662-46369-7", "identifierType"=>"ISBN"}])
    end

    it "another book chapter" do
      input = "https://doi.org/10.1007/978-3-319-75889-3_1"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1007/978-3-319-75889-3_1")
      expect(subject.url).to eq("http://link.springer.com/10.1007/978-3-319-75889-3_1")
      expect(subject.types).to eq("bibtex"=>"inbook", "citeproc"=>"chapter", "resourceType"=>"BookChapter", "resourceTypeGeneral"=>"BookChapter", "ris"=>"CHAP", "schemaOrg"=>"Chapter")
      expect(subject.creators).to eq([{"familyName"=>"Jones", "givenName"=>"Hunter M.", "name"=>"Jones, Hunter M.", "nameType"=>"Personal"}])
      expect(subject.titles).to eq([{"title"=>"Climate Change and Increasing Risk of Extreme Heat"}])
      expect(subject.dates).to include({"date"=>"2018", "dateType"=>"Issued"})
      expect(subject.publication_year).to eq("2018")
      expect(subject.publisher).to eq({"name"=>"Springer Science and Business Media LLC"})
      expect(subject.agency).to eq("crossref")
      expect(subject.container["type"]).to eq("Book Series")
      expect(subject.container["title"]).to eq("SpringerBriefs in Medical Earth Sciences")
      expect(subject.container["identifier"]).to eq("2523-3629")
      expect(subject.container["identifierType"]).to eq("ISSN")
    end

    it "yet another book chapter" do
      input = "https://doi.org/10.4018/978-1-4666-1891-6.ch004"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.4018/978-1-4666-1891-6.ch004")
      expect(subject.url).to eq("http://services.igi-global.com/resolvedoi/resolve.aspx?doi=10.4018/978-1-4666-1891-6.ch004")
      expect(subject.types).to eq("bibtex"=>"inbook", "citeproc"=>"chapter", "resourceType"=>"BookChapter", "resourceTypeGeneral"=>"BookChapter", "ris"=>"CHAP", "schemaOrg"=>"Chapter")
      expect(subject.creators).to eq([{"affiliation"=>[{"name"=>"Universit?? de Lyon, France"}], "familyName"=>"Bichot", "givenName"=>"Charles-Edmond", "name"=>"Bichot, Charles-Edmond", "nameType"=>"Personal"}])
      expect(subject.titles).to eq([{"title"=>"Unsupervised and Supervised Image Segmentation Using Graph Partitioning"}])
      expect(subject.dates).to eq([{"date"=>"2012-08-08", "dateType"=>"Issued"}, {"date"=>"2019-07-02T17:17:21Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2012")
      expect(subject.publisher).to eq({"name"=>"IGI Global"})
      expect(subject.agency).to eq("crossref")
      expect(subject.container["type"]).to eq("Book")
      expect(subject.container["title"]).to eq("Graph-Based Methods in Computer Vision")
      expect(subject.container["firstPage"]).to eq("72")
      expect(subject.container["lastPage"]).to eq("94")
      expect(subject.container["identifiers"]).to eq([{"identifier"=>"9781466618916", "identifierType"=>"ISBN"}])
    end

    it "missing creator" do
      input = "https://doi.org/10.3390/publications6020015"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.3390/publications6020015")
      expect(subject.url).to eq("http://www.mdpi.com/2304-6775/6/2/15")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"JournalArticle", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators).to eq([{"name"=>"Alexander Kohls", "nameType"=>"Organizational"}, {"name"=>"Salvatore Mele", "nameType"=>"Organizational"}])
      expect(subject.titles).to eq([{"title"=>"Converting the Literature of a Scientific Field to Open Access through Global Collaboration: The Experience of SCOAP3 in Particle Physics"}])
      expect(subject.dates).to eq([{"date"=>"2018-04-09", "dateType"=>"Issued"}, {"date"=>"2018-04-10T17:58:05Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2018")
      expect(subject.publisher).to eq({"name"=>"MDPI AG"})
      expect(subject.agency).to eq("crossref")
    end

    it "book" do
      input = "https://doi.org/10.1017/9781108348843"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1017/9781108348843")
      expect(subject.identifiers).to eq([{"identifier"=>"9781108348843", "identifierType"=>"ISBN"}])
      expect(subject.url).to eq("https://www.cambridge.org/core/product/identifier/9781108348843/type/book")
      expect(subject.types).to eq("bibtex"=>"book", "citeproc"=>"book", "resourceType"=>"Book", "resourceTypeGeneral"=>"Book", "ris"=>"BOOK", "schemaOrg"=>"Book")
      expect(subject.creators).to eq([{"familyName"=>"Leung", "givenName"=>"Vincent S.", "name"=>"Leung, Vincent S.", "nameType"=>"Personal"}])
      expect(subject.titles).to eq([{"title"=>"The Politics of the Past in Early China"}])
      expect(subject.dates).to eq([{"date"=>"2019-07-01", "dateType"=>"Issued"}, {"date"=>"2021-01-08T19:18:57Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2019")
      expect(subject.publisher).to eq({"name"=>"Cambridge University Press (CUP)"})
      expect(subject.agency).to eq("crossref")
      expect(subject.date_registered).to eq("2019-07-06T10:19:22Z")
    end

    it "another book" do
      input = "https://doi.org/10.2973/odp.proc.ir.180.2000"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.2973/odp.proc.ir.180.2000")
      expect(subject.url).to eq("http://www-odp.tamu.edu/publications/180_IR/180TOC.HTM")
      expect(subject.types).to eq("bibtex"=>"book", "citeproc"=>"book", "resourceType"=>"Book", "resourceTypeGeneral"=>"Book", "ris"=>"BOOK", "schemaOrg"=>"Book")
      expect(subject.creators).to eq([{"name"=>":(unav)", "nameType"=>"Organizational"}])
      expect(subject.contributors.size).to eq(4)
      expect(subject.contributors.first).to eq("contributorType"=>"Editor", "familyName"=>"Taylor", "givenName"=>"B.", "name"=>"Taylor, B.", "nameType"=>"Personal")
      expect(subject.titles).to eq([{"title"=>"Proceedings of the Ocean Drilling Program, 180 Initial Reports"}])
      expect(subject.dates).to eq([{"date"=>"2000-02-04", "dateType"=>"Issued"}, {"date"=>"2009-02-02T21:19:43Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2000")
      expect(subject.publisher).to eq({"name"=>"International Ocean Discovery Program (IODP)"})
      expect(subject.agency).to eq("crossref")
      expect(subject.date_registered).to eq("2006-10-17T20:17:44Z")
    end

    it "yet another book" do
      input = "https://doi.org/10.1029/ar035"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1029/ar035")
      expect(subject.identifiers).to eq([{"identifier"=>"0-87590-181-6", "identifierType"=>"ISBN"}])
      expect(subject.url).to eq("http://doi.wiley.com/10.1029/AR035")
      expect(subject.types).to eq("bibtex"=>"book", "citeproc"=>"book", "resourceType"=>"Book", "resourceTypeGeneral"=>"Book", "ris"=>"BOOK", "schemaOrg"=>"Book")
      expect(subject.creators).to eq([{"familyName"=>"McGinnis", "givenName"=>"Richard Frank", "name"=>"McGinnis, Richard Frank", "nameType"=>"Personal"}])
      expect(subject.titles).to eq([{"title"=>"Biogeography of Lanternfishes (Myctophidae) South of 30??S"}])
      expect(subject.dates).to eq([{"date"=>"1982", "dateType"=>"Issued"}, {"date"=>"2021-02-23T21:58:36Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("1982")
      expect(subject.publisher).to eq({"name"=>"Wiley"})
      expect(subject.related_identifiers.length).to eq(44)
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"10.1016/0031-0182(70)90103-3", "relatedIdentifierType"=>"DOI", "relationType"=>"References")
      expect(subject.container).to eq("identifier"=>"0066-4634", "identifierType"=>"ISSN", "title"=>"Antarctic Research Series", "type"=>"Book Series", "volume"=>"35")
      expect(subject.agency).to eq("crossref")
      expect(subject.date_registered).to be_nil
    end

    it "mEDRA" do
      input = "https://doi.org/10.3280/ecag2018-001005"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.3280/ecag2018-001005")
      expect(subject.identifiers).to eq([{"identifier"=>"5", "identifierType"=>"article_number"}])
      expect(subject.url).to eq("http://www.francoangeli.it/riviste/Scheda_Riviste.asp?IDArticolo=61645")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"JournalArticle", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.length).to eq(2)
      expect(subject.creators.first).to eq("familyName"=>"Oh", "givenName"=>"Sohae Eve", "name"=>"Oh, Sohae Eve", "nameType"=>"Personal")
      expect(subject.titles).to eq([{"title"=>"Substitutability between organic and conventional poultry products and organic price premiums"}])
      expect(subject.dates).to include({"date"=>"2018-05", "dateType"=>"Issued"})
      expect(subject.publication_year).to eq("2018")
      expect(subject.publisher).to eq({"name"=>"Franco Angeli"})
      expect(subject.agency).to eq("mEDRA")
    end

    it "KISTI" do
      input = "https://doi.org/10.5012/bkcs.2013.34.10.2889"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.5012/bkcs.2013.34.10.2889")
      expect(subject.identifiers).to eq([{"identifier"=>"JCGMCS_2013_v34n10_2889", "identifierType"=>"Publisher ID"}])
      expect(subject.url).to eq("http://koreascience.or.kr/journal/view.jsp?kj=JCGMCS&py=2013&vnc=v34n10&sp=2889")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"JournalArticle", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.length).to eq(7)
      expect(subject.creators.first).to eq("familyName"=>"Huang", "givenName"=>"Guimei", "name"=>"Huang, Guimei", "nameType"=>"Personal")
      expect(subject.titles).to eq([{"title"=>"Synthesis, Crystal Structure and Theoretical Calculation of a Novel Nickel(II) Complex with Dibromotyrosine and 1,10-Phenanthroline"}])
      expect(subject.dates).to eq([{"date"=>"2013-10-20", "dateType"=>"Issued"}, {"date"=>"2016-12-15T02:40:52Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2013")
      expect(subject.publisher).to eq({"name"=>"Korean Chemical Society"})
      expect(subject.agency).to eq("KISTI")
    end

    it "JaLC" do
      input = "https://doi.org/10.1241/johokanri.39.979"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1241/johokanri.39.979")
      expect(subject.url).to eq("http://joi.jlc.jst.go.jp/JST.JSTAGE/johokanri/39.979?from=CrossRef")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"JournalArticle", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators).to eq([{"familyName"=>"KUSUMOTO", "givenName"=>"Hiroyuki", "name"=>"KUSUMOTO, Hiroyuki", "nameType"=>"Personal"}])
      expect(subject.titles).to eq([{"title"=>"Utilizing the Internet. 12 Series. Future of the Internet."}])
      expect(subject.dates).to eq([{"date"=>"1997", "dateType"=>"Issued"}, {"date"=>"2020-03-06T06:44:36Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("1997")
      expect(subject.publisher).to eq({"name"=>"Japan Science and Technology Agency (JST)"})
      expect(subject.agency).to eq("JaLC")
    end

    it "OP" do
      input = "https://doi.org/10.2903/j.efsa.2018.5239"
      subject = Bolognese::Metadata.new(input: input)
      #expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.2903/j.efsa.2018.5239")
      expect(subject.url).to eq("http://doi.wiley.com/10.2903/j.efsa.2018.5239")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"JournalArticle", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.length).to eq(28)
      expect(subject.creators.first).to eq("familyName"=>"Younes", "givenName"=>"Maged", "name"=>"Younes, Maged", "nameType"=>"Personal")
      expect(subject.titles).to eq([{"title"=>"Scientific opinion on the safety of green tea catechins"}])
      expect(subject.dates).to include({"date"=>"2018-04", "dateType"=>"Issued"})
      expect(subject.publication_year).to eq("2018")
      expect(subject.publisher).to eq({"name"=>"Wiley"})
      expect(subject.agency).to eq("OP")
    end

    it "multiple titles" do
      input = "https://doi.org/10.4000/dms.865"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.4000/dms.865")
      expect(subject.url).to eq("http://journals.openedition.org/dms/865")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"JournalArticle", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators).to eq([{"familyName"=>"Peraya", "givenName"=>"Daniel", "name"=>"Peraya, Daniel", "nameType"=>"Personal"}])
      expect(subject.titles).to eq([{"title"=>"Distances, absence, proximit??s et pr??sences??: des concepts en d??placement"}, {"title"=>"Distance(s), proximity and presence(s): evolving concepts"}])
      expect(subject.dates).to include({"date"=>"2014-12-14", "dateType"=>"Issued"})
      expect(subject.publication_year).to eq("2014")
      expect(subject.publisher).to eq({"name"=>"OpenEdition"})
      expect(subject.agency).to eq("crossref")
      expect(subject.date_registered).to be_nil
    end

    it "multiple titles with missing" do
      input = "https://doi.org/10.1186/1471-2164-7-187"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1186/1471-2164-7-187")
      expect(subject.url).to eq("https://bmcgenomics.biomedcentral.com/articles/10.1186/1471-2164-7-187")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"JournalArticle", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators).to eq([{"familyName"=>"Myers",
        "givenName"=>"Chad L",
        "name"=>"Myers, Chad L",
        "nameType"=>"Personal"},
       {"familyName"=>"Barrett",
        "givenName"=>"Daniel R",
        "name"=>"Barrett, Daniel R",
        "nameType"=>"Personal"},
       {"familyName"=>"Hibbs",
        "givenName"=>"Matthew A",
        "name"=>"Hibbs, Matthew A",
        "nameType"=>"Personal"},
       {"familyName"=>"Huttenhower",
        "givenName"=>"Curtis",
        "name"=>"Huttenhower, Curtis",
        "nameType"=>"Personal"},
       {"familyName"=>"Troyanskaya",
        "givenName"=>"Olga G",
        "name"=>"Troyanskaya, Olga G",
        "nameType"=>"Personal"}])
      expect(subject.titles).to eq([{"title"=>"Finding function: evaluation methods for functional genomic data"}])
      expect(subject.dates).to include({"date"=>"2006-07-25", "dateType"=>"Issued"})
      expect(subject.publication_year).to eq("2006")
      expect(subject.publisher).to eq({"name"=>"Springer Science and Business Media LLC"})
      expect(subject.agency).to eq("crossref")
      expect(subject.date_registered).to eq("2020-04-20T16:04:45Z")
    end

    it "markup" do
      input = "https://doi.org/10.1098/rspb.2017.0132"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1098/rspb.2017.0132")
      expect(subject.url).to eq("https://royalsocietypublishing.org/doi/10.1098/rspb.2017.0132")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"JournalArticle", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.size).to eq(6)
      expect(subject.creators.first).to eq("affiliation" => [{"name"=>"School of Biological Sciences, Centre for Evolutionary Biology, University of Western Australia, Crawley, WA 6009, Australia"}], "familyName" => "Dougherty","givenName" => "Liam R.","name" => "Dougherty, Liam R.","nameIdentifiers" => [{"nameIdentifier"=>"https://orcid.org/0000-0003-1406-0680", "nameIdentifierScheme"=>"ORCID", "schemeUri"=>"https://orcid.org"}],"nameType"=>"Personal")
      expect(subject.titles).to eq([{"title"=>"Sexual conflict and correlated evolution between male persistence and female resistance traits in the seed beetle <i>Callosobruchus maculatus</i>"}])
      expect(subject.dates).to include({"date"=>"2017-05-24", "dateType"=>"Issued"})
      expect(subject.publication_year).to eq("2017")
      expect(subject.publisher).to eq({"name"=>"The Royal Society"})
      expect(subject.agency).to eq("crossref")
      expect(subject.date_registered).to eq("2021-02-14T10:36:45Z")
    end

    it "empty given name" do
      input = "https://doi.org/10.1111/J.1865-1682.2010.01171.X"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1111/j.1865-1682.2010.01171.x")
      expect(subject.url).to eq("http://doi.wiley.com/10.1111/j.1865-1682.2010.01171.x")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"JournalArticle", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.length).to eq(5)
      expect(subject.creators[3]).to eq("familyName"=>"Ehtisham-ul-Haq", "givenName"=>"???", "name"=>"Ehtisham-ul-Haq, ???", "nameType"=>"Personal")
      expect(subject.titles).to eq([{"title"=>"Serological Evidence of Brucella abortus Prevalence in Punjab Province, Pakistan - A Cross-Sectional Study"}])
      expect(subject.rights_list).to eq([{"rightsUri"=>"http://doi.wiley.com/10.1002/tdm_license_1.1"}])
      expect(subject.dates).to eq([{"date"=>"2010-12", "dateType"=>"Issued"}, {"date"=>"2021-02-04T22:37:42Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2010")
      expect(subject.publisher).to eq({"name"=>"Wiley"})
    end

    it "invalid date" do
      input = "https://doi.org/10.1055/s-0039-1690894"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1055/s-0039-1690894")
      expect(subject.identifiers).to eq([{"identifier"=>"s-0039-1690894", "identifierType"=>"sequence-number"}])
      expect(subject.url).to eq("http://www.thieme-connect.de/DOI/DOI?10.1055/s-0039-1690894")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"JournalArticle", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.length).to eq(4)
      expect(subject.creators[3]).to eq("affiliation" => [{"name"=>"Department of Chemistry, Tianjin Key Laboratory of Molecular Optoelectronic Sciences, and Tianjin Collaborative Innovation Centre of Chemical Science and Engineering, Tianjin University"}, {"name"=>"Joint School of National University of Singapore and Tianjin University, International Campus of Tianjin University"}],
        "familyName" => "Ma",
        "givenName" => "Jun-An",
        "name" => "Ma, Jun-An",
        "nameIdentifiers" => [{"nameIdentifier"=>"https://orcid.org/0000-0002-3902-6799", "nameIdentifierScheme"=>"ORCID", "schemeUri"=>"https://orcid.org"}],
        "nameType" => "Personal")
      expect(subject.titles).to eq([{"title"=>"Silver-Catalyzed [3+3] Annulation of Glycine Imino Esters with Seyferth???Gilbert Reagent To Access Tetrahydro-1,2,4-triazinecarboxylate Esters"}])
      expect(subject.dates).to eq([{"date"=>"2020-04-08", "dateType"=>"Issued"}, {"date"=>"2020-06-16T23:13:36Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2020")
      expect(subject.publisher).to eq({"name"=>"Georg Thieme Verlag KG"})
    end

    it "journal article with" do
      input = "https://doi.org/10.1111/nph.14619"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1111/nph.14619")
      expect(subject.url).to eq("http://doi.wiley.com/10.1111/nph.14619")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"JournalArticle", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.length).to eq(3)
      expect(subject.creators.first).to eq("nameType"=>"Personal", "nameIdentifiers" => [{"nameIdentifier"=>"https://orcid.org/0000-0002-4156-3761", "nameIdentifierScheme"=>"ORCID", "schemeUri"=>"https://orcid.org"}], "name"=>"Dissmeyer, Nico", "givenName"=>"Nico", "familyName"=>"Dissmeyer", "affiliation" => [{"name"=>"Independent Junior Research Group on Protein Recognition and Degradation; Leibniz Institute of Plant Biochemistry (IPB); Weinberg 3 Halle (Saale) D-06120 Germany"}, {"name"=>"ScienceCampus Halle - Plant-based Bioeconomy; Betty-Heimann-Strasse 3 Halle (Saale) D-06120 Germany"}])
      expect(subject.titles).to eq([{"title"=>"Life and death of proteins after protease cleavage: protein degradation by the N-end rule pathway"}])
      expect(subject.rights_list).to eq([{"rightsUri"=>"http://doi.wiley.com/10.1002/tdm_license_1.1"}, {"rightsUri"=>"http://onlinelibrary.wiley.com/termsAndConditions#vor"}])
      expect(subject.dates).to include({"date"=>"2018-05", "dateType"=>"Issued"})
      expect(subject.publication_year).to eq("2018")
      expect(subject.publisher).to eq({"name"=>"Wiley"})
      expect(subject.related_identifiers.length).to eq(49)
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"0028-646X", "relatedIdentifierType"=>"ISSN", "relationType"=>"IsPartOf", "resourceTypeGeneral"=>"Collection")
      expect(subject.related_identifiers.last).to eq("relatedIdentifier"=>"10.1002/pmic.201400530", "relatedIdentifierType"=>"DOI", "relationType"=>"References")
      expect(subject.container).to eq("firstPage"=>"929", "identifier"=>"0028-646X", "identifierType"=>"ISSN", "issue"=>"3", "lastPage"=>"935", "title"=>"New Phytologist", "type"=>"Journal", "volume"=>"218")
      expect(subject.agency).to eq("crossref")
      expect(subject.date_registered).to eq("2018-08-03T11:45:49Z")
    end

    it "author literal" do
      input = "https://doi.org/10.1038/ng.3834"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1038/ng.3834")
      expect(subject.url).to eq("http://www.nature.com/articles/ng.3834")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"JournalArticle", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.length).to eq(14)
      expect(subject.creators.last).to eq("name"=>"GTEx Consortium", "nameType"=>"Organizational")
      expect(subject.titles).to eq([{"title"=>"The impact of structural variation on human gene expression"}])
      expect(subject.dates).to include({"date"=>"2017-04-03", "dateType"=>"Issued"})
      expect(subject.publication_year).to eq("2017")
      expect(subject.publisher).to eq({"name"=>"Springer Science and Business Media LLC"})
      expect(subject.agency).to eq("crossref")
      expect(subject.date_registered).to eq("2019-11-02T09:30:06Z")
    end

    it "affiliation is space" do
      input = "https://doi.org/10.1177/0042098011428175"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1177/0042098011428175")
      expect(subject.url).to eq("http://journals.sagepub.com/doi/10.1177/0042098011428175")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"JournalArticle", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.length).to eq(1)
      expect(subject.creators.first).to eq("affiliation"=>[{"name"=>"??"}], "familyName"=>"Petrovici", "givenName"=>"Norbert", "name"=>"Petrovici, Norbert", "nameType"=>"Personal")
      expect(subject.titles).to eq([{"title"=>"Workers and the City: Rethinking the Geographies of Power in Post-socialist Urbanisation"}])
      expect(subject.dates).to include({"date"=>"2011-12-22", "dateType"=>"Issued"})
      expect(subject.publication_year).to eq("2011")
      expect(subject.publisher).to eq({"name"=>"SAGE Publications"})
      expect(subject.agency).to eq("crossref")
      expect(subject.date_registered).to eq("2021-05-16T02:02:38Z")
    end

    it "multiple issn" do
      input = "https://doi.org/10.1007/978-3-642-34922-5_19"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1007/978-3-642-34922-5_19")
      expect(subject.url).to eq("http://link.springer.com/10.1007/978-3-642-34922-5_19")
      expect(subject.types).to eq("bibtex"=>"inbook", "citeproc"=>"chapter", "resourceType"=>"BookChapter", "resourceTypeGeneral"=>"BookChapter", "ris"=>"CHAP", "schemaOrg"=>"Chapter")
      expect(subject.creators.length).to eq(3)
      expect(subject.creators.first).to eq("familyName"=>"Razib", "givenName"=>"Ali", "name"=>"Razib, Ali", "nameType"=>"Personal")
      expect(subject.titles).to eq([{"title"=>"Log-Domain Arithmetic for High-Speed Fuzzy Control on a Field-Programmable Gate Array"}])
      expect(subject.dates).to include({"date"=>"2013", "dateType"=>"Issued"})
      expect(subject.publication_year).to eq("2013")
      expect(subject.publisher).to eq({"name"=>"Springer Science and Business Media LLC"})
      expect(subject.container).to eq("identifier"=>"1860-0808", "identifierType"=>"ISSN", "title"=>"Studies in Fuzziness and Soft Computing", "type"=>"Book Series")
      expect(subject.agency).to eq("crossref")
      expect(subject.date_registered).to eq("2012-10-31T16:15:44Z")
    end

    it "article id as page number" do
      input = "https://doi.org/10.1103/physrevlett.120.117701"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1103/physrevlett.120.117701")
      expect(subject.url).to eq("https://link.aps.org/doi/10.1103/PhysRevLett.120.117701")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"JournalArticle", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.length).to eq(5)
      expect(subject.creators.first).to eq("familyName"=>"Marrazzo", "givenName"=>"Antimo", "name"=>"Marrazzo, Antimo", "nameType"=>"Personal")
      expect(subject.titles).to eq([{"title"=>"Prediction of a Large-Gap and Switchable Kane-Mele Quantum Spin Hall Insulator"}])
      expect(subject.dates).to include({"date"=>"2018-03-13", "dateType"=>"Issued"})
      expect(subject.publication_year).to eq("2018")
      expect(subject.publisher).to eq({"name"=>"American Physical Society (APS)"})
      expect(subject.container).to eq("firstPage" => "117701", "identifier"=>"1079-7114", "identifierType"=>"ISSN", "issue"=>"11", "title"=>"Physical Review Letters", "type"=>"Journal", "volume"=>"120")
      expect(subject.agency).to eq("crossref")
      expect(subject.date_registered).to eq("2018-03-13T15:18:48Z")
    end

    it "posted content copernicus" do
      input = "https://doi.org/10.5194/CP-2020-95"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.url).to eq("https://cp.copernicus.org/preprints/cp-2020-95/")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"PostedContent", "resourceTypeGeneral"=>"JournalArticle", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.count).to eq(6)
      expect(subject.creators.first).to eq("nameType" => "Personal", "familyName" => "Shao",
        "givenName" => "Jun",
        "name" => "Shao, Jun",
        "nameIdentifiers" => [{"nameIdentifier"=>"https://orcid.org/0000-0001-6130-6474", "nameIdentifierScheme"=>"ORCID", "schemeUri"=>"https://orcid.org"}])
      expect(subject.titles).to eq([{"title"=>"The Atmospheric Bridge Communicated the ??&lt;sup&gt;13&lt;/sup&gt;C Decline during the Last Deglaciation to the Global Upper Ocean"}])
      expect(subject.id).to eq("https://doi.org/10.5194/cp-2020-95")
      expect(subject.identifiers).to be_empty
      expect(subject.descriptions.first["description"]).to start_with("Abstract. During the early last glacial termination")
      expect(subject.dates).to include({"date"=>"2020-07-28", "dateType"=>"Issued"})
      expect(subject.publication_year).to eq("2020")
      expect(subject.publisher).to eq({"name"=>"Copernicus GmbH"})
      expect(subject.agency).to eq("crossref")
    end

    it "book oup" do
      input = "10.1093/oxfordhb/9780198746140.013.5"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.url).to eq("http://oxfordhandbooks.com/view/10.1093/oxfordhb/9780198746140.001.0001/oxfordhb-9780198746140-e-5")
      expect(subject.types).to eq("bibtex"=>"book", "citeproc"=>"book", "resourceType"=>"Book", "resourceTypeGeneral"=>"Book", "ris"=>"BOOK", "schemaOrg"=>"Book")
      expect(subject.creators.count).to eq(1)
      expect(subject.creators.first).to eq("familyName"=>"Clayton", "givenName"=>"Barbra R.", "name"=>"Clayton, Barbra R.", "nameType"=>"Personal")
      expect(subject.contributors.count).to eq(2)
      expect(subject.contributors.first).to eq("contributorType"=>"Editor", "familyName"=>"Cozort", "givenName"=>"Daniel", "name"=>"Cozort, Daniel", "nameType"=>"Personal")
      expect(subject.titles).to eq([{"title"=>"The Changing Way of the Bodhisattva"}])
      expect(subject.id).to eq("https://doi.org/10.1093/oxfordhb/9780198746140.013.5")
      expect(subject.identifiers).to be_empty
      expect(subject.descriptions.first["description"]).to start_with("This chapter explores the nature of the connections")
      expect(subject.dates).to include({"date"=>"2018-04-05", "dateType"=>"Issued"})
      expect(subject.publication_year).to eq("2018")
      expect(subject.publisher).to eq({"name"=>"Oxford University Press (OUP)"})
      expect(subject.agency).to eq("crossref")
    end

    it "report osti" do
      input = "10.2172/972169"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.url).to eq("http://www.osti.gov/servlets/purl/972169-1QXROM/")
      expect(subject.types).to eq("bibtex"=>"techreport", "citeproc"=>"report", "resourceType"=>"Report", "resourceTypeGeneral"=>"Report", "ris"=>"RPRT", "schemaOrg"=>"Report")
      expect(subject.creators.count).to eq(4)
      expect(subject.creators.first).to eq("familyName"=>"Denholm", "givenName"=>"P.", "name"=>"Denholm, P.", "nameType"=>"Personal")
      expect(subject.contributors.count).to eq(0)
      expect(subject.titles).to eq([{"title"=>"Role of Energy Storage with Renewable Electricity Generation"}])
      expect(subject.id).to eq("https://doi.org/10.2172/972169")
      expect(subject.identifiers).to eq( [{"identifier"=>"NREL/TP-6A2-47187", "identifierType"=>"report-number"}, {"identifier"=>"972169", "identifierType"=>"sequence-number"}])
      expect(subject.descriptions).to be_empty
      expect(subject.dates).to include({"date"=>"2010-01-01", "dateType"=>"Issued"})
      expect(subject.publication_year).to eq("2010")
      expect(subject.publisher).to eq({"name"=>"Office of Scientific and Technical Information (OSTI)"})
      expect(subject.agency).to eq("crossref")
    end

    it "journal issue" do
      input = "https://doi.org/10.6002/ect.2015.0371"
      subject = Bolognese::Metadata.new(input: input)
      #expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.6002/ect.2015.0371")
      expect(subject.url).to eq("http://ectrx.org/forms/ectrxcontentshow.php?doi_id=10.6002/ect.2015.0371")
      expect(subject.types).to eq("bibtex"=>"misc", "citeproc"=>"article-journal", "resourceType"=>"JournalIssue", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"PublicationIssue")
      expect(subject.creators).to eq([{"name"=>":(unav)", "nameType"=>"Organizational"}])
      expect(subject.titles).to eq([{"title"=>":(unav)"}])
      expect(subject.dates).to eq([{"date"=>"2018-10", "dateType"=>"Issued"}, {"date"=>"2018-10-03T12:09:12Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2018")
      expect(subject.publisher).to eq({"name"=>"Baskent University"})
      expect(subject.related_identifiers.length).to eq(1)
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"2146-8427", "relatedIdentifierType"=>"ISSN", "relationType"=>"IsPartOf", "resourceTypeGeneral"=>"Collection")
      expect(subject.container).to eq("identifier"=>"2146-8427", "identifierType"=>"ISSN", "issue"=>"5", "title"=>"Experimental and Clinical Transplantation", "type"=>"Journal", "volume"=>"16")
      expect(subject.agency).to eq("crossref")
    end

    it "not found error" do
      input = "https://doi.org/10.7554/elife.01567x"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be false
      expect(subject.id).to eq("https://doi.org/10.7554/elife.01567x")
      expect(subject.doi).to eq("10.7554/elife.01567x")
      expect(subject.agency).to eq("crossref")
      expect(subject.state).to eq("not_found")
    end
  end
end
