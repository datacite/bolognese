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
      expect(subject.identifier).to eq("https://doi.org/10.7554/elife.01567")
      expect(subject.type).to eq("ScholarlyArticle")
      expect(subject.b_url).to eq("https://elifesciences.org/articles/01567")
      expect(subject.additional_type).to eq("JournalArticle")
      expect(subject.bibtex_type).to eq("article")
      expect(subject.ris_type).to eq("JOUR")
      expect(subject.citeproc_type).to eq("article-journal")
      expect(subject.resource_type_general).to eq("Text")
      expect(subject.author.length).to eq(5)
      expect(subject.author.first).to eq("type"=>"Person", "name"=>"Martial Sankar", "givenName"=>"Martial", "familyName"=>"Sankar")
      expect(subject.license).to eq("id"=>"http://creativecommons.org/licenses/by/3.0")
      expect(subject.title).to eq("Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
      expect(subject.date_published).to eq("2014-02-11")
      expect(subject.publication_year).to eq(2014)
      expect(subject.date_modified).to eq("2017-10-18T19:09:43Z")
      expect(subject.is_part_of).to eq("type"=>"Periodical", "title"=>"eLife", "issn"=>"2050-084X")
      expect(subject.container_title).to eq("eLife")
      expect(subject.references.count).to eq(26)
      expect(subject.references[20]).to eq("id"=>"https://doi.org/10.5061/dryad.b835k", "type"=>"CreativeWork", "title" => "Data from: Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
      expect(subject.funding).to eq([{"type"=>"Organization", "name"=>"SystemsX"},
                                     {"type"=>"Organization",
                                      "id"=>"https://doi.org/10.13039/501100003043",
                                      "name"=>"EMBO"},
                                     {"type"=>"Organization",
                                      "id"=>"https://doi.org/10.13039/501100001711",
                                      "name"=>"Swiss National Science Foundation"},
                                     {"type"=>"Organization",
                                      "id"=>"https://doi.org/10.13039/501100006390",
                                      "name"=>"University of Lausanne"}])
      expect(subject.service_provider).to eq("Crossref")
    end

    it "journal article" do
      input = "https://doi.org/10.1371/journal.pone.0000030"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq(input)
      expect(subject.b_url).to eq("http://dx.plos.org/10.1371/journal.pone.0000030")
      expect(subject.type).to eq("ScholarlyArticle")
      expect(subject.additional_type).to eq("JournalArticle")
      expect(subject.bibtex_type).to eq("article")
      expect(subject.ris_type).to eq("JOUR")
      expect(subject.citeproc_type).to eq("article-journal")
      expect(subject.resource_type_general).to eq("Text")
      expect(subject.author.length).to eq(5)
      expect(subject.author.first).to eq("type"=>"Person", "name"=>"Markus Ralser", "givenName"=>"Markus", "familyName"=>"Ralser")
      expect(subject.editor).to eq("type"=>"Person", "name"=>"Guilhem Janbon", "givenName"=>"Guilhem", "familyName"=>"Janbon")
      expect(subject.title).to eq("Triose Phosphate Isomerase Deficiency Is Caused by Altered Dimerization–Not Catalytic Inactivity–of the Mutant Enzymes")
      expect(subject.license).to eq("id"=>"http://creativecommons.org/licenses/by/4.0")
      expect(subject.date_published).to eq("2006-12-20")
      expect(subject.publication_year).to eq(2006)
      expect(subject.date_modified).to eq("2017-06-17T12:26:15Z")
      expect(subject.first_page).to eq("e30")
      expect(subject.is_part_of).to eq("type"=>"Periodical", "title"=>"PLoS ONE", "issn"=>"1932-6203")
      expect(subject.container_title).to eq("PLoS ONE")
      expect(subject.service_provider).to eq("Crossref")
    end

    it "posted_content" do
      input = "https://doi.org/10.1101/097196"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq(input)
      expect(subject.b_url).to eq("http://biorxiv.org/lookup/doi/10.1101/097196")
      expect(subject.type).to eq("ScholarlyArticle")
      expect(subject.additional_type).to eq("PostedContent")
      expect(subject.bibtex_type).to eq("article")
      expect(subject.ris_type).to eq("JOUR")
      expect(subject.citeproc_type).to eq("article-journal")
      expect(subject.resource_type_general).to eq("Text")
      expect(subject.author.count).to eq(11)
      expect(subject.author.last).to eq("type"=>"Person", "id"=>"http://orcid.org/0000-0003-4060-7360", "name"=>"Timothy Clark", "givenName"=>"Timothy", "familyName"=>"Clark")
      expect(subject.title).to eq("A Data Citation Roadmap for Scholarly Data Repositories")
      expect(subject.alternate_identifier).to eq("biorxiv;097196v2")
      expect(subject.description["text"]).to start_with("This article presents a practical roadmap")
      expect(subject.date_published).to eq("2017-10-09")
      expect(subject.date_modified).to eq("2017-10-10T05:10:49Z")
      expect(subject.is_part_of).to be_nil
      expect(subject.publisher).to eq("bioRxiv")
      expect(subject.service_provider).to eq("Crossref")
    end

    it "DOI with SICI DOI" do
      input = "https://doi.org/10.1890/0012-9658(2006)87[2832:tiopma]2.0.co;2"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.1890/0012-9658(2006)87%5B2832:tiopma%5D2.0.co;2")
      expect(subject.b_url).to eq("http://doi.wiley.com/10.1890/0012-9658(2006)87[2832:TIOPMA]2.0.CO;2")
      expect(subject.type).to eq("ScholarlyArticle")
      expect(subject.additional_type).to eq("JournalArticle")
      expect(subject.resource_type_general).to eq("Text")
      expect(subject.author).to eq([{"type"=>"Person", "name"=>"A. Fenton", "givenName"=>"A.", "familyName"=>"Fenton"}, {"type"=>"Person", "name"=>"S. A. Rands", "givenName"=>"S. A.", "familyName"=>"Rands"}])
      expect(subject.license).to eq("id"=>"http://doi.wiley.com/10.1002/tdm_license_1.1")
      expect(subject.title).to eq("THE IMPACT OF PARASITE MANIPULATION AND PREDATOR FORAGING BEHAVIOR ON PREDATOR–PREY COMMUNITIES")
      expect(subject.date_published).to eq("2006-11")
      expect(subject.date_modified).to eq("2017-04-01T06:47:57Z")
      expect(subject.first_page).to eq("2832")
      expect(subject.last_page).to eq("2841")
      expect(subject.is_part_of).to eq("type"=>"Periodical", "title"=>"Ecology", "issn"=>"0012-9658")
      expect(subject.container_title).to eq("Ecology")
      expect(subject.service_provider).to eq("Crossref")
    end

    it "DOI with ORCID ID" do
      input = "https://doi.org/10.1155/2012/291294"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.1155/2012/291294")
      expect(subject.b_url).to eq("http://www.hindawi.com/journals/pm/2012/291294/")
      expect(subject.type).to eq("ScholarlyArticle")
      expect(subject.additional_type).to eq("JournalArticle")
      expect(subject.resource_type_general).to eq("Text")
      expect(subject.author.length).to eq(7)
      expect(subject.author[2]).to eq("type"=>"Person", "id"=>"http://orcid.org/0000-0003-2043-4925", "name"=>"Beatriz Hernandez", "givenName"=>"Beatriz", "familyName"=>"Hernandez")
      expect(subject.license).to eq("id"=>"http://creativecommons.org/licenses/by/3.0")
      expect(subject.title).to eq("Delineating a Retesting Zone Using Receiver Operating Characteristic Analysis on Serial QuantiFERON Tuberculosis Test Results in US Healthcare Workers")
      expect(subject.date_published).to eq("2012")
      expect(subject.date_modified).to eq("2016-08-02T18:42:41Z")
      expect(subject.first_page).to eq("1")
      expect(subject.last_page).to eq("7")
      expect(subject.is_part_of).to eq("type"=>"Periodical", "title"=>"Pulmonary Medicine", "issn"=>"2090-1836")
      expect(subject.container_title).to eq("Pulmonary Medicine")
      expect(subject.service_provider).to eq("Crossref")
    end

    it "date in future" do
      input = "https://doi.org/10.1016/j.ejphar.2015.03.018"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq(input)
      expect(subject.b_url).to eq("http://linkinghub.elsevier.com/retrieve/pii/S0014299915002332")
      expect(subject.type).to eq("ScholarlyArticle")
      expect(subject.additional_type).to eq("JournalArticle")
      expect(subject.resource_type_general).to eq("Text")
      expect(subject.author.length).to eq(10)
      expect(subject.author.first).to eq("type"=>"Person", "name"=>"Sarah E. Beck", "givenName"=>"Sarah E.", "familyName"=>"Beck")
      expect(subject.title).to eq("Paving the path to HIV neurotherapy: Predicting SIV CNS disease")
      expect(subject.date_published).to eq("2015-07")
      expect(subject.date_modified).to eq("2017-06-23T08:44:48Z")
      expect(subject.is_part_of).to eq("type"=>"Periodical", "title"=>"European Journal of Pharmacology", "issn"=>"00142999")
      expect(subject.container_title).to eq("European Journal of Pharmacology")
      expect(subject.service_provider).to eq("Crossref")
    end

    it "dataset" do
      input = "10.2210/pdb4hhb/pdb"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.2210/pdb4hhb/pdb")
      expect(subject.b_url).to eq("ftp://ftp.wwpdb.org/pub/pdb/data/structures/divided/pdb/hh/pdb4hhb.ent.gz")
      expect(subject.type).to eq("ScholarlyArticle")
      expect(subject.additional_type).to eq("SaComponent")
      expect(subject.resource_type_general).to eq("Text")
      expect(subject.bibtex_type).to eq("misc")
      expect(subject.ris_type).to eq("JOUR")
      expect(subject.citeproc_type).to eq("article-journal")
      expect(subject.author.length).to eq(2)
      expect(subject.author.first).to eq("type"=>"Person", "name"=>"G. Fermi", "givenName"=>"G.", "familyName"=>"Fermi")
      expect(subject.title).to eq("THE CRYSTAL STRUCTURE OF HUMAN DEOXYHAEMOGLOBIN AT 1.74 ANGSTROMS RESOLUTION")
      expect(subject.description).to eq("x-ray diffraction structure")
      expect(subject.date_published).to eq("1984-07-17")
      expect(subject.publication_year).to eq(1984)
      expect(subject.date_modified).to eq("2014-05-27T16:45:59Z")
      expect(subject.publisher).to eq("(:unav)")
      expect(subject.service_provider).to eq("Crossref")
    end

    it "book chapter" do
      input = "https://doi.org/10.1007/978-3-662-46370-3_13"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.1007/978-3-662-46370-3_13")
      expect(subject.b_url).to eq("http://link.springer.com/10.1007/978-3-662-46370-3_13")
      expect(subject.type).to eq("Chapter")
      expect(subject.additional_type).to eq("BookChapter")
      expect(subject.resource_type_general).to eq("Text")
      expect(subject.bibtex_type).to eq("inbook")
      expect(subject.ris_type).to eq("CHAP")
      expect(subject.citeproc_type).to eq("chapter")
      expect(subject.author.length).to eq(2)
      expect(subject.author.first).to eq("type"=>"Person", "name"=>"Ronald L. Diercks", "givenName"=>"Ronald L.", "familyName"=>"Diercks")
      expect(subject.title).to eq("Clinical Symptoms and Physical Examinations")
      expect(subject.date_published).to eq("2015")
      expect(subject.date_modified).to eq("2015-04-14T02:31:13Z")
      expect(subject.publisher).to eq("Springer Berlin Heidelberg")
      expect(subject.service_provider).to eq("Crossref")
    end

    it "journal article with" do
      input = "https://doi.org/10.1111/nph.14619"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq(input)
      expect(subject.b_url).to eq("http://doi.wiley.com/10.1111/nph.14619")
      expect(subject.type).to eq("ScholarlyArticle")
      expect(subject.additional_type).to eq("JournalArticle")
      expect(subject.resource_type_general).to eq("Text")
      expect(subject.author.length).to eq(3)
      expect(subject.author.first).to eq("type"=>"Person", "id"=>"http://orcid.org/0000-0002-4156-3761", "name"=>"Nico Dissmeyer", "givenName"=>"Nico", "familyName"=>"Dissmeyer")
      expect(subject.title).to eq("Life and death of proteins after protease cleavage: protein degradation by the N-end rule pathway")
      expect(subject.license).to eq([{"id"=>"http://doi.wiley.com/10.1002/tdm_license_1.1"}, {"id"=>"http://onlinelibrary.wiley.com/termsAndConditions"}])
      expect(subject.date_published).to eq("2018-05")
      expect(subject.date_modified).to eq("2018-04-16T09:28:43Z")
      expect(subject.is_part_of).to eq("type"=>"Periodical", "title"=>"New Phytologist", "issn"=>"0028646X")
      expect(subject.container_title).to eq("New Phytologist")
      expect(subject.service_provider).to eq("Crossref")
    end

    it "not found error" do
      input = "https://doi.org/10.7554/elife.01567x"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be false
      expect(subject.identifier).to eq("https://doi.org/10.7554/elife.01567x")
      expect(subject.doi).to eq("10.7554/elife.01567x")
      expect(subject.service_provider).to eq("Crossref")
      expect(subject.state).to eq("not_found")
    end
  end
end
