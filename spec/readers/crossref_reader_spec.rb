require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  let(:input) { "10.7554/eLife.01567" }

  subject { Bolognese::Metadata.new(input: input) }

  context "get crossref metadata" do
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
      input = "https://doi.org/10.1371/journal.pone.0000030"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.id).to eq(input)
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
      expect(subject.pagination).to eq("e30")
      expect(subject.is_part_of).to eq("type"=>"Periodical", "name"=>"PLoS ONE", "issn"=>"1932-6203")
      expect(subject.provider).to eq("Crossref")
    end

    it "posted_content" do
      input = "https://doi.org/10.1101/097196"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.id).to eq(input)
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
      input = "https://doi.org/10.1890/0012-9658(2006)87[2832:tiopma]2.0.co;2"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.id).to eq("https://doi.org/10.1890/0012-9658(2006)87%5B2832:tiopma%5D2.0.co;2")
      expect(subject.url).to eq("http://doi.wiley.com/10.1890/0012-9658(2006)87[2832:TIOPMA]2.0.CO;2")
      expect(subject.type).to eq("ScholarlyArticle")
      expect(subject.additional_type).to eq("JournalArticle")
      expect(subject.resource_type_general).to eq("Text")
      expect(subject.author).to eq([{"type"=>"Person", "name"=>"A. Fenton", "givenName"=>"A.", "familyName"=>"Fenton"}, {"type"=>"Person", "name"=>"S. A. Rands", "givenName"=>"S. A.", "familyName"=>"Rands"}])
      expect(subject.license).to eq("url"=>"http://doi.wiley.com/10.1002/tdm_license_1.1")
      expect(subject.title).to eq("THE IMPACT OF PARASITE MANIPULATION AND PREDATOR FORAGING BEHAVIOR ON PREDATOR–PREY COMMUNITIES")
      expect(subject.date_published).to eq("2006-11")
      expect(subject.date_modified).to eq("2017-04-01T00:47:57Z")
      expect(subject.pagination).to eq("2832-2841")
      expect(subject.is_part_of).to eq("type"=>"Periodical", "name"=>"Ecology", "issn"=>"0012-9658")
      expect(subject.provider).to eq("Crossref")
    end

    it "DOI with ORCID ID" do
      input = "https://doi.org/10.1155/2012/291294"
      subject = Bolognese::Metadata.new(input: input)
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
      expect(subject.pagination).to eq("1-7")
      expect(subject.is_part_of).to eq("type"=>"Periodical", "name"=>"Pulmonary Medicine", "issn"=>["2090-1836", "2090-1844"])
      expect(subject.provider).to eq("Crossref")
    end

    it "date in future" do
      input = "https://doi.org/10.1016/j.ejphar.2015.03.018"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.id).to eq(input)
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
      input = "https://doi.org/10.7554/elife.01567x"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.id).to be_nil
      expect(subject.exists?).to be false
    end
  end
end
