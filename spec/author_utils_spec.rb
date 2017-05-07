require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  let(:input) { "https://doi.org/10.1101/097196" }

  subject { Bolognese::Metadata.new(input: input, from: "crossref") }

  context "is_personal_name?" do
    it "has type organization" do
      author = {"email"=>"info@ucop.edu", "name"=>"University of California, Santa Barbara", "role"=>{"namespace"=>"http://www.ngdc.noaa.gov/metadata/published/xsd/schema/resources/Codelist/gmxCodelists.xml#CI_RoleCode", "roleCode"=>"copyrightHolder"}, "type"=>"organization" }
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

    it "has known given name" do
      author = {"name"=>"Martin Fenner" }
      expect(subject.is_personal_name?(author)).to be true
    end

    it "has no info" do
      author = {"name"=>"M Fenner" }
      expect(subject.is_personal_name?(author)).to be false
    end
  end

  context "get_one_author" do
    it "has familyName" do
      input = "https://doi.org/10.5438/4K3M-NYVG"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      string = subject.get_datacite(id: input)
      meta = Maremma.from_xml(string).fetch("resource", {})
      response = subject.get_one_author(meta.dig("creators", "creator"))
      expect(response).to eq("type"=>"Person", "id"=>"http://orcid.org/0000-0003-1419-2405", "name"=>"Fenner, Martin", "givenName"=>"Martin", "familyName"=>"Fenner")
    end

    it "has name in sort-order" do
      input = "https://doi.org/10.5061/dryad.8515"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      string = subject.get_datacite(id: input)
      meta = Maremma.from_xml(string).fetch("resource", {})
      response = subject.get_one_author(meta.dig("creators", "creator").first)
      expect(response).to eq("type"=>"Person", "name"=>"Benjamin Ollomo", "givenName"=>"Benjamin", "familyName"=>"Ollomo")
    end

    it "has name in display-order" do
      input = "https://doi.org/10.5281/ZENODO.48440"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      string = subject.get_datacite(id: input)
      meta = Maremma.from_xml(string).fetch("resource", {})
      response = subject.get_one_author(meta.dig("creators", "creator"))
      expect(response).to eq("type"=>"Person", "name"=>"Kristian Garza", "givenName"=>"Kristian", "familyName"=>"Garza")
    end

    it "has multiple names in display-order" do
      input = "https://doi.org/10.6084/M9.FIGSHARE.3479141 "
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      string = subject.get_datacite(id: input)
      meta = Maremma.from_xml(string).fetch("resource", {})
      response = subject.get_authors(meta.dig("creators", "creator"))
      expect(response.count).to eq(9)
      expect(response.last).to eq("type"=>"Person", "name"=>"Ed Pentz", "givenName"=>"Ed", "familyName"=>"Pentz")
    end

    it "has name in display-order with ORCID" do
      input = "https://doi.org/10.6084/M9.FIGSHARE.4700788"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      string = subject.get_datacite(id: input)
      meta = Maremma.from_xml(string).fetch("resource", {})
      response = subject.get_one_author(meta.dig("creators", "creator"))
      expect(response).to eq("type"=>"Person", "id"=>"http://orcid.org/0000-0003-4881-1606", "name"=>"Andrea Bedini", "givenName"=>"Andrea", "familyName"=>"Bedini")
    end

    it "has name in Thai" do
      input = "https://doi.org/10.14457/KMITL.res.2006.17"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      string = subject.get_datacite(id: input)
      meta = Maremma.from_xml(string).fetch("resource", {})
      response = subject.get_one_author(meta.dig("creators", "creator"))
      expect(response).to eq("name"=>"กัญจนา แซ่เตียว")
    end

    it "multiple author names in one field" do
      input = "https://doi.org/10.7910/dvn/eqtqyo"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      string = subject.get_datacite(id: input)
      meta = Maremma.from_xml(string).fetch("resource", {})
      response = subject.get_authors(meta.dig("creators", "creator"))
      expect(response).to eq([{"type"=>"Person",
                               "name"=>"Ryan Enos",
                               "givenName"=>"Ryan",
                               "familyName"=>"Enos"},
                              {"type"=>"Person",
                               "name"=>"Anthony Fowler",
                               "givenName"=>"Anthony",
                               "familyName"=>"Fowler"},
                              {"type"=>"Person",
                               "name"=>"Lynn Vavreck",
                               "givenName"=>"Lynn",
                               "familyName"=>"Vavreck"}])
    end

    it "hyper-authorship" do
      input = "https://doi.org/10.17182/HEPDATA.77274.V1"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      string = subject.get_datacite(id: input)
      meta = Maremma.from_xml(string).fetch("resource", {})
      response = subject.get_authors(meta.dig("creators", "creator"))
      expect(response.length).to eq(1000)
      expect(response.first).to eq("type"=>"Person", "name"=>"Jaroslav Adam", "givenName"=>"Jaroslav", "familyName"=>"Adam")
    end

    it "is organization" do
      author = {"email"=>"info@ucop.edu", "name"=>"University of California, Santa Barbara", "role"=>{"namespace"=>"http://www.ngdc.noaa.gov/metadata/published/xsd/schema/resources/Codelist/gmxCodelists.xml#CI_RoleCode", "roleCode"=>"copyrightHolder"}, "type"=>"organization" }
      response = subject.get_one_author(author)
      expect(response).to eq("type"=>"Organization", "name"=>"University Of California, Santa Barbara")
    end

    it "name with affiliation" do
      input = "10.11588/DIGLIT.6130"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      string = subject.get_datacite(id: input)
      meta = Maremma.from_xml(string).fetch("resource", {})
      response = subject.get_one_author(meta.dig("creators", "creator"))
      expect(response).to eq("type"=>"Person", "name"=>"Dr. Störi, Kunstsalon")
    end
  end

  context "get_name_identifier" do
    it "has ORCID" do
      input = "https://doi.org/10.5438/4K3M-NYVG"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      string = subject.get_datacite(id: input)
      meta = Maremma.from_xml(string).fetch("resource", {})
      response = subject.get_name_identifier(meta.dig("creators", "creator"))
      expect(response).to eq("http://orcid.org/0000-0003-1419-2405")
    end

    it "has no ORCID" do
      input = "https://doi.org/10.4230/lipics.tqc.2013.93"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      string = subject.get_datacite(id: input)
      meta = Maremma.from_xml(string).fetch("resource", {})
      response = subject.get_name_identifier(meta.dig("creators", "creator"))
      expect(response).to be_nil
    end

    it "has jacow.org scheme" do
      input = "https://doi.org/10.18429/JACOW-IPAC2016-TUPMY003"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      string = subject.get_datacite(id: input)
      meta = Maremma.from_xml(string).fetch("resource", {})
      response = subject.get_name_identifier(meta.dig("creators", "creator").first)
      expect(response).to eq("http://jacow.org/JACoW-00077389")
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
