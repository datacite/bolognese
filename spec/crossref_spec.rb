require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  context "crossref metadata" do
    before(:each) { allow(Time).to receive(:now).and_return(Time.mktime(2015, 6, 25)) }

    let(:id) { "10.1371/journal.pone.0000030" }
    let(:service) { "crossref" }

    subject { Bolognese::Metadata.new(id: id, service: service) }

    it "get_crossref_metadata" do
      response = subject
      expect(response["@id"]).to eq("https://doi.org/#{crossref_doi}")
      expect(response["@type"]).to eq("ScholarlyArticle")
      expect(response["author"]).to eq([{"@type"=>"Person", "givenName"=>"Markus", "familyName"=>"Ralser"},
                                       {"@type"=>"Person", "givenName"=>"Gino", "familyName"=>"Heeren"},
                                       {"@type"=>"Person", "givenName"=>"Michael", "familyName"=>"Breitenbach"},
                                       {"@type"=>"Person", "givenName"=>"Hans", "familyName"=>"Lehrach"},
                                       {"@type"=>"Person", "givenName"=>"Sylvia", "familyName"=>"Krobitsch"}])
      expect(response["name"]).to eq("Triose Phosphate Isomerase Deficiency Is Caused by Altered Dimerization–Not Catalytic Inactivity–of the Mutant Enzymes")
      expect(response["datePublished"]).to eq("2006-12-20")
      expect(response["dateModified"]).to eq("2016-12-31T21:37:08Z")
      expect(response["isPartOf"]).to eq("@type"=>"Periodical", "name"=>"PLoS ONE", "issn"=>"1932-6203")
      expect(response["provider"]).to eq("@type"=>"Organization", "name"=>"Crossref")
    end

    it "get_crossref_metadata with ORCID IDs" do
      id = "10.1101/097196"
      response = subject.get_crossref_metadata(doi)
      expect(response["@id"]).to eq("https://doi.org/#{doi}")
      expect(response["@type"]).to eq("CreativeWork")
      #expect(response["author"]).to eq([{"given"=>"Markus", "family"=>"Ralser"}, {"given"=>"Gino", "family"=>"Heeren"}, {"given"=>"Michael", "family"=>"Breitenbach"}, {"given"=>"Hans", "family"=>"Lehrach"}, {"given"=>"Sylvia", "family"=>"Krobitsch"}])
      expect(response["name"]).to eq("Triose Phosphate Isomerase Deficiency Is Caused by Altered Dimerization–Not Catalytic Inactivity–of the Mutant Enzymes")
      expect(response["datePublished"]).to eq("2006-12-20")
      expect(response["dateModified"]).to eq("2016-12-31T21:37:08Z")
      expect(response["isPartOf"]).to eq("@type"=>"Periodical", "name"=>"PLoS ONE", "issn"=>"1932-6203")
      expect(response["provider"]).to eq("@type"=>"Organization", "name"=>"Crossref")
    end

    it "get_crossref_metadata with SICI DOI" do
      id = "10.1890/0012-9658(2006)87[2832:tiopma]2.0.co;2"
      response = subject
      expect(response["@id"]).to eq(subject.doi_as_url(doi))
      expect(response["@type"]).to eq("ScholarlyArticle")
      expect(response["author"]).to eq([{"@type"=>"Person", "givenName"=>"A.", "familyName"=>"Fenton"}, {"@type"=>"Person", "givenName"=>"S. A.", "familyName"=>"Rands"}])
      expect(response["name"]).to eq("THE IMPACT OF PARASITE MANIPULATION AND PREDATOR FORAGING BEHAVIOR ON PREDATOR–PREY COMMUNITIES")
      expect(response["datePublished"]).to eq("2006-11")
      expect(response["dateModified"]).to eq("2016-10-04T17:20:17Z")
      expect(response["isPartOf"]).to eq("@type"=>"Periodical", "name"=>"Ecology", "issn"=>"0012-9658")
      expect(response["provider"]).to eq("@type"=>"Organization", "name"=>"Crossref")
    end

    it "get_crossref_metadata with date in future" do
      id = "10.1016/j.ejphar.2015.03.018"
      metadata = subject
      expect(response["@id"]).to eq("https://doi.org/#{doi}")
      expect(response["@type"]).to eq("ScholarlyArticle")
      expect(response["author"]).to eq([{"@type"=>"Person", "givenName"=>"Sarah E.", "familyName"=>"Beck"},
                                        {"@type"=>"Person", "givenName"=>"Suzanne E.", "familyName"=>"Queen"},
                                        {"@type"=>"Person", "givenName"=>"Kenneth W.", "familyName"=>"Witwer"},
                                        {"@type"=>"Person", "givenName"=>"Kelly A.", "familyName"=>"Metcalf Pate"},
                                        {"@type"=>"Person", "givenName"=>"Lisa M.", "familyName"=>"Mangus"},
                                        {"@type"=>"Person", "givenName"=>"Lucio", "familyName"=>"Gama"},
                                        {"@type"=>"Person", "givenName"=>"Robert J.", "familyName"=>"Adams"},
                                        {"@type"=>"Person", "givenName"=>"Janice E.", "familyName"=>"Clements"},
                                        {"@type"=>"Person", "givenName"=>"M.", "familyName"=>"Christine Zink"},
                                        {"@type"=>"Person", "givenName"=>"Joseph L.", "familyName"=>"Mankowski"}])
      expect(response["name"]).to eq("Paving the path to HIV neurotherapy: Predicting SIV CNS disease")
      expect(response["datePublished"]).to eq("2015-07")
      expect(response["dateModified"]).to eq("2016-08-20T02:19:38Z")
      expect(response["isPartOf"]).to eq("@type"=>"Periodical", "name"=>"European Journal of Pharmacology", "issn"=>"00142999")
      expect(response["provider"]).to eq("@type"=>"Organization", "name"=>"Crossref")
    end

    it "get_crossref_metadata with not found error" do
      id = "#{id}x"
      response = subject
      expect(response).to eq("error" => "Resource not found.")
    end
  end
end
