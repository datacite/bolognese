require 'spec_helper'

describe Bolognese::Crossref, vcr: true do
  let(:id) { "https://doi.org/10.1101/097196" }

  subject { Bolognese::Crossref.new(id: id) }

  context "is_personal_name?" do
    it "has type person" do
      author = {"type"=>"Person", "name"=>"Martin Fenner" }
      expect(subject.is_personal_name?(author)).to be true
    end

    it "has type organization" do
      author = {"type"=>"Organization", "name"=>"University of California, Santa Barbara"}
      expect(subject.is_personal_name?(author)).to be false
    end

    it "has id" do
      author = {"id"=>"http://orcid.org/0000-0003-1419-2405", "givenName"=>"Martin", "familyName"=>"Fenner", "name"=>"Martin Fenner" }
      expect(subject.is_personal_name?(author)).to be true
    end

    it "has family name" do
      author = {"givenName"=>"Martin", "familyName"=>"Fenner", "name"=>"Martin Fenner" }
      expect(subject.is_personal_name?(author)).to be true
    end

    it "has comma" do
      author = {"name"=>"Fenner, Martin" }
      expect(subject.is_personal_name?(author)).to be true
    end

    it "has no info" do
      author = {"name"=>"Martin Fenner" }
      expect(subject.is_personal_name?(author)).to be false
    end
  end

  context "get_one_author" do
    it "has familyName" do
      id = "https://doi.org/10.5438/4K3M-NYVG"
      subject = Bolognese::Datacite.new(id: id)
      response = subject.get_one_author(subject.metadata.dig("creators", "creator"))
      expect(response).to eq("type"=>"Person", "id"=>"http://orcid.org/0000-0003-1419-2405", "name"=>"Fenner, Martin", "givenName"=>"Martin", "familyName"=>"Fenner")
    end

    it "has name in sort-order" do
      id = "https://doi.org/10.5061/dryad.8515"
      subject = Bolognese::Datacite.new(id: id)
      response = subject.get_one_author(subject.metadata.dig("creators", "creator").first)
      expect(response).to eq("type"=>"Person", "name"=>"Benjamin Ollomo", "givenName"=>"Benjamin", "familyName"=>"Ollomo")
    end

    it "has name in display-order" do
      id = "https://doi.org/10.5281/ZENODO.48440"
      subject = Bolognese::Datacite.new(id: id)
      response = subject.get_one_author(subject.metadata.dig("creators", "creator"))
      expect(response).to eq("type"=>"Person", "name"=>"Kristian Garza", "givenName"=>"Kristian", "familyName"=>"Garza")
    end

    it "has name in display-order with ORCID" do
      id = "https://doi.org/10.6084/M9.FIGSHARE.4700788"
      subject = Bolognese::Datacite.new(id: id)
      response = subject.get_one_author(subject.metadata.dig("creators", "creator"))
      expect(response).to eq("type"=>"Person", "id"=>"http://orcid.org/0000-0003-4881-1606", "name"=>"Andrea Bedini", "givenName"=>"Andrea", "familyName"=>"Bedini")
    end
  end

  context "get_name_identifier" do
    it "has ORCID" do
      id = "https://doi.org/10.5438/4K3M-NYVG"
      subject = Bolognese::Datacite.new(id: id)
      response = subject.get_name_identifier(subject.metadata.dig("creators", "creator"))
      expect(response).to eq("http://orcid.org/0000-0003-1419-2405")
    end

    it "has no ORCID" do
      id = "https://doi.org/10.4230/lipics.tqc.2013.93"
      subject = Bolognese::Datacite.new(id: id)
      response = subject.get_name_identifier(subject.metadata.dig("creators", "creator"))
      expect(response).to be_nil
    end
  end

  context "authors_as_string" do
    let(:author_with_organization) { [{"type"=>"Person",
                                       "id"=>"http://orcid.org/0000-0003-0077-4738",
                                       "name"=>"Matt Jones"},
                                      {"type"=>"Person",
                                       "id"=>"http://orcid.org/0000-0002-2192-403X",
                                       "name"=>"Peter Slaughter"},
                                      {"type"=>"Organization",
                                       "id"=>"http://orcid.org/0000-0002-3957-2474",
                                       "name"=>"University of California, Santa Barbara"}] }

    it "author" do
      response = subject.authors_as_string(subject.author)
      expect(response).to eq("Fenner, Martin and Crosas, Mercè and Grethe, Jeffrey and Kennedy, David and Hermjakob, Henning and Rocca-Serra, Philippe and Berjon, Robin and Karcher, Sebastian and Martone, Maryann and Clark, Timothy")
    end

    it "single author" do
      response = subject.authors_as_string(subject.author.first)
      expect(response).to eq("Fenner, Martin")
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
