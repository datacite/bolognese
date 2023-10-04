# frozen_string_literal: true

require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  let(:input) { "https://doi.org/10.1101/097196" }

  subject { Bolognese::Metadata.new(input: input, from: "crossref") }

  context "is_personal_name?" do
    it "has type organization" do
      author = {"email"=>"info@ucop.edu", "name"=>"University of California, Santa Barbara", "role"=>{"namespace"=>"http://www.ngdc.noaa.gov/metadata/published/xsd/schema/resources/Codelist/gmxCodelists.xml#CI_RoleCode", "roleCode"=>"copyrightHolder"}, "nameType"=>"Organizational" }
      expect(subject.is_personal_name?(author)).to be false
    end

    it "has id" do
      author = {"id"=>"http://orcid.org/0000-0003-1419-2405", "givenName"=>"Martin", "familyName"=>"Fenner", "name"=>"Martin Fenner" }
      expect(subject.is_personal_name?(author)).to be true
    end

    it "has orcid id" do
      author = { "creatorName"=>"Fenner, Martin", "givenName"=>"Martin", "familyName"=>"Fenner", "nameIdentifier"=>{"schemeURI"=>"http://orcid.org/", "nameIdentifierScheme"=>"ORCID", "__content__"=>"0000-0003-1419-2405"}}
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
      meta = Maremma.from_xml(subject.raw).fetch("resource", {})
      response = subject.get_one_author(meta.dig("creators", "creator"))
      expect(response).to eq("nameIdentifiers" => [{"nameIdentifier"=>"https://orcid.org/0000-0003-1419-2405", "nameIdentifierScheme"=>"ORCID", "schemeUri"=>"https://orcid.org"}], "name"=>"Fenner, Martin", "givenName"=>"Martin", "familyName"=>"Fenner")
    end

    it "has name in sort-order" do
      input = "https://doi.org/10.5061/dryad.8515"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      meta = Maremma.from_xml(subject.raw).fetch("resource", {})
      response = subject.get_one_author(meta.dig("creators", "creator").first)
      expect(response).to eq("nameType"=>"Personal", "name"=>"Ollomo, Benjamin", "givenName"=>"Benjamin", "familyName"=>"Ollomo", "nameIdentifiers" => [], "affiliation" => [{"affiliationIdentifier"=>"https://ror.org/01wyqb997", "affiliationIdentifierScheme"=>"ROR", "name"=>"Centre International de Recherches Médicales de Franceville"}])
    end

    it "has name in display-order" do
      input = "https://doi.org/10.5281/ZENODO.48440"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      meta = Maremma.from_xml(subject.raw).fetch("resource", {})
      response = subject.get_one_author(meta.dig("creators", "creator"))
      expect(response).to eq("nameType"=>"Personal", "name"=>"Garza, Kristian", "givenName"=>"Kristian", "familyName"=>"Garza", "nameIdentifiers" => [], "affiliation" => [])
    end

    it "has name in display-order with ORCID" do
      input = "https://doi.org/10.6084/M9.FIGSHARE.4700788"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      meta = Maremma.from_xml(subject.raw).fetch("resource", {})
      response = subject.get_one_author(meta.dig("creators", "creator"))
      expect(response).to eq("nameType"=>"Personal", "nameIdentifiers" => [{"nameIdentifier"=>"https://orcid.org/0000-0003-4881-1606", "nameIdentifierScheme"=>"ORCID", "schemeUri"=>"https://orcid.org"}], "name"=>"Bedini, Andrea", "givenName"=>"Andrea", "familyName"=>"Bedini", "affiliation" => [])
    end

    it "has name in Thai" do
      input = "https://doi.org/10.14457/KMITL.res.2006.17"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      meta = Maremma.from_xml(subject.raw).fetch("resource", {})
      response = subject.get_one_author(meta.dig("creators", "creator"))
      expect(response).to eq("name"=>"กัญจนา แซ่เตียว", "nameIdentifiers" => [], "affiliation" => [])
    end

    it "multiple author names in one field" do
      input = "https://doi.org/10.7910/dvn/eqtqyo"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      meta = Maremma.from_xml(subject.raw).fetch("resource", {})
      response = subject.get_authors(meta.dig("creators", "creator"))
      expect(response).to eq([{"name" => "Enos, Ryan (Harvard University); Fowler, Anthony (University Of Chicago); Vavreck, Lynn (UCLA)", "nameIdentifiers" => [], "affiliation" => []}])
    end

    it "hyper-authorship" do
      input = "https://doi.org/10.17182/HEPDATA.77274.V1"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      meta = Maremma.from_xml(subject.raw).fetch("resource", {})
      response = subject.get_authors(meta.dig("creators", "creator"))
      expect(response.length).to eq(1000)
      expect(response.first).to eq("nameType"=>"Personal", "name"=>"Adam, Jaroslav", "givenName"=>"Jaroslav", "familyName"=>"Adam", "affiliation" => [{"name"=>"Prague, Tech. U."}], "nameIdentifiers" => [])
    end

    it "is organization" do
      author = {"email"=>"info@ucop.edu", "creatorName"=> { "__content__" => "University of California, Santa Barbara", "nameType" => "Organizational" }, "role"=>{"namespace"=>"http://www.ngdc.noaa.gov/metadata/published/xsd/schema/resources/Codelist/gmxCodelists.xml#CI_RoleCode", "roleCode"=>"copyrightHolder"} }
      response = subject.get_one_author(author)
      expect(response).to eq("nameType"=>"Organizational", "name"=>"University Of California, Santa Barbara", "nameIdentifiers" => [], "affiliation" => [])
    end

    it "name with affiliation" do
      input = "10.11588/DIGLIT.6130"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      meta = Maremma.from_xml(subject.raw).fetch("resource", {})
      response = subject.get_one_author(meta.dig("creators", "creator"))
      expect(response).to eq("nameType"=>"Organizational", "name"=>"Dr. Störi, Kunstsalon", "nameIdentifiers" => [], "affiliation" => [])
    end

    it "name with affiliation and country" do
      input = "10.16910/jemr.9.1.2"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      response = subject.get_one_author(subject.creators.first)
      expect(response).to eq("familyName" => "Eraslan",
        "givenName" => "Sukru",
        "name" => "Eraslan, Sukru")
    end

    it "name with role" do
      input = "10.14463/GBV:873056442"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      meta = Maremma.from_xml(subject.raw).fetch("resource", {})
      response = subject.get_one_author(meta.dig("creators", "creator").first)
      expect(response).to eq("affiliation" => [],
        "familyName" => "Schumacher",
        "givenName" => "Heinrich Christian",
        "name" => "Schumacher, Heinrich Christian",
        "nameIdentifiers" => [{"nameIdentifier"=>"118611593", "nameIdentifierScheme"=>"GND", "schemeUri"=>"http://d-nb.info/gnd/"}],
        "nameType" => "Personal")
    end

    it "multiple name_identifier" do
      input = "10.24350/CIRM.V.19028803"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      meta = Maremma.from_xml(subject.raw).fetch("resource", {})
      response = subject.get_one_author(meta.dig("creators", "creator"))
      expect(response).to eq("nameType"=>"Personal", "name"=>"Dubos, Thomas", "givenName"=>"Thomas", "familyName"=>"Dubos", "affiliation" => [{"name"=>"&#201;cole Polytechnique Laboratoire de M&#233;t&#233;orologie Dynamique"}], "nameIdentifiers" => [{"nameIdentifier"=>"0000 0003 5752 6882", "nameIdentifierScheme"=>"ISNI", "schemeUri"=>"http://isni.org/isni/"}, {"nameIdentifier"=>"https://orcid.org/0000-0003-4514-4211", "nameIdentifierScheme"=>"ORCID", "schemeUri"=>"https://orcid.org"}])
    end

    it "nameType organizational" do
      input = fixture_path + 'gtex.xml'
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      meta = Maremma.from_xml(subject.raw).fetch("resource", {})
      response = subject.get_one_author(meta.dig("creators", "creator"))
      expect(response).to eq("nameType"=>"Organizational", "name"=>"The GTEx Consortium", "nameIdentifiers" => [], "affiliation" => [])
    end

    it "only familyName and givenName" do
      input = "https://doi.pangaea.de/10.1594/PANGAEA.836178"
      subject = Bolognese::Metadata.new(input: input, from: "schema_org")
      expect(subject.creators.first).to eq("nameType" => "Personal", "name"=>"Johansson, Emma", "givenName"=>"Emma", "familyName"=>"Johansson")
    end
  end

  it "has ROR nameIdentifiers" do
    input = fixture_path + 'datacite-example-ROR-nameIdentifiers.xml'
    subject = Bolognese::Metadata.new(input: input, from: "datacite")
    expect(subject.creators[2]).to eq("nameType"=>"Organizational", "name"=>"Gump South Pacific Research Station", "nameIdentifiers"=> [{"nameIdentifier"=>"https://ror.org/04sk0et52", "schemeUri"=>"https://ror.org", "nameIdentifierScheme"=>"ROR"}], "affiliation"=>[])
    expect(subject.creators[3]).to eq("nameType"=>"Organizational", "name"=>"University Of Vic", "nameIdentifiers"=> [{"nameIdentifier"=>"https://ror.org/006zjws59", "schemeUri"=>"https://ror.org", "nameIdentifierScheme"=>"ROR"}], "affiliation"=>[])
    expect(subject.creators[4]).to eq("nameType"=>"Organizational", "name"=>"University Of Kivu", "nameIdentifiers"=> [{"nameIdentifier"=>"https://ror.org/01qfhxr31", "schemeUri"=>"https://ror.org", "nameIdentifierScheme"=>"ROR"}], "affiliation"=>[])
    expect(subject.creators[5]).to eq("nameType"=>"Organizational", "name"=>"សាកលវិទ្យាល័យកម្ពុជា", "nameIdentifiers"=> [{"nameIdentifier"=>"http://ror.org/025e3rc84", "nameIdentifierScheme"=>"RORS"}], "affiliation"=>[])
    expect(subject.creators[6]).to eq("nameType"=>"Organizational", "name"=>"جامعة زاخۆ", "nameIdentifiers"=> [{"nameIdentifier"=>"05sd1pz50", "schemeUri"=>"https://ror.org", "nameIdentifierScheme"=>"RORS"}], "affiliation"=>[])
    expect(subject.contributors.first).to eq("nameType"=>"Organizational", "name"=>" Nawroz University ", "nameIdentifiers"=> [{"nameIdentifier"=>"https://ror.org/04gp75d48", "schemeUri"=>"https://ror.org", "nameIdentifierScheme"=>"ROR"}], "affiliation"=>[], "contributorType"=>"Producer")
    expect(subject.contributors.last).to eq("nameType"=>"Organizational", "name"=>"University Of Greenland (Https://Www.Uni.Gl/)", "nameIdentifiers"=> [{"nameIdentifier"=>"https://ror.org/00t5j6b61", "schemeUri"=>"https://ror.org", "nameIdentifierScheme"=>"ROR"}],"affiliation"=>[], "contributorType"=>"Sponsor")
  end

  context "affiliationIdentifier" do
    let(:input) { fixture_path + 'datacite-example-ROR-nameIdentifiers.xml' }
    subject { Bolognese::Metadata.new(input: input, from: "datacite") }

    it "should normalize ROR affiliationIdentifier with and without URL" do
      # without URL inside affiliationIdentifier="05bp8ka77"
      ror_affiliater0 = subject.creators[0]["affiliation"].select { |r| r["affiliationIdentifierScheme"] == "ROR" }
      expect(ror_affiliater0[0]["affiliationIdentifier"]).to eq("https://ror.org/05bp8ka77")
      # with URL "affiliationIdentifier"=>"https://ror.org/05bp8ka05"
      ror_affiliater1 = subject.creators[1]["affiliation"].select { |r| r["affiliationIdentifierScheme"] == "ROR" }
      expect(ror_affiliater1[0]["affiliationIdentifier"]).to eq("https://ror.org/05bp8ka05")
    end

    it "should normalize the valid ORCID nameIdentifier to URL with schemeURI" do
      # with "schemeURI"
      # ORICD normalization  0000-0001-9998-0117 => https://orcid.org/0000-0001-9998-0117
      expect(subject.creators[0]["nameIdentifiers"]).to eq([{"nameIdentifier"=>"https://orcid.org/0000-0001-9998-0117", "schemeUri"=>"https://orcid.org", "nameIdentifierScheme"=>"ORCID"}])
    end

    it "should normalize the valid ORCID nameIdentifier to URL without schemeURI" do
      # without "schemeURI"
      # ORICD normalization  0000-0001-9998-0117 => https://orcid.org/0000-0001-9998-0117
      expect(subject.creators[7]["nameIdentifiers"]).to eq([{"nameIdentifier"=>"https://orcid.org/0000-0001-9998-0117", "schemeUri"=>"https://orcid.org", "nameIdentifierScheme"=>"ORCID"}])
    end

    it "should parse non ROR schema's without normalizing them" do
      input = fixture_path + 'datacite-example-ROR-nameIdentifiers.xml'
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      # without "schemeURI"
      grid_affiliater0 = subject.creators[0]["affiliation"].select { |r| r["affiliationIdentifierScheme"] == "GRID" }
      expect(grid_affiliater0[0]["affiliationIdentifier"]).to eq("grid.268117.b")
      # with "schemeURI"=>"https://grid.ac/institutes/"
      grid_affiliater1 = subject.creators[1]["affiliation"].select { |r| r["affiliationIdentifierScheme"] == "GRID" }
      expect(grid_affiliater1[0]["affiliationIdentifier"]).to eq("https://grid.ac/institutes/grid.268117.b")
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
      response = subject.authors_as_string(subject.creators)
      expect(response).to eq("Fenner, Martin and Crosas, Merc?? and Grethe, Jeffrey and Kennedy, David and Hermjakob, Henning and Rocca-Serra, Philippe and Durand, Gustavo and Berjon, Robin and Karcher, Sebastian and Martone, Maryann and Clark, Timothy")
    end

    it "single author" do
      response = subject.authors_as_string(subject.creators.first)
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
