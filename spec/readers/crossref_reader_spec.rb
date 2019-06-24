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
      expect(subject.identifiers).to eq([{"identifier"=>"https://doi.org/10.7554/elife.01567", "identifierType"=>"DOI"}, {"identifier"=>"e01567", "identifierType"=>"Publisher ID"}])
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.url).to eq("https://elifesciences.org/articles/01567")
      expect(subject.creators.length).to eq(5)
      expect(subject.creators.first).to eq("nameType"=>"Personal", "name"=>"Sankar, Martial", "givenName"=>"Martial", "familyName"=>"Sankar")
      expect(subject.rights_list).to eq([{"rightsUri"=>"http://creativecommons.org/licenses/by/3.0"}])
      expect(subject.titles).to eq([{"title"=>"Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth"}])
      expect(subject.dates).to eq([{"date"=>"2014-02-11", "dateType"=>"Issued"}, {"date"=>"2018-08-23T13:41:49Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2014")
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
      expect(subject.identifiers).to eq([{"identifier"=>"https://doi.org/10.1371/journal.pone.0000030", "identifierType"=>"DOI"}, {"identifier"=>"10.1371/journal.pone.0000030", "identifierType"=>"Publisher ID"}])
      expect(subject.url).to eq("http://dx.plos.org/10.1371/journal.pone.0000030")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.length).to eq(5)
      expect(subject.creators.first).to eq("nameType"=>"Personal", "name"=>"Ralser, Markus", "givenName"=>"Markus", "familyName"=>"Ralser")
      expect(subject.contributors).to eq("contributorType"=>"Editor", "familyName"=>"Janbon", "givenName"=>"Guilhem", "name"=>"Janbon, Guilhem", "nameType"=>"Personal")
      expect(subject.titles).to eq([{"title"=>"Triose Phosphate Isomerase Deficiency Is Caused by Altered Dimerization–Not Catalytic Inactivity–of the Mutant Enzymes"}])
      expect(subject.rights_list).to eq([{"rightsUri"=>"http://creativecommons.org/licenses/by/4.0"}])
      expect(subject.dates).to eq([{"date"=>"2006-12-20", "dateType"=>"Issued"}, {"date"=>"2017-06-17T12:26:15Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2006")
      expect(subject.related_identifiers.length).to eq(62)
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"1932-6203", "relatedIdentifierType"=>"ISSN", "relationType"=>"IsPartOf", "resourceTypeGeneral"=>"Collection")
      expect(subject.related_identifiers.last).to eq("relatedIdentifier"=>"10.1056/nejm199109123251104", "relatedIdentifierType"=>"DOI", "relationType"=>"References")
      expect(subject.container).to eq("firstPage"=>"e30", "identifier"=>"1932-6203", "identifierType"=>"ISSN", "issue"=>"1", "title"=>"PLoS ONE", "type"=>"Journal", "volume"=>"1")
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
      expect(subject.identifiers).to eq([{"identifier"=>"https://doi.org/10.1101/097196", "identifierType"=>"DOI"}, {"identifier"=>"biorxiv;097196v2", "identifierType"=>"Publisher ID"}])
      expect(subject.descriptions.first["description"]).to start_with("This article presents a practical roadmap")
      expect(subject.dates).to eq([{"date"=>"2017-10-09", "dateType"=>"Issued"}, {"date"=>"2017-10-10T05:10:49Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2017")
      expect(subject.publisher).to eq("bioRxiv")
      expect(subject.agency).to eq("Crossref")
    end

    it "DOI with SICI DOI" do
      input = "https://doi.org/10.1890/0012-9658(2006)87[2832:tiopma]2.0.co;2"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifiers).to eq([{"identifier"=>"https://doi.org/10.1890/0012-9658(2006)87%255b2832:tiopma%255d2.0.co;2", "identifierType"=>"DOI"}])
      expect(subject.url).to eq("http://doi.wiley.com/10.1890/0012-9658(2006)87[2832:TIOPMA]2.0.CO;2")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators).to eq([{"nameType"=>"Personal", "name"=>"Fenton, A.", "givenName"=>"A.", "familyName"=>"Fenton"}, {"nameType"=>"Personal", "name"=>"Rands, S. A.", "givenName"=>"S. A.", "familyName"=>"Rands"}])
      expect(subject.rights_list).to eq([{"rightsUri"=>"http://doi.wiley.com/10.1002/tdm_license_1.1"}])
      expect(subject.titles).to eq([{"title"=>"THE IMPACT OF PARASITE MANIPULATION AND PREDATOR FORAGING BEHAVIOR ON PREDATOR–PREY COMMUNITIES"}])
      expect(subject.dates).to eq([{"date"=>"2006-11", "dateType"=>"Issued"}, {"date"=>"2018-08-02T21:20:01Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2006")
      expect(subject.related_identifiers.length).to eq(34)
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"0012-9658", "relatedIdentifierType"=>"ISSN", "relationType"=>"IsPartOf", "resourceTypeGeneral"=>"Collection")
      expect(subject.related_identifiers.last).to eq("relatedIdentifier"=>"10.1098/rspb.2002.2213", "relatedIdentifierType"=>"DOI", "relationType"=>"References")
      expect(subject.container).to eq("firstPage"=>"2832", "identifier"=>"0012-9658", "identifierType"=>"ISSN", "issue"=>"11", "lastPage"=>"2841", "title"=>"Ecology", "type"=>"Journal", "volume"=>"87")
      expect(subject.agency).to eq("Crossref")
    end

    it "DOI with ORCID ID" do
      input = "https://doi.org/10.1155/2012/291294"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifiers).to eq([{"identifier"=>"https://doi.org/10.1155/2012/291294", "identifierType"=>"DOI"}])
      expect(subject.url).to eq("http://www.hindawi.com/journals/pm/2012/291294/")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.length).to eq(7)
      expect(subject.creators[2]).to eq("nameType"=>"Personal", "nameIdentifiers" => [{"nameIdentifier"=>"https://orcid.org/0000-0003-2043-4925", "nameIdentifierScheme"=>"ORCID", "schemeUri"=>"https://orcid.org"}], "name"=>"Hernandez, Beatriz", "givenName"=>"Beatriz", "familyName"=>"Hernandez")
      expect(subject.rights_list).to eq([{"rightsUri"=>"http://creativecommons.org/licenses/by/3.0"}])
      expect(subject.titles).to eq([{"title"=>"Delineating a Retesting Zone Using Receiver Operating Characteristic Analysis on Serial QuantiFERON Tuberculosis Test Results in US Healthcare Workers"}])
      expect(subject.dates).to eq([{"date"=>"2012", "dateType"=>"Issued"}, {"date"=>"2016-08-02T18:42:41Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2012")
      expect(subject.related_identifiers.length).to eq(18)
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"2090-1836", "relatedIdentifierType"=>"ISSN", "relationType"=>"IsPartOf", "resourceTypeGeneral"=>"Collection")
      expect(subject.related_identifiers.last).to eq("relatedIdentifier"=>"10.1378/chest.12-0045", "relatedIdentifierType"=>"DOI", "relationType"=>"References")
      expect(subject.container).to eq("firstPage"=>"1", "identifier"=>"2090-1836", "identifierType"=>"ISSN", "lastPage"=>"7", "title"=>"Pulmonary Medicine", "type"=>"Journal", "volume"=>"2012")
      expect(subject.agency).to eq("Crossref")
    end

    it "date in future" do
      input = "https://doi.org/10.1016/j.ejphar.2015.03.018"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifiers).to eq([{"identifier"=>"https://doi.org/10.1016/j.ejphar.2015.03.018", "identifierType"=>"DOI"}, {"identifier"=>"S0014299915002332", "identifierType"=>"Publisher ID"}])
      expect(subject.url).to eq("https://linkinghub.elsevier.com/retrieve/pii/S0014299915002332")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.length).to eq(10)
      expect(subject.creators.first).to eq("nameType"=>"Personal", "name"=>"Beck, Sarah E.", "givenName"=>"Sarah E.", "familyName"=>"Beck")
      expect(subject.titles).to eq([{"title"=>"Paving the path to HIV neurotherapy: Predicting SIV CNS disease"}])
      expect(subject.dates).to eq([{"date"=>"2015-07", "dateType"=>"Issued"}, {"date"=>"2018-09-23T21:22:53Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2015")
      expect(subject.related_identifiers).to eq([{"relatedIdentifier"=>"00142999", "relatedIdentifierType"=>"ISSN", "relationType"=>"IsPartOf", "resourceTypeGeneral"=>"Collection"}])
      expect(subject.container).to eq("firstPage"=>"303", "identifier"=>"00142999", "identifierType"=>"ISSN", "lastPage"=>"312", "title"=>"European Journal of Pharmacology", "type"=>"Journal", "volume"=>"759")
      expect(subject.agency).to eq("Crossref")
    end

    it "vor with url" do
      input = "https://doi.org/10.1038/hdy.2013.26"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifiers).to eq([{"identifier"=>"https://doi.org/10.1038/hdy.2013.26", "identifierType"=>"DOI"}])
      expect(subject.url).to eq("http://www.nature.com/articles/hdy201326")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.length).to eq(2)
      expect(subject.creators.first).to eq("familyName"=>"Gross", "givenName"=>"J B", "name"=>"Gross, J B", "nameType"=>"Personal")
      expect(subject.titles).to eq([{"title"=>"Albinism in phylogenetically and geographically distinct populations of Astyanax cavefish arises through the same loss-of-function Oca2 allele"}])
      expect(subject.dates).to eq([{"date"=>"2013-04-10", "dateType"=>"Issued"}, {"date"=>"2019-04-16T16:25:36Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2013")
      expect(subject.related_identifiers.size).to eq(35)
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"0018-067X", "relatedIdentifierType"=>"ISSN", "relationType"=>"IsPartOf", "resourceTypeGeneral"=>"Collection")
      expect(subject.container).to eq("firstPage"=>"122", "identifier"=>"0018-067X", "identifierType"=>"ISSN", "issue"=>"2", "lastPage"=>"130", "title"=>"Heredity", "type"=>"Journal", "volume"=>"111")
      expect(subject.agency).to eq("Crossref")
    end

    it "dataset" do
      input = "10.2210/pdb4hhb/pdb"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifiers).to eq([{"identifier"=>"https://doi.org/10.2210/pdb4hhb/pdb", "identifierType"=>"DOI"}])
      expect(subject.url).to eq("ftp://ftp.wwpdb.org/pub/pdb/data/structures/divided/pdb/hh/pdb4hhb.ent.gz")
      expect(subject.types).to eq("bibtex"=>"misc", "citeproc"=>"article-journal", "resourceType"=>"SaComponent", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.length).to eq(2)
      expect(subject.creators.first).to eq("nameType"=>"Personal", "name"=>"Fermi, G.", "givenName"=>"G.", "familyName"=>"Fermi")
      expect(subject.titles).to eq([{"title"=>"THE CRYSTAL STRUCTURE OF HUMAN DEOXYHAEMOGLOBIN AT 1.74 ANGSTROMS RESOLUTION"}])
      expect(subject.descriptions).to eq([{"description"=>"x-ray diffraction structure", "descriptionType"=>"Other"}])
      expect(subject.dates).to eq([{"date"=>"1984-07-17", "dateType"=>"Issued"}, {"date"=>"2014-05-27T16:45:59Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("1984")
      expect(subject.publisher).to eq("(:unav)")
      expect(subject.agency).to eq("Crossref")
    end

    it "book chapter" do
      input = "https://doi.org/10.1007/978-3-662-46370-3_13"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifiers).to eq([{"identifier"=>"https://doi.org/10.1007/978-3-662-46370-3_13", "identifierType"=>"DOI"}])
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

    it "journal article with" do
      input = "https://doi.org/10.1111/nph.14619"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifiers).to eq([{"identifier"=>"https://doi.org/10.1111/nph.14619", "identifierType"=>"DOI"}])
      expect(subject.url).to eq("http://doi.wiley.com/10.1111/nph.14619")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(subject.creators.length).to eq(3)
      expect(subject.creators.first).to eq("nameType"=>"Personal", "nameIdentifiers" => [{"nameIdentifier"=>"https://orcid.org/0000-0002-4156-3761", "nameIdentifierScheme"=>"ORCID", "schemeUri"=>"https://orcid.org"}], "name"=>"Dissmeyer, Nico", "givenName"=>"Nico", "familyName"=>"Dissmeyer")
      expect(subject.titles).to eq([{"title"=>"Life and death of proteins after protease cleavage: protein degradation by the N-end rule pathway"}])
      expect(subject.rights_list).to eq([{"rightsUri"=>"http://doi.wiley.com/10.1002/tdm_license_1.1"}, {"rightsUri"=>"http://onlinelibrary.wiley.com/termsAndConditions"}])
      expect(subject.dates).to eq([{"date"=>"2018-05", "dateType"=>"Issued"}, {"date"=>"2018-08-07T05:52:14Z", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2018")
      expect(subject.related_identifiers.length).to eq(49)
      expect(subject.related_identifiers.first).to eq("relatedIdentifier"=>"0028646X", "relatedIdentifierType"=>"ISSN", "relationType"=>"IsPartOf", "resourceTypeGeneral"=>"Collection")
      expect(subject.related_identifiers.last).to eq("relatedIdentifier"=>"10.1002/pmic.201400530", "relatedIdentifierType"=>"DOI", "relationType"=>"References")
      expect(subject.container).to eq("firstPage"=>"929", "identifier"=>"0028646X", "identifierType"=>"ISSN", "issue"=>"3", "lastPage"=>"935", "title"=>"New Phytologist", "type"=>"Journal", "volume"=>"218")
      expect(subject.agency).to eq("Crossref")
    end

    it "not found error" do
      input = "https://doi.org/10.7554/elife.01567x"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be false
      expect(subject.identifiers).to eq([{"identifier"=>"https://doi.org/10.7554/elife.01567x", "identifierType"=>"DOI"}])
      expect(subject.doi).to eq("10.7554/elife.01567x")
      expect(subject.agency).to eq("Crossref")
      expect(subject.state).to eq("not_found")
    end
  end
end
