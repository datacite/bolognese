require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  context "write metadata as datacite xml" do
    it "with data citation" do
      input = "10.7554/eLife.01567"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.dig("resourceType", "resourceTypeGeneral")).to eq("Text")
      expect(datacite.dig("titles", "title")).to eq("Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
      expect(datacite.dig("relatedIdentifiers", "relatedIdentifier").length).to eq(26)
      expect(datacite.dig("relatedIdentifiers", "relatedIdentifier").first).to eq("relatedIdentifierType"=>"ISSN", "relationType"=>"IsPartOf", "__content__"=>"2050-084X")
      expect(datacite.dig("relatedIdentifiers", "relatedIdentifier")[1]).to eq("relatedIdentifierType"=>"DOI", "relationType"=>"References", "__content__"=>"https://doi.org/10.1038/nature02100")
      expect(datacite.dig("rightsList")).to eq("rights"=>{"rightsURI"=>"http://creativecommons.org/licenses/by/3.0"})
      expect(datacite.dig("fundingReferences", "fundingReference").count).to eq(4)
      expect(datacite.dig("fundingReferences", "fundingReference").last).to eq("funderName"=>"University of Lausanne", "funderIdentifier"=>{"funderIdentifierType"=>"Crossref Funder ID", "__content__"=>"https://doi.org/10.13039/501100006390"})
    end

    it "with ORCID ID" do
      input = "https://doi.org/10.1155/2012/291294"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.dig("resourceType", "resourceTypeGeneral")).to eq("Text")
      expect(datacite.dig("creators", "creator").count).to eq(7)
      expect(datacite.dig("creators", "creator")[2]).to eq("creatorName" => "Hernandez, Beatriz",
        "familyName" => "Hernandez",
        "givenName" => "Beatriz",
        "nameIdentifier" => {"schemeURI"=>"http://orcid.org/", "nameIdentifierScheme"=>"ORCID", "__content__"=>"http://orcid.org/0000-0003-2043-4925"})
    end

    it "with editor" do
      input = "https://doi.org/10.1371/journal.pone.0000030"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.dig("contributors", "contributor")).to eq("contributorType"=>"Editor", "contributorName"=>"Janbon, Guilhem", "givenName"=>"Guilhem", "familyName"=>"Janbon")
    end

    it "Crossref DOI" do
      input = fixture_path + "crossref.bib"
      subject = Bolognese::Metadata.new(input: input, from: "bibtex")
      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.dig("resourceType", "resourceTypeGeneral")).to eq("Text")
      expect(datacite.dig("titles", "title")).to eq("Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
      expect(datacite.dig("descriptions", "description", "__content__")).to start_with("Among various advantages, their small size makes model organisms preferred subjects of investigation.")
      expect(datacite.dig("creators", "creator").count).to eq(5)
      expect(datacite.dig("creators", "creator").first).to eq("creatorName"=>"Sankar, Martial", "givenName"=>"Martial", "familyName"=>"Sankar")
    end

    it "BlogPosting Citeproc JSON" do
      input = fixture_path + "citeproc.json"
      subject = Bolognese::Metadata.new(input: input, from: "citeproc")
      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.dig("resourceType", "resourceTypeGeneral")).to eq("Text")
      expect(datacite.dig("titles", "title")).to eq("Eating your own Dog Food")
      expect(datacite.dig("descriptions", "description", "__content__")).to start_with("Eating your own dog food")
      expect(datacite.dig("creators", "creator")).to eq("creatorName"=>"Fenner, Martin", "givenName"=>"Martin", "familyName"=>"Fenner")
    end

    it "rdataone" do
      input = fixture_path + 'codemeta.json'
      subject = Bolognese::Metadata.new(input: input, from: "codemeta")
      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.dig("titles", "title")).to eq("R Interface to the DataONE REST API")
      expect(datacite.dig("creators", "creator")).to eq([{"creatorName"=>"Jones, Matt",
                                                          "givenName"=>"Matt",
                                                          "familyName"=>"Jones",
                                                          "nameIdentifier"=>
                                                         {"schemeURI"=>"http://orcid.org/",
                                                          "nameIdentifierScheme"=>"ORCID",
                                                          "__content__"=>"http://orcid.org/0000-0003-0077-4738"}},
                                                         {"creatorName"=>"Slaughter, Peter",
                                                           "givenName"=>"Peter",
                                                           "familyName"=>"Slaughter",
                                                          "nameIdentifier"=>
                                                         {"schemeURI"=>"http://orcid.org/",
                                                          "nameIdentifierScheme"=>"ORCID",
                                                          "__content__"=>"http://orcid.org/0000-0002-2192-403X"}},
                                                         {"creatorName"=>"University Of California, Santa Barbara"}])
      expect(datacite.fetch("version")).to eq("2.0.0")
    end

    it "maremma" do
      input = "https://github.com/datacite/maremma"
      subject = Bolognese::Metadata.new(input: input, from: "codemeta")
      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.dig("titles", "title")).to eq("Maremma: a Ruby library for simplified network calls")
      expect(datacite.dig("creators", "creator")).to eq("creatorName"=>"Fenner, Martin", "givenName"=>"Martin", "familyName"=>"Fenner", "nameIdentifier"=>{"schemeURI"=>"http://orcid.org/", "nameIdentifierScheme"=>"ORCID", "__content__"=>"http://orcid.org/0000-0003-0077-4738"})
    end

    it "Dataset in schema 4.0" do
      input = "https://doi.org/10.5061/DRYAD.8515"
      subject = Bolognese::Metadata.new(input: input, from: "datacite", regenerate: true)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.5061/dryad.8515")
      expect(subject.type).to eq("Dataset")
      expect(subject.additional_type).to eq("DataPackage")
      expect(subject.resource_type_general).to eq("Dataset")
      expect(subject.author.length).to eq(8)
      expect(subject.author.first).to eq("type"=>"Person", "name"=>"Benjamin Ollomo", "givenName"=>"Benjamin", "familyName"=>"Ollomo")
      expect(subject.title).to eq("Data from: A new malaria agent in African hominids.")
      expect(subject.alternate_name).to eq("type"=>"citation", "name"=>"Ollomo B, Durand P, Prugnolle F, Douzery EJP, Arnathau C, Nkoghe D, Leroy E, Renaud F (2009) A new malaria agent in African hominids. PLoS Pathogens 5(5): e1000446.")
      expect(subject.license).to eq("id"=>"http://creativecommons.org/publicdomain/zero/1.0")
      expect(subject.date_published).to eq("2011")
      expect(subject.has_part).to eq([{"id"=>"https://doi.org/10.5061/dryad.8515/1"},
                                      {"id"=>"https://doi.org/10.5061/dryad.8515/2"}])
      expect(subject.is_referenced_by).to eq("id"=>"https://doi.org/10.1371/journal.ppat.1000446")
      expect(subject.publisher).to eq("Dryad Digital Repository")
      expect(subject.provider).to eq("DataCite")
      expect(subject.schema_version).to eq("http://datacite.org/schema/kernel-3")

      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.fetch("xsi:schemaLocation", "").split(" ").first).to eq("http://datacite.org/schema/kernel-4")
    end

    it "with data citation schema.org" do
      input = "https://blog.datacite.org/eating-your-own-dog-food/"
      subject = Bolognese::Metadata.new(input: input, from: "schema_org")
      expect(subject.valid?).to be true
      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.dig("titles", "title")).to eq("Eating your own Dog Food")
      expect(datacite.dig("relatedIdentifiers", "relatedIdentifier").count).to eq(3)
      expect(datacite.dig("relatedIdentifiers", "relatedIdentifier").first).to eq("relatedIdentifierType"=>"DOI", "relationType"=>"IsPartOf", "__content__"=>"https://doi.org/10.5438/0000-00ss")
    end
  end
end
