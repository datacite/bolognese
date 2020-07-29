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
      expect(subject.identifiers).to eq([{"identifier"=>"e01567", "identifierType"=>"Publisher ID"}])
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.url).to eq("https://elifesciences.org/articles/01567")
      expect(subject.creators.length).to eq(5)
      expect(subject.creators.first).to eq("nameType"=>"Personal", "name"=>"Sankar, Martial", "givenName"=>"Martial", "familyName"=>"Sankar", "affiliation" => [{"name"=>"Department of Plant Molecular Biology, University of Lausanne, Lausanne, Switzerland"}])
      expect(subject.rights_list).to eq([{"rights"=>"Creative Commons Attribution 3.0 Unported",
        "rightsIdentifier"=>"cc-by-3.0",
        "rightsIdentifierScheme"=>"SPDX",
        "rightsUri"=>"https://creativecommons.org/licenses/by/3.0/legalcode",
        "schemeUri"=>"https://spdx.org/licenses/"}])
      expect(subject.titles).to eq([{"title"=>"Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth"}])
      expect(subject.dates).to eq([{"date"=>"2014-02-11", "dateType"=>"Issued"}, {"date"=>"2018-08-23T13:41:49Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2014")
      expect(subject.publisher).to eq("eLife Sciences Publications, Ltd")
      expect(subject.container).to eq("identifier"=>"2050-084X", "identifierType"=>"ISSN", "title"=>"eLife", "type"=>"Journal", "volume"=>"3")
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
      expect(subject.agency).to eq("Crossref")
    end

    it "journal article" do
      input = "https://doi.org/10.1371/journal.pone.0000030"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1371/journal.pone.0000030")
      expect(subject.identifiers).to eq([{"identifier"=>"10.1371/journal.pone.0000030", "identifierType"=>"Publisher ID"}])
      expect(subject.url).to eq("https://dx.plos.org/10.1371/journal.pone.0000030")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.length).to eq(5)
      expect(subject.creators.first).to eq("nameType"=>"Personal", "name"=>"Ralser, Markus", "givenName"=>"Markus", "familyName"=>"Ralser")
      expect(subject.contributors).to eq("contributorType"=>"Editor", "familyName"=>"Janbon", "givenName"=>"Guilhem", "name"=>"Janbon, Guilhem", "nameType"=>"Personal")
      expect(subject.titles).to eq([{"title"=>"Triose Phosphate Isomerase Deficiency Is Caused by Altered Dimerization–Not Catalytic Inactivity–of the Mutant Enzymes"}])
      expect(subject.rights_list).to eq([{"rights"=>"Creative Commons Attribution 4.0 International",
        "rightsIdentifier"=>"cc-by-4.0",
        "rightsIdentifierScheme"=>"SPDX",
        "rightsUri"=>"https://creativecommons.org/licenses/by/4.0/legalcode",
        "schemeUri"=>"https://spdx.org/licenses/"}])
      expect(subject.dates).to eq([{"date"=>"2006-12-20", "dateType"=>"Issued"}, {"date"=>"2020-05-09T09:35:17Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2006")
      expect(subject.publisher).to eq("Public Library of Science (PLoS)")
      expect(subject.related_identifiers.length).to eq(64)
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"1932-6203", "relatedIdentifierType"=>"ISSN", "relationType"=>"IsPartOf", "resourceTypeGeneral"=>"Collection")
      expect(subject.related_identifiers.last).to eq("relatedIdentifier"=>"10.1056/nejm199109123251104", "relatedIdentifierType"=>"DOI", "relationType"=>"References")
      expect(subject.container).to eq("firstPage"=>"e30", "identifier"=>"1932-6203", "identifierType"=>"ISSN", "issue"=>"1", "title"=>"PLoS ONE", "type"=>"Journal", "volume"=>"1")
      expect(subject.agency).to eq("Crossref")
    end

    it "journal article with funding" do
      input = "https://doi.org/10.3389/fpls.2019.00816"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.3389/fpls.2019.00816")
      expect(subject.identifiers).to eq([{"identifier"=>"816", "identifierType"=>"Publisher ID"}])
      expect(subject.url).to eq("https://www.frontiersin.org/article/10.3389/fpls.2019.00816/full")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
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
      expect(subject.publisher).to eq("Frontiers Media SA")
      expect(subject.funding_references).to eq([{"awardNumber"=>"CA17111", "funderIdentifier"=>"https://doi.org/10.13039/501100000921", "funderIdentifierType"=>"Crossref Funder ID", "funderName"=>"COST (European Cooperation in Science and Technology)"}])
      expect(subject.related_identifiers.length).to eq(70)
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"1664-462X", "relatedIdentifierType"=>"ISSN", "relationType"=>"IsPartOf", "resourceTypeGeneral"=>"Collection")
      expect(subject.related_identifiers.last).to eq("relatedIdentifier"=>"10.17660/actahortic.2004.632.41", "relatedIdentifierType"=>"DOI", "relationType"=>"References")
      expect(subject.container).to eq("identifier"=>"1664-462X", "identifierType"=>"ISSN", "title"=>"Frontiers in Plant Science", "type"=>"Journal", "volume"=>"10")
      expect(subject.agency).to eq("Crossref")
    end

    it "journal article original language title" do
      input = "https://doi.org/10.7600/jspfsm.56.60"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.7600/jspfsm.56.60")
      expect(subject.url).to eq("http://jlc.jst.go.jp/JST.JSTAGE/jspfsm/56.60?lang=en&from=CrossRef&type=abstract")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators).to eq("name"=>":(unav)", "nameType"=>"Organizational")
      expect(subject.titles).to eq([{"lang"=>"ja", "title"=>"自律神経・循環器応答"}])
      expect(subject.dates).to include({"date"=>"2007", "dateType"=>"Issued"})
      expect(subject.publication_year).to eq("2007")
      expect(subject.publisher).to eq("The Japanese Society of Physical Fitness and Sports Medicine")
      expect(subject.related_identifiers.length).to eq(1)
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"1881-4751", "relatedIdentifierType"=>"ISSN", "relationType"=>"IsPartOf", "resourceTypeGeneral"=>"Collection")
      expect(subject.container).to eq("firstPage"=>"60", "identifier"=>"1881-4751", "identifierType"=>"ISSN", "issue"=>"1", "lastPage"=>"60", "title"=>"Japanese Journal of Physical Fitness and Sports Medicine", "type"=>"Journal", "volume"=>"56")
      expect(subject.agency).to eq("Crossref")
    end

    it "journal article with RDF for container" do
      input = "https://doi.org/10.1163/1937240X-00002096"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1163/1937240x-00002096")
      expect(subject.url).to eq("https://academic.oup.com/jcb/article-lookup/doi/10.1163/1937240X-00002096")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.length).to eq(8)
      expect(subject.creators.first).to eq("familyName"=>"Mesquita-Joanes", "givenName"=>"Francesc", "name"=>"Mesquita-Joanes, Francesc", "nameType"=>"Personal")
      expect(subject.titles).to eq([{"title"=>"Global distribution of Fabaeformiscandona subacuta: an exotic invasive Ostracoda on the Iberian Peninsula?"}])
      expect(subject.dates).to include({"date"=>"2012-01-01", "dateType"=>"Issued"})
      expect(subject.publication_year).to eq("2012")
      expect(subject.publisher).to eq("Oxford University Press (OUP)")
      expect(subject.related_identifiers.length).to eq(44)
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"1937-240X", "relatedIdentifierType"=>"ISSN", "relationType"=>"IsPartOf", "resourceTypeGeneral"=>"Collection")
      expect(subject.related_identifiers.last).to eq("relatedIdentifier"=>"10.1002/aqc.1122", "relatedIdentifierType"=>"DOI", "relationType"=>"References")
      expect(subject.container).to eq("firstPage"=>"949", "identifier"=>"1937-240X", "identifierType"=>"ISSN", "issue"=>"6", "lastPage"=>"961", "title"=>"Journal of Crustacean Biology", "type"=>"Journal", "volume"=>"32")
      expect(subject.agency).to eq("Crossref")
    end

    it "book chapter with RDF for container" do
      input = "10.1007/978-3-642-33191-6_49"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1007/978-3-642-33191-6_49")
      expect(subject.url).to eq("http://link.springer.com/10.1007/978-3-642-33191-6_49")
      expect(subject.types).to eq("bibtex"=>"inbook", "citeproc"=>"chapter", "resourceType"=>"BookChapter", "resourceTypeGeneral"=>"Text", "ris"=>"CHAP", "schemaOrg"=>"Chapter")
      expect(subject.creators.length).to eq(3)
      expect(subject.creators.first).to eq("familyName"=>"Chen", "givenName"=>"Lili", "name"=>"Chen, Lili", "nameType"=>"Personal")
      expect(subject.titles).to eq([{"title"=>"Human Body Orientation Estimation in Multiview Scenarios"}])
      expect(subject.dates).to eq([{"date"=>"2012", "dateType"=>"Issued"}, {"date"=>"2019-07-03T01:07:17Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2012")
      expect(subject.publisher).to eq("Springer Berlin Heidelberg")
      expect(subject.related_identifiers.length).to eq(7)
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"10.1007/978-3-540-24670-1_3", "relatedIdentifierType"=>"DOI", "relationType"=>"References")
      expect(subject.container).to eq("identifier"=>"1611-3349", "identifierType"=>"ISSN", "title"=>"Lecture Notes in Computer Science", "type"=>"Book Series")
      expect(subject.agency).to eq("Crossref")
    end

    it "posted_content" do
      input = "https://doi.org/10.1101/097196"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.url).to eq("http://biorxiv.org/lookup/doi/10.1101/097196")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"PostedContent", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.count).to eq(11)
      expect(subject.creators.last).to eq("nameType"=>"Personal", "nameIdentifiers" => [{"nameIdentifier"=>"https://orcid.org/0000-0003-4060-7360", "nameIdentifierScheme"=>"ORCID", "schemeUri"=>"https://orcid.org"}], "name"=>"Clark, Timothy", "givenName"=>"Timothy", "familyName"=>"Clark")
      expect(subject.titles).to eq([{"title"=>"A Data Citation Roadmap for Scholarly Data Repositories"}])
      expect(subject.id).to eq("https://doi.org/10.1101/097196")
      expect(subject.identifiers).to eq([{"identifier"=>"biorxiv;097196v2", "identifierType"=>"Publisher ID"}])
      expect(subject.descriptions.first["description"]).to start_with("This article presents a practical roadmap")
      expect(subject.dates).to include({"date"=>"2017-10-09", "dateType"=>"Issued"})
      expect(subject.publication_year).to eq("2017")
      expect(subject.publisher).to eq("Cold Spring Harbor Laboratory")
      expect(subject.agency).to eq("Crossref")
    end

    it "DOI with SICI DOI" do
      input = "https://doi.org/10.1890/0012-9658(2006)87[2832:tiopma]2.0.co;2"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1890/0012-9658(2006)87%255b2832:tiopma%255d2.0.co;2")
      expect(subject.url).to eq("http://doi.wiley.com/10.1890/0012-9658(2006)87[2832:TIOPMA]2.0.CO;2")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators).to eq([{"nameType"=>"Personal", "name"=>"Fenton, A.", "givenName"=>"A.", "familyName"=>"Fenton"}, {"nameType"=>"Personal", "name"=>"Rands, S. A.", "givenName"=>"S. A.", "familyName"=>"Rands"}])
      expect(subject.rights_list).to eq([{"rightsUri"=>"http://doi.wiley.com/10.1002/tdm_license_1.1"}])
      expect(subject.titles).to eq([{"title"=>"THE IMPACT OF PARASITE MANIPULATION AND PREDATOR FORAGING BEHAVIOR ON PREDATOR–PREY COMMUNITIES"}])
      expect(subject.dates).to eq([{"date"=>"2006-11", "dateType"=>"Issued"}, {"date"=>"2019-04-28T17:51:50Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2006")
      expect(subject.publisher).to eq("Wiley")
      expect(subject.related_identifiers.length).to eq(35)
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"0012-9658", "relatedIdentifierType"=>"ISSN", "relationType"=>"IsPartOf", "resourceTypeGeneral"=>"Collection")
      expect(subject.related_identifiers.last).to eq("relatedIdentifier"=>"10.1098/rspb.2002.2213", "relatedIdentifierType"=>"DOI", "relationType"=>"References")
      expect(subject.container).to eq("firstPage"=>"2832", "identifier"=>"0012-9658", "identifierType"=>"ISSN", "issue"=>"11", "lastPage"=>"2841", "title"=>"Ecology", "type"=>"Journal", "volume"=>"87")
      expect(subject.agency).to eq("Crossref")
    end

    it "DOI with ORCID ID" do
      input = "https://doi.org/10.1155/2012/291294"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1155/2012/291294")
      expect(subject.url).to eq("http://www.hindawi.com/journals/pm/2012/291294/")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
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
      expect(subject.publisher).to eq("Hindawi Limited")
      expect(subject.related_identifiers.length).to eq(18)
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"2090-1844", "relatedIdentifierType"=>"ISSN", "relationType"=>"IsPartOf", "resourceTypeGeneral"=>"Collection")
      expect(subject.related_identifiers.last).to eq("relatedIdentifier"=>"10.1378/chest.12-0045", "relatedIdentifierType"=>"DOI", "relationType"=>"References")
      expect(subject.container).to eq("firstPage"=>"1", "identifier"=>"2090-1844", "identifierType"=>"ISSN", "lastPage"=>"7", "title"=>"Pulmonary Medicine", "type"=>"Journal", "volume"=>"2012")
      expect(subject.agency).to eq("Crossref")
    end

    it "date in future" do
      input = "https://doi.org/10.1016/j.ejphar.2015.03.018"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1016/j.ejphar.2015.03.018")
      expect(subject.identifiers).to eq([{"identifier"=>"S0014299915002332", "identifierType"=>"Publisher ID"}])
      expect(subject.url).to eq("https://linkinghub.elsevier.com/retrieve/pii/S0014299915002332")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.length).to eq(10)
      expect(subject.creators.first).to eq("nameType"=>"Personal", "name"=>"Beck, Sarah E.", "givenName"=>"Sarah E.", "familyName"=>"Beck")
      expect(subject.titles).to eq([{"title"=>"Paving the path to HIV neurotherapy: Predicting SIV CNS disease"}])
      expect(subject.dates).to include({"date"=>"2015-07", "dateType"=>"Issued"})
      expect(subject.publication_year).to eq("2015")
      expect(subject.publisher).to eq("Elsevier BV")
      expect(subject.related_identifiers).to eq([{"relatedIdentifier"=>"0014-2999", "relatedIdentifierType"=>"ISSN", "relationType"=>"IsPartOf", "resourceTypeGeneral"=>"Collection"}])
      expect(subject.container).to eq("firstPage"=>"303", "identifier"=>"0014-2999", "identifierType"=>"ISSN", "lastPage"=>"312", "title"=>"European Journal of Pharmacology", "type"=>"Journal", "volume"=>"759")
      expect(subject.agency).to eq("Crossref")
    end

    it "vor with url" do
      input = "https://doi.org/10.1038/hdy.2013.26"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1038/hdy.2013.26")
      expect(subject.url).to eq("http://www.nature.com/articles/hdy201326")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.length).to eq(2)
      expect(subject.creators.first).to eq("familyName"=>"Gross", "givenName"=>"J B", "name"=>"Gross, J B", "nameType"=>"Personal")
      expect(subject.titles).to eq([{"title"=>"Albinism in phylogenetically and geographically distinct populations of Astyanax cavefish arises through the same loss-of-function Oca2 allele"}])
      expect(subject.dates).to include({"date"=>"2013-04-10", "dateType"=>"Issued"})
      expect(subject.publication_year).to eq("2013")
      expect(subject.publisher).to eq("Springer Science and Business Media LLC")
      expect(subject.related_identifiers.size).to eq(35)
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"1365-2540", "relatedIdentifierType"=>"ISSN", "relationType"=>"IsPartOf", "resourceTypeGeneral"=>"Collection")
      expect(subject.container).to eq("firstPage"=>"122", "identifier"=>"1365-2540", "identifierType"=>"ISSN", "issue"=>"2", "lastPage"=>"130", "title"=>"Heredity", "type"=>"Journal", "volume"=>"111")
      expect(subject.agency).to eq("Crossref")
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
      expect(subject.publisher).to eq("Worldwide Protein Data Bank")
      expect(subject.agency).to eq("Crossref")
    end

    it "component" do
      input = "10.1371/journal.pmed.0030277.g001"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1371/journal.pmed.0030277.g001")
      expect(subject.url).to eq("https://dx.plos.org/10.1371/journal.pmed.0030277.g001")
      expect(subject.types).to eq("bibtex"=>"misc", "citeproc"=>"article-journal", "resourceType"=>"SaComponent", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators).to eq("name"=>":(unav)", "nameType"=>"Organizational")
      expect(subject.titles).to eq([{"title"=>":{unav)"}])
      expect(subject.descriptions).to be_empty
      expect(subject.dates).to eq([{"date"=>"2015-10-20", "dateType"=>"Issued"}, {"date"=>"2018-10-19T17:13:42Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2015")
      expect(subject.publisher).to eq("Public Library of Science (PLoS)")
      expect(subject.agency).to eq("Crossref")
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
      expect(subject.publisher).to eq("USDA Forest Service")
      expect(subject.agency).to eq("Crossref")
    end

    it "book chapter" do
      input = "https://doi.org/10.1007/978-3-662-46370-3_13"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1007/978-3-662-46370-3_13")
      expect(subject.url).to eq("http://link.springer.com/10.1007/978-3-662-46370-3_13")
      expect(subject.types).to eq("bibtex"=>"inbook", "citeproc"=>"chapter", "resourceType"=>"BookChapter", "resourceTypeGeneral"=>"Text", "ris"=>"CHAP", "schemaOrg"=>"Chapter")
      expect(subject.creators.length).to eq(2)
      expect(subject.creators.first).to eq("nameType"=>"Personal", "name"=>"Diercks, Ronald L.", "givenName"=>"Ronald L.", "familyName"=>"Diercks")
      expect(subject.titles).to eq([{"title"=>"Clinical Symptoms and Physical Examinations"}])
      expect(subject.dates).to eq([{"date"=>"2015", "dateType"=>"Issued"}, {"date"=>"2015-04-14T02:31:13Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2015")
      expect(subject.publisher).to eq("Springer Berlin Heidelberg")
      expect(subject.agency).to eq("Crossref")
    end

    it "another book chapter" do
      input = "https://doi.org/10.1007/978-3-319-75889-3_1"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1007/978-3-319-75889-3_1")
      expect(subject.url).to eq("http://link.springer.com/10.1007/978-3-319-75889-3_1")
      expect(subject.types).to eq("bibtex"=>"inbook", "citeproc"=>"chapter", "resourceType"=>"BookChapter", "resourceTypeGeneral"=>"Text", "ris"=>"CHAP", "schemaOrg"=>"Chapter")
      expect(subject.creators).to eq("familyName"=>"Jones", "givenName"=>"Hunter M.", "name"=>"Jones, Hunter M.", "nameType"=>"Personal")
      expect(subject.titles).to eq([{"title"=>"Climate Change and Increasing Risk of Extreme Heat"}])
      expect(subject.dates).to include({"date"=>"2018", "dateType"=>"Issued"})
      expect(subject.publication_year).to eq("2018")
      expect(subject.publisher).to eq("Springer International Publishing")
      expect(subject.agency).to eq("Crossref")
    end

    it "yet another book chapter" do
      input = "https://doi.org/10.4018/978-1-4666-1891-6.ch004"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.4018/978-1-4666-1891-6.ch004")
      expect(subject.url).to eq("http://services.igi-global.com/resolvedoi/resolve.aspx?doi=10.4018/978-1-4666-1891-6.ch004")
      expect(subject.types).to eq("bibtex"=>"inbook", "citeproc"=>"chapter", "resourceType"=>"BookChapter", "resourceTypeGeneral"=>"Text", "ris"=>"CHAP", "schemaOrg"=>"Chapter")
      expect(subject.creators).to eq("familyName"=>"Bichot", "givenName"=>"Charles-Edmond", "name"=>"Bichot, Charles-Edmond", "affiliation" => [{"name"=>"Université de Lyon, France"}], "nameType"=>"Personal")
      expect(subject.titles).to eq([{"title"=>"Unsupervised and Supervised Image Segmentation Using Graph Partitioning"}])
      expect(subject.dates).to eq([{"date"=>"2012-08-08", "dateType"=>"Issued"}, {"date"=>"2019-07-02T17:17:21Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2012")
      expect(subject.publisher).to eq("IGI Global")
      expect(subject.agency).to eq("Crossref")
    end

    it "missing creator" do
      input = "https://doi.org/10.3390/publications6020015"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.3390/publications6020015")
      expect(subject.url).to eq("http://www.mdpi.com/2304-6775/6/2/15")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators).to eq([{"name"=>"Alexander Kohls", "nameType"=>"Organizational"}, {"name"=>"Salvatore Mele", "nameType"=>"Organizational"}])
      expect(subject.titles).to eq([{"title"=>"Converting the Literature of a Scientific Field to Open Access through Global Collaboration: The Experience of SCOAP3 in Particle Physics"}])
      expect(subject.dates).to eq([{"date"=>"2018-04-09", "dateType"=>"Issued"}, {"date"=>"2018-04-10T17:58:05Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2018")
      expect(subject.publisher).to eq("MDPI AG")
      expect(subject.agency).to eq("Crossref")
    end

    it "book" do
      input = "https://doi.org/10.1017/9781108348843"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1017/9781108348843")
      expect(subject.identifiers).to eq([{"identifier"=>"9781108348843", "identifierType"=>"ISBN"}])
      expect(subject.url).to eq("https://www.cambridge.org/core/product/identifier/9781108348843/type/book")
      expect(subject.types).to eq("bibtex"=>"book", "citeproc"=>"book", "resourceType"=>"Book", "ris"=>"BOOK", "schemaOrg"=>"Book")
      expect(subject.creators).to eq("familyName"=>"Leung", "givenName"=>"Vincent S.", "name"=>"Leung, Vincent S.", "nameType"=>"Personal")
      expect(subject.titles).to eq([{"title"=>"The Politics of the Past in Early China"}])
      expect(subject.dates).to eq([{"date"=>"2019-07-01", "dateType"=>"Issued"}, {"date"=>"2019-12-01T18:11:11Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2019")
      expect(subject.publisher).to eq("Cambridge University Press")
      expect(subject.agency).to eq("Crossref")
      expect(subject.date_registered).to eq("2019-07-06T10:19:22Z")
    end

    it "another book" do
      input = "https://doi.org/10.2973/odp.proc.ir.180.2000"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.2973/odp.proc.ir.180.2000")
      expect(subject.url).to eq("http://www-odp.tamu.edu/publications/180_IR/180TOC.HTM")
      expect(subject.types).to eq("bibtex"=>"book", "citeproc"=>"book", "resourceType"=>"Book", "ris"=>"BOOK", "schemaOrg"=>"Book")
      expect(subject.creators).to eq("name"=>":(unav)", "nameType"=>"Organizational")
      expect(subject.contributors.size).to eq(4)
      expect(subject.contributors.first).to eq("contributorType"=>"Editor", "familyName"=>"Taylor", "givenName"=>"B.", "name"=>"Taylor, B.", "nameType"=>"Personal")
      expect(subject.titles).to eq([{"title"=>"Proceedings of the Ocean Drilling Program, 180 Initial Reports"}])
      expect(subject.dates).to eq([{"date"=>"2000-02-04", "dateType"=>"Issued"}, {"date"=>"2009-02-02T21:19:43Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2000")
      expect(subject.publisher).to eq("Ocean Drilling Program")
      expect(subject.agency).to eq("Crossref")
      expect(subject.date_registered).to eq("2006-10-17T20:17:44Z")
    end

    it "yet another book" do
      input = "https://doi.org/10.1029/ar035"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1029/ar035")
      expect(subject.identifiers).to eq([{"identifier"=>"0-87590-181-6", "identifierType"=>"ISBN"}])
      expect(subject.url).to eq("http://doi.wiley.com/10.1029/AR035")
      expect(subject.types).to eq("bibtex"=>"book", "citeproc"=>"book", "resourceType"=>"Book", "ris"=>"BOOK", "schemaOrg"=>"Book")
      expect(subject.creators).to eq("familyName"=>"McGinnis", "givenName"=>"Richard Frank", "name"=>"McGinnis, Richard Frank", "nameType"=>"Personal")
      expect(subject.titles).to eq([{"title"=>"Biogeography of Lanternfishes (Myctophidae) South of 30°S"}])
      expect(subject.dates).to eq([{"date"=>"1982", "dateType"=>"Issued"}, {"date"=>"2019-06-15T05:11:12Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("1982")
      expect(subject.publisher).to eq("American Geophysical Union")
      expect(subject.related_identifiers.length).to eq(44)
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"10.1016/0031-0182(70)90103-3", "relatedIdentifierType"=>"DOI", "relationType"=>"References")
      expect(subject.container).to eq("identifier"=>"0066-4634", "identifierType"=>"ISSN", "title"=>"Antarctic Research Series", "type"=>"Book Series", "volume"=>"35")
      expect(subject.agency).to eq("Crossref")
      expect(subject.date_registered).to be_nil
    end

    it "mEDRA" do
      input = "https://doi.org/10.3280/ecag2018-001005"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.3280/ecag2018-001005")
      expect(subject.identifiers).to eq([{"identifier"=>"5", "identifierType"=>"Publisher ID"}])
      expect(subject.url).to eq("http://www.francoangeli.it/riviste/Scheda_Riviste.asp?IDArticolo=61645")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.length).to eq(2)
      expect(subject.creators.first).to eq("familyName"=>"Oh", "givenName"=>"Sohae Eve", "name"=>"Oh, Sohae Eve", "nameType"=>"Personal")
      expect(subject.titles).to eq([{"title"=>"Substitutability between organic and conventional poultry products and organic price premiums"}])
      expect(subject.dates).to include({"date"=>"2018-05", "dateType"=>"Issued"})
      expect(subject.publication_year).to eq("2018")
      expect(subject.publisher).to eq("Franco Angeli")
      expect(subject.agency).to eq("mEDRA")
    end

    it "KISTI" do
      input = "https://doi.org/10.5012/bkcs.2013.34.10.2889"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.5012/bkcs.2013.34.10.2889")
      expect(subject.identifiers).to eq([{"identifier"=>"JCGMCS_2013_v34n10_2889", "identifierType"=>"Publisher ID"}])
      expect(subject.url).to eq("http://koreascience.or.kr/journal/view.jsp?kj=JCGMCS&py=2013&vnc=v34n10&sp=2889")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.length).to eq(7)
      expect(subject.creators.first).to eq("familyName"=>"Huang", "givenName"=>"Guimei", "name"=>"Huang, Guimei", "nameType"=>"Personal")
      expect(subject.titles).to eq([{"title"=>"Synthesis, Crystal Structure and Theoretical Calculation of a Novel Nickel(II) Complex with Dibromotyrosine and 1,10-Phenanthroline"}])
      expect(subject.dates).to eq([{"date"=>"2013-10-20", "dateType"=>"Issued"}, {"date"=>"2016-12-15T02:40:52Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2013")
      expect(subject.publisher).to eq("Korean Chemical Society")
      expect(subject.agency).to eq("KISTI")
    end

    it "JaLC" do
      input = "https://doi.org/10.1241/johokanri.39.979"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1241/johokanri.39.979")
      expect(subject.url).to eq("http://joi.jlc.jst.go.jp/JST.JSTAGE/johokanri/39.979?from=CrossRef")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators).to eq("familyName"=>"KUSUMOTO", "givenName"=>"Hiroyuki", "name"=>"KUSUMOTO, Hiroyuki", "nameType"=>"Personal")
      expect(subject.titles).to eq([{"title"=>"Utilizing the Internet. 12 Series. Future of the Internet."}])
      expect(subject.dates).to eq([{"date"=>"1997", "dateType"=>"Issued"}, {"date"=>"2020-03-06T06:44:36Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("1997")
      expect(subject.publisher).to eq("Japan Science and Technology Agency (JST)")
      expect(subject.agency).to eq("JaLC")
    end

    it "OP" do
      input = "https://doi.org/10.2903/j.efsa.2018.5239"
      subject = Bolognese::Metadata.new(input: input)
      #expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.2903/j.efsa.2018.5239")
      expect(subject.url).to eq("http://doi.wiley.com/10.2903/j.efsa.2018.5239")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.length).to eq(28)
      expect(subject.creators.first).to eq("familyName"=>"Younes", "givenName"=>"Maged", "name"=>"Younes, Maged", "nameType"=>"Personal")
      expect(subject.titles).to eq([{"title"=>"Scientific opinion on the safety of green tea catechins"}])
      expect(subject.dates).to include({"date"=>"2018-04", "dateType"=>"Issued"})
      expect(subject.publication_year).to eq("2018")
      expect(subject.publisher).to eq("Wiley")
      expect(subject.agency).to eq("OP")
    end

    it "multiple titles" do
      input = "https://doi.org/10.4000/dms.865"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.4000/dms.865")
      expect(subject.url).to eq("http://journals.openedition.org/dms/865")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators).to eq("familyName"=>"Peraya", "givenName"=>"Daniel", "name"=>"Peraya, Daniel", "nameType"=>"Personal")
      expect(subject.titles).to eq([{"title"=>"Distances, absence, proximités et présences : des concepts en déplacement"}, {"title"=>"Distance(s), proximity and presence(s): evolving concepts"}])
      expect(subject.dates).to include({"date"=>"2014-12-23", "dateType"=>"Issued"})
      expect(subject.publication_year).to eq("2014")
      expect(subject.publisher).to eq("OpenEdition")
      expect(subject.agency).to eq("Crossref")
      expect(subject.date_registered).to be_nil
    end

    it "markup" do
      input = "https://doi.org/10.1098/rspb.2017.0132"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1098/rspb.2017.0132")
      expect(subject.url).to eq("https://royalsocietypublishing.org/doi/10.1098/rspb.2017.0132")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.size).to eq(6)
      expect(subject.creators.first).to eq("affiliation" => [{"name"=>"School of Biological Sciences, Centre for Evolutionary Biology, University of Western Australia, Crawley, WA 6009, Australia"}], "familyName" => "Dougherty","givenName" => "Liam R.","name" => "Dougherty, Liam R.","nameIdentifiers" => [{"nameIdentifier"=>"https://orcid.org/0000-0003-1406-0680", "nameIdentifierScheme"=>"ORCID", "schemeUri"=>"https://orcid.org"}],"nameType"=>"Personal")
      expect(subject.titles).to eq([{"title"=>"Sexual conflict and correlated evolution between male persistence and female resistance traits in the seed beetle <i>Callosobruchus maculatus</i>"}])
      expect(subject.dates).to include({"date"=>"2017-05-24", "dateType"=>"Issued"})
      expect(subject.publication_year).to eq("2017")
      expect(subject.publisher).to eq("The Royal Society")
      expect(subject.agency).to eq("Crossref")
      expect(subject.date_registered).to eq("2019-07-18T04:43:12Z")
    end

    it "empty given name" do
      input = "https://doi.org/10.1111/J.1865-1682.2010.01171.X"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1111/j.1865-1682.2010.01171.x")
      expect(subject.url).to eq("http://doi.wiley.com/10.1111/j.1865-1682.2010.01171.x")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.length).to eq(5)
      expect(subject.creators[3]).to eq("familyName"=>"Ehtisham-ul-Haq", "givenName"=>" ", "name"=>"Ehtisham-ul-Haq,  ", "nameType"=>"Personal")
      expect(subject.titles).to eq([{"title"=>"Serological Evidence of Brucella abortus Prevalence in Punjab Province, Pakistan - A Cross-Sectional Study"}])
      expect(subject.rights_list).to eq([{"rightsUri"=>"http://doi.wiley.com/10.1002/tdm_license_1.1"}])
      expect(subject.dates).to eq([{"date"=>"2010-12", "dateType"=>"Issued"}, {"date"=>"2019-03-05T09:22:24Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2010")
      expect(subject.publisher).to eq("Wiley")
    end

    it "invalid date" do
      input = "https://doi.org/10.1055/s-0039-1690894"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1055/s-0039-1690894")
      expect(subject.identifiers).to eq([{"identifier"=>"s-0039-1690894", "identifierType"=>"Publisher ID"}])
      expect(subject.url).to eq("http://www.thieme-connect.de/DOI/DOI?10.1055/s-0039-1690894")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.length).to eq(4)
      expect(subject.creators[3]).to eq("affiliation" => [{"name"=>"Department of Chemistry, Tianjin Key Laboratory of Molecular Optoelectronic Sciences, and Tianjin Collaborative Innovation Centre of Chemical Science and Engineering, Tianjin University"}, {"name"=>"Joint School of National University of Singapore and Tianjin University, International Campus of Tianjin University"}],
        "familyName" => "Ma",
        "givenName" => "Jun-An",
        "name" => "Ma, Jun-An",
        "nameIdentifiers" => [{"nameIdentifier"=>"https://orcid.org/0000-0002-3902-6799", "nameIdentifierScheme"=>"ORCID", "schemeUri"=>"https://orcid.org"}],
        "nameType" => "Personal")
      expect(subject.titles).to eq([{"title"=>"Silver-Catalyzed [3+3] Annulation of Glycine Imino Esters with Seyferth–Gilbert Reagent To Access Tetrahydro-1,2,4-triazinecarboxylate Esters"}])
      expect(subject.dates).to eq([{"date"=>"2020-04-08", "dateType"=>"Issued"}, {"date"=>"2020-06-16T23:13:36Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2020")
      expect(subject.publisher).to eq("Georg Thieme Verlag KG")
    end

    it "journal article with" do
      input = "https://doi.org/10.1111/nph.14619"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1111/nph.14619")
      expect(subject.url).to eq("http://doi.wiley.com/10.1111/nph.14619")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.length).to eq(3)
      expect(subject.creators.first).to eq("nameType"=>"Personal", "nameIdentifiers" => [{"nameIdentifier"=>"https://orcid.org/0000-0002-4156-3761", "nameIdentifierScheme"=>"ORCID", "schemeUri"=>"https://orcid.org"}], "name"=>"Dissmeyer, Nico", "givenName"=>"Nico", "familyName"=>"Dissmeyer", "affiliation" => [{"name"=>"Independent Junior Research Group on Protein Recognition and Degradation; Leibniz Institute of Plant Biochemistry (IPB); Weinberg 3 Halle (Saale) D-06120 Germany"}, {"name"=>"ScienceCampus Halle - Plant-based Bioeconomy; Betty-Heimann-Strasse 3 Halle (Saale) D-06120 Germany"}])
      expect(subject.titles).to eq([{"title"=>"Life and death of proteins after protease cleavage: protein degradation by the N-end rule pathway"}])
      expect(subject.rights_list).to eq([{"rightsUri"=>"http://doi.wiley.com/10.1002/tdm_license_1.1"}, {"rightsUri"=>"http://onlinelibrary.wiley.com/termsAndConditions#vor"}])
      expect(subject.dates).to include({"date"=>"2018-05", "dateType"=>"Issued"})
      expect(subject.publication_year).to eq("2018")
      expect(subject.publisher).to eq("Wiley")
      expect(subject.related_identifiers.length).to eq(49)
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"0028-646X", "relatedIdentifierType"=>"ISSN", "relationType"=>"IsPartOf", "resourceTypeGeneral"=>"Collection")
      expect(subject.related_identifiers.last).to eq("relatedIdentifier"=>"10.1002/pmic.201400530", "relatedIdentifierType"=>"DOI", "relationType"=>"References")
      expect(subject.container).to eq("firstPage"=>"929", "identifier"=>"0028-646X", "identifierType"=>"ISSN", "issue"=>"3", "lastPage"=>"935", "title"=>"New Phytologist", "type"=>"Journal", "volume"=>"218")
      expect(subject.agency).to eq("Crossref")
      expect(subject.date_registered).to eq("2018-08-03T11:45:49Z")
    end

    it "author literal" do
      input = "https://doi.org/10.1038/ng.3834"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.1038/ng.3834")
      expect(subject.url).to eq("http://www.nature.com/articles/ng.3834")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.length).to eq(14)
      expect(subject.creators.last).to eq("name"=>"GTEx Consortium", "nameType"=>"Organizational")
      expect(subject.titles).to eq([{"title"=>"The impact of structural variation on human gene expression"}])
      expect(subject.dates).to include({"date"=>"2017-04-03", "dateType"=>"Issued"})
      expect(subject.publication_year).to eq("2017")
      expect(subject.publisher).to eq("Springer Science and Business Media LLC")
      expect(subject.agency).to eq("Crossref")
      expect(subject.date_registered).to eq("2019-11-02T09:30:06Z")
    end

    it "posted content copernicus" do
      input = "https://doi.org/10.5194/CP-2020-95"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.url).to eq("https://cp.copernicus.org/preprints/cp-2020-95/")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"PostedContent", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.count).to eq(6)
      expect(subject.creators.first).to eq("nameType" => "Personal", "familyName" => "Shao",
        "givenName" => "Jun",
        "name" => "Shao, Jun",
        "nameIdentifiers" => [{"nameIdentifier"=>"https://orcid.org/0000-0001-6130-6474", "nameIdentifierScheme"=>"ORCID", "schemeUri"=>"https://orcid.org"}])
      expect(subject.titles).to eq([{"title"=>"The Atmospheric Bridge Communicated the δ&lt;sup&gt;13&lt;/sup&gt;C Declineduring the Last Deglaciation to the Global Upper Ocean"}])
      expect(subject.id).to eq("https://doi.org/10.5194/cp-2020-95")
      expect(subject.identifiers).to be_empty
      expect(subject.descriptions.first["description"]).to start_with("Abstract. During the early last glacial termination")
      expect(subject.dates).to include({"date"=>"2020-07-28", "dateType"=>"Issued"})
      expect(subject.publication_year).to eq("2020")
      expect(subject.publisher).to eq("Copernicus GmbH")
      expect(subject.agency).to eq("Crossref")
    end

    it "journal issue" do
      input = "https://doi.org/10.6002/ect.2015.0371"
      subject = Bolognese::Metadata.new(input: input)
      #expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.6002/ect.2015.0371")
      expect(subject.url).to eq("http://ectrx.org/forms/ectrxcontentshow.php?doi_id=10.6002/ect.2015.0371")
      expect(subject.types).to eq("bibtex"=>"misc", "citeproc"=>"article-journal", "resourceType"=>"JournalIssue", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"PublicationIssue")
      expect(subject.creators).to eq("name"=>":(unav)", "nameType"=>"Organizational")
      expect(subject.titles).to eq([{"title"=>":{unav)"}])
      expect(subject.dates).to eq([{"date"=>"2018-10", "dateType"=>"Issued"}, {"date"=>"2018-10-03T12:09:12Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2018")
      expect(subject.publisher).to eq("Baskent University")
      expect(subject.related_identifiers.length).to eq(1)
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"2146-8427", "relatedIdentifierType"=>"ISSN", "relationType"=>"IsPartOf", "resourceTypeGeneral"=>"Collection")
      expect(subject.container).to eq("identifier"=>"2146-8427", "identifierType"=>"ISSN", "issue"=>"5", "title"=>"Experimental and Clinical Transplantation", "type"=>"Journal", "volume"=>"16")
      expect(subject.agency).to eq("Crossref")
    end

    it "not found error" do
      input = "https://doi.org/10.7554/elife.01567x"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be false
      expect(subject.id).to eq("https://doi.org/10.7554/elife.01567x")
      expect(subject.doi).to eq("10.7554/elife.01567x")
      expect(subject.agency).to eq("Crossref")
      expect(subject.state).to eq("not_found")
    end
  end
end
