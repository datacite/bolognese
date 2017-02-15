require 'spec_helper'

describe Bolognese::Crossref, vcr: true do
  context "get metadata" do
    let(:id) { "https://doi.org/10.1371/journal.pone.0000030" }

    subject { Bolognese::Crossref.new(id) }

    it "journal article" do
      expect(subject.id).to eq(id)
      expect(subject.type).to eq("ScholarlyArticle")
      expect(subject.additional_type).to eq("JournalArticle")
      expect(subject.author).to eq([{"@type"=>"Person", "givenName"=>"Markus", "familyName"=>"Ralser"},
                                    {"@type"=>"Person", "givenName"=>"Gino", "familyName"=>"Heeren"},
                                    {"@type"=>"Person", "givenName"=>"Michael", "familyName"=>"Breitenbach"},
                                    {"@type"=>"Person", "givenName"=>"Hans", "familyName"=>"Lehrach"},
                                    {"@type"=>"Person", "givenName"=>"Sylvia", "familyName"=>"Krobitsch"}])
      expect(subject.editor).to eq([{"@type"=>"Person", "givenName"=>"Guilhem", "familyName"=>"Janbon"}])
      expect(subject.name).to eq("Triose Phosphate Isomerase Deficiency Is Caused by Altered Dimerization–Not Catalytic Inactivity–of the Mutant Enzymes")
      expect(subject.license).to eq("http://creativecommons.org/licenses/by/4.0/")
      expect(subject.date_published).to eq("2006-12-20")
      expect(subject.date_modified).to eq("2016-12-31T21:37:08Z")
      expect(subject.page_start).to eq("e30")
      expect(subject.is_part_of).to eq("@type"=>"Periodical", "name"=>"PLoS ONE", "issn"=>"1932-6203")
      expect(subject.provider).to eq("@type"=>"Organization", "name"=>"Crossref")
    end

    it "posted_content" do
      id = "https://doi.org/10.1101/097196"
      subject = Bolognese::Crossref.new(id)
      expect(subject.id).to eq(id)
      expect(subject.type).to eq("CreativeWork")
      expect(subject.additional_type).to eq("PostedContent")
      expect(subject.author.count).to eq(10)
      expect(subject.author.last).to eq("@type"=>"Person", "@id"=>"http://orcid.org/0000-0003-4060-7360", "givenName"=>"Timothy", "familyName"=>"Clark")
      expect(subject.name).to eq("A Data Citation Roadmap for Scholarly Data Repositories")
      expect(subject.alternate_name).to eq("biorxiv;097196v1")
      expect(subject.description).to start_with("This article presents a practical roadmap")
      expect(subject.date_published).to eq("2016-12-28")
      expect(subject.date_modified).to eq("2016-12-29T00:10:20Z")
      expect(subject.is_part_of).to be_nil
      expect(subject.provider).to eq("@type"=>"Organization", "name"=>"Crossref")
    end

    it "DOI with data citation" do
      id = "10.7554/eLife.01567"
      subject = Bolognese::Crossref.new(id)
      expect(subject.id).to eq("https://doi.org/10.7554/elife.01567")
      expect(subject.type).to eq("ScholarlyArticle")
      expect(subject.additional_type).to eq("JournalArticle")
      expect(subject.author).to eq([{"@type"=>"Person", "givenName"=>"Martial", "familyName"=>"Sankar"},
                                    {"@type"=>"Person", "givenName"=>"Kaisa", "familyName"=>"Nieminen"},
                                    {"@type"=>"Person", "givenName"=>"Laura", "familyName"=>"Ragni"},
                                    {"@type"=>"Person", "givenName"=>"Ioannis", "familyName"=>"Xenarios"},
                                    {"@type"=>"Person", "givenName"=>"Christian S", "familyName"=>"Hardtke"}])
      expect(subject.license).to eq("http://creativecommons.org/licenses/by/3.0/")
      expect(subject.name).to eq("Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
      expect(subject.date_published).to eq("2014-02-11")
      expect(subject.date_modified).to eq("2015-08-11T05:35:02Z")
      expect(subject.is_part_of).to eq("@type"=>"Periodical", "name"=>"eLife", "issn"=>"2050-084X")
      expect(subject.citation.count).to eq(25)
      expect(subject.citation[19]).to eq("@type"=>"CreativeWork", "@id"=>"https://doi.org/10.5061/dryad.b835k")
      expect(subject.provider).to eq("@type"=>"Organization", "name"=>"Crossref")
    end

    it "DOI test" do
      id = "10.12688/f1000research.2-147.v1"
      subject = Bolognese::Crossref.new(id)
      expect(subject.as_schema_org).to eq(25)
    end



    it "DOI with SICI DOI" do
      id = "https://doi.org/10.1890/0012-9658(2006)87[2832:tiopma]2.0.co;2"
      subject = Bolognese::Crossref.new(id)
      expect(subject.id).to eq("https://doi.org/10.1890/0012-9658(2006)87%5B2832:tiopma%5D2.0.co;2")
      expect(subject.type).to eq("ScholarlyArticle")
      expect(subject.additional_type).to eq("JournalArticle")
      expect(subject.author).to eq([{"@type"=>"Person", "givenName"=>"A.", "familyName"=>"Fenton"}, {"@type"=>"Person", "givenName"=>"S. A.", "familyName"=>"Rands"}])
      expect(subject.license).to eq("http://doi.wiley.com/10.1002/tdm_license_1")
      expect(subject.name).to eq("THE IMPACT OF PARASITE MANIPULATION AND PREDATOR FORAGING BEHAVIOR ON PREDATOR–PREY COMMUNITIES")
      expect(subject.date_published).to eq("2006-11")
      expect(subject.date_modified).to eq("2016-10-04T17:20:17Z")
      expect(subject.page_start).to eq("2832")
      expect(subject.page_end).to eq("2841")
      expect(subject.is_part_of).to eq("@type"=>"Periodical", "name"=>"Ecology", "issn"=>"0012-9658")
      expect(subject.provider).to eq("@type"=>"Organization", "name"=>"Crossref")
    end

    it "date in future" do
      id = "https://doi.org/10.1016/j.ejphar.2015.03.018"
      subject = Bolognese::Crossref.new(id)
      expect(subject.id).to eq(id)
      expect(subject.type).to eq("ScholarlyArticle")
      expect(subject.additional_type).to eq("JournalArticle")
      expect(subject.author).to eq([{"@type"=>"Person", "givenName"=>"Sarah E.", "familyName"=>"Beck"},
                                    {"@type"=>"Person", "givenName"=>"Suzanne E.", "familyName"=>"Queen"},
                                    {"@type"=>"Person", "givenName"=>"Kenneth W.", "familyName"=>"Witwer"},
                                    {"@type"=>"Person", "givenName"=>"Kelly A.", "familyName"=>"Metcalf Pate"},
                                    {"@type"=>"Person", "givenName"=>"Lisa M.", "familyName"=>"Mangus"},
                                    {"@type"=>"Person", "givenName"=>"Lucio", "familyName"=>"Gama"},
                                    {"@type"=>"Person", "givenName"=>"Robert J.", "familyName"=>"Adams"},
                                    {"@type"=>"Person", "givenName"=>"Janice E.", "familyName"=>"Clements"},
                                    {"@type"=>"Person", "givenName"=>"M.", "familyName"=>"Christine Zink"},
                                    {"@type"=>"Person", "givenName"=>"Joseph L.", "familyName"=>"Mankowski"}])
      expect(subject.name).to eq("Paving the path to HIV neurotherapy: Predicting SIV CNS disease")
      expect(subject.date_published).to eq("2015-07")
      expect(subject.date_modified).to eq("2016-08-20T02:19:38Z")
      expect(subject.is_part_of).to eq("@type"=>"Periodical", "name"=>"European Journal of Pharmacology", "issn"=>"00142999")
      expect(subject.provider).to eq("@type"=>"Organization", "name"=>"Crossref")
    end

    it "not found error" do
      id = "https://doi.org/10.1371/journal.pone.0000030x"
      subject = Bolognese::Crossref.new(id)
      expect(subject.id).to eq(id)
      expect(subject.exists?).to be false
    end
  end
end
