# frozen_string_literal: true

require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  context "write metadata as datacite json" do
    it "with data citation" do
      input = "10.7554/eLife.01567"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      datacite = JSON.parse(subject.datacite_json)
      expect(datacite.fetch("url")).to eq("https://elifesciences.org/articles/01567")
      expect(datacite.fetch("types")).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(datacite.fetch("titles")).to eq([{"title"=>"Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth"}])
      expect(datacite.fetch("relatedIdentifiers").length).to eq(27)
      expect(datacite.fetch("relatedIdentifiers").first).to eq("relatedIdentifier"=>"2050-084X", "relatedIdentifierType"=>"ISSN", "relationType"=>"IsPartOf", "resourceTypeGeneral"=>"Collection")
      expect(datacite.fetch("rightsList")).to eq([{"rights"=>"Creative Commons Attribution 3.0 Unported",
        "rightsIdentifier"=>"cc-by-3.0",
        "rightsIdentifierScheme"=>"SPDX",
        "rightsUri"=>"https://creativecommons.org/licenses/by/3.0/legalcode",
        "schemeUri"=>"https://spdx.org/licenses/"}])
    end

    it "with ORCID ID" do
      input = "https://doi.org/10.1155/2012/291294"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      datacite = JSON.parse(subject.datacite_json)
      expect(datacite.fetch("url")).to eq("http://www.hindawi.com/journals/pm/2012/291294/")
      expect(datacite.fetch("types")).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(datacite.fetch("creators").length).to eq(7)
      expect(datacite.fetch("creators").first).to eq("nameType"=>"Personal", "name"=>"Thanassi, Wendy", "givenName"=>"Wendy", "familyName"=>"Thanassi", "affiliation" => [{"name"=>"Department of Medicine, Veterans Affairs Palo Alto Health Care System, 3801 Miranda Avenue MC-, Palo Alto, CA 94304-1207, USA"}, {"name"=>"Occupational Health Strategic Health Care Group, Office of Public Health, Veterans Health Administration, Washington, DC 20006, USA"}, {"name"=>"Division of Emergency Medicine, Stanford University School of Medicine, Stanford, CA 94304, USA"}, {"name"=>"War Related Illness and Injury Study Center (WRIISC) and Mental Illness Research Education and Clinical Center (MIRECC), Department of Veterans Affairs, Palo Alto, CA 94304, USA"}])
    end

    it "Crossref DOI" do
      input = fixture_path + "crossref.bib"
      subject = Bolognese::Metadata.new(input: input, from: "bibtex")
      datacite = JSON.parse(subject.datacite_json)
      expect(datacite.fetch("types")).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(datacite.fetch("titles")).to eq([{"title"=>"Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth"}])
      expect(datacite.dig("descriptions", 0, "description")).to start_with("Among various advantages, their small size makes model organisms preferred subjects of investigation.")
      expect(datacite.fetch("creators").length).to eq(5)
      expect(datacite.fetch("creators").first).to eq("nameType"=>"Personal", "name"=>"Sankar, Martial", "givenName"=>"Martial", "familyName"=>"Sankar")
    end

    it "BlogPosting Citeproc JSON" do
      input = fixture_path + "citeproc.json"
      subject = Bolognese::Metadata.new(input: input, from: "citeproc")
      datacite = JSON.parse(subject.datacite_json)
      expect(datacite.fetch("types")).to eq("bibtex"=>"article", "citeproc"=>"post-weblog", "resourceTypeGeneral"=>"Text", "ris"=>"GEN", "schemaOrg"=>"BlogPosting")
      expect(datacite.fetch("titles")).to eq([{"title"=>"Eating your own Dog Food"}])
      expect(datacite.dig("descriptions", 0, "description")).to start_with("Eating your own dog food")
      expect(datacite.fetch("creators")).to eq([{"familyName"=>"Fenner", "givenName"=>"Martin", "name"=>"Fenner, Martin"}])
    end

    it "rdataone" do
      input = fixture_path + 'codemeta.json'
      subject = Bolognese::Metadata.new(input: input, from: "codemeta")
      datacite = JSON.parse(subject.datacite_json)
      expect(datacite.fetch("titles")).to eq([{"title"=>"R Interface to the DataONE REST API"}])
      expect(datacite.fetch("creators").length).to eq(3)
      expect(datacite.fetch("creators").first).to eq("affiliation"=>[{"name"=>"NCEAS"}], "nameType"=>"Personal", "name" => "Jones, Matt",
        "nameIdentifiers" => [{"nameIdentifier"=>"https://orcid.org/0000-0003-0077-4738", "nameIdentifierScheme"=>"ORCID", "schemeUri"=>"https://orcid.org"}], "givenName"=>"Matt", "familyName"=>"Jones")
      expect(datacite.fetch("version")).to eq("2.0.0")
    end

    it "maremma" do
      input = "https://github.com/datacite/maremma"
      subject = Bolognese::Metadata.new(input: input, from: "codemeta")
      datacite = JSON.parse(subject.datacite_json)
      expect(datacite.fetch("titles")).to eq([{"title"=>"Maremma: a Ruby library for simplified network calls"}])
      expect(datacite.fetch("creators")).to eq([{"affiliation"=>[{"name"=>"DataCite"}],
        "familyName"=>"Fenner",
        "givenName"=>"Martin",
        "name"=>"Fenner, Martin",
        "nameIdentifiers"=>
         [{"nameIdentifier"=>"https://orcid.org/0000-0003-0077-4738",
           "nameIdentifierScheme"=>"ORCID", "schemeUri"=>"https://orcid.org"}],
        "nameType"=>"Personal"}])
    end

    it "with data citation schema.org" do
      input = "https://blog.datacite.org/eating-your-own-dog-food/"
      subject = Bolognese::Metadata.new(input: input, from: "schema_org")
      expect(subject.valid?).to be true
      datacite = JSON.parse(subject.datacite_json)
      expect(datacite.fetch("titles")).to eq([{"title"=>"Eating your own Dog Food"}])
      expect(datacite.fetch("relatedIdentifiers").count).to eq(3)
      expect(datacite.fetch("relatedIdentifiers").first).to eq("relatedIdentifier"=>"10.5438/0000-00ss", "relatedIdentifierType"=>"DOI", "relationType"=>"IsPartOf", "resourceTypeGeneral"=>"Text")
    end
  end
end
