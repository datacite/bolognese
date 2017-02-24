require 'spec_helper'

describe Bolognese::Crossref, vcr: true do
  let(:id) { "https://doi.org/10.1371/journal.pone.0000030" }

  subject { Bolognese::Crossref.new(id: id) }

  context "authors_as_string" do
    let(:author_with_organization) { [{"@type"=>"person",
                                       "@id"=>"http://orcid.org/0000-0003-0077-4738",
                                       "name"=>"Matt Jones"},
                                      {"@type"=>"person",
                                       "@id"=>"http://orcid.org/0000-0002-2192-403X",
                                       "name"=>"Peter Slaughter"},
                                      {"@type"=>"organization",
                                       "@id"=>"http://orcid.org/0000-0002-3957-2474",
                                       "name"=>"University of California, Santa Barbara"}] }

    it "author" do
      response = subject.authors_as_string(subject.author)
      expect(response).to eq("Ralser, Markus and Heeren, Gino and Breitenbach, Michael and Lehrach, Hans and Krobitsch, Sylvia")
    end

    it "single author" do
      response = subject.authors_as_string(subject.author.first)
      expect(response).to eq("Ralser, Markus")
    end

    it "no author" do
      response = subject.authors_as_string(nil)
      expect(response).to be_nil
    end

    it "with organization" do
      response = subject.authors_as_string(author_with_organization)
      expect(response).to eq("Matt Jones and Peter Slaughter and {University of California, Santa Barbara}")
    end
  end
end
