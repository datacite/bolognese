# frozen_string_literal: true

require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  context "write metadata as crosscite" do
    it "with data citation" do
      input = "10.7554/eLife.01567"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      crosscite = JSON.parse(subject.crosscite)
      expect(crosscite.fetch("url")).to eq("https://elifesciences.org/articles/01567")
      expect(crosscite.fetch("types")).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(crosscite.fetch("titles")).to eq([{"title"=>"Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth"}])
      expect(crosscite.fetch("related_identifiers").length).to eq(27)
      expect(crosscite.fetch("related_identifiers").first).to eq("relatedIdentifier"=>"2050-084X", "relatedIdentifierType"=>"ISSN", "relationType"=>"IsPartOf", "resourceTypeGeneral"=>"Collection")
      expect(crosscite.fetch("related_identifiers").last).to eq("relatedIdentifier"=>"10.1038/ncb2764", "relatedIdentifierType"=>"DOI", "relationType"=>"References")
      expect(crosscite.fetch("rights_list")).to eq([{"rightsUri"=>"http://creativecommons.org/licenses/by/3.0"}])
    end

    it "with ORCID ID" do
      input = "https://doi.org/10.1155/2012/291294"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      crosscite = JSON.parse(subject.crosscite)
      expect(crosscite.fetch("types")).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceType"=>"JournalArticle", "resourceTypeGeneral"=>"Text", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(crosscite.fetch("creators").count).to eq(7)
      expect(crosscite.fetch("creators")[2]).to eq("nameType"=>"Personal", "nameIdentifiers" => [{"nameIdentifier"=>"https://orcid.org/0000-0003-2043-4925", "nameIdentifierScheme"=>"ORCID", "schemeUri"=>"https://orcid.org"}], "name"=>"Hernandez, Beatriz", "givenName"=>"Beatriz", "familyName"=>"Hernandez")
    end

    # it "with editor" do
    #   input = "https://doi.org/10.1371/journal.pone.0000030"
    #   subject = Bolognese::Metadata.new(input: input, from: "crossref")
    #   crosscite = JSON.parse(subject.crosscite)
    #   expect(crosscite["editor"]).to eq("contributorType"=>"Editor", "contributorName"=>"Janbon, Guilhem", "givenName"=>"Guilhem", "familyName"=>"Janbon")
    # end

    it "Crossref DOI" do
      input = fixture_path + "crossref.bib"
      subject = Bolognese::Metadata.new(input: input, from: "bibtex")
      crosscite = JSON.parse(subject.crosscite)
      expect(crosscite.fetch("types")).to eq("bibtex"=>"article", "citeproc"=>"article-journal", "resourceTypeGeneral"=>"Text", "resourceType"=>"JournalArticle", "ris"=>"JOUR", "schemaOrg"=>"ScholarlyArticle")
      expect(crosscite.fetch("titles")).to eq([{"title"=>"Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth"}])
      expect(crosscite.dig("descriptions", 0, "description")).to start_with("Among various advantages, their small size makes model organisms preferred subjects of investigation.")
      expect(crosscite.fetch("creators").count).to eq(5)
      expect(crosscite.fetch("creators").first).to eq("nameType"=>"Personal", "name"=>"Sankar, Martial", "givenName"=>"Martial", "familyName"=>"Sankar")
    end

    it "BlogPosting Citeproc JSON" do
      input = fixture_path + "citeproc.json"
      subject = Bolognese::Metadata.new(input: input, from: "citeproc")
      expect(subject.valid?).to be true
      crosscite = JSON.parse(subject.crosscite)
      expect(crosscite["types"]).to eq("bibtex"=>"article", "citeproc"=>"post-weblog", "resourceTypeGeneral"=>"Text", "ris"=>"GEN", "schemaOrg"=>"BlogPosting")
      expect(crosscite.fetch("titles")).to eq([{"title"=>"Eating your own Dog Food"}])
      expect(crosscite.dig("descriptions", 0, "description")).to start_with("Eating your own dog food")
      expect(crosscite.fetch("creators")).to eq([{"familyName"=>"Fenner", "givenName"=>"Martin", "name"=>"Fenner, Martin", "nameType"=>"Personal"}])
    end

    it "rdataone" do
      input = fixture_path + 'codemeta.json'
      subject = Bolognese::Metadata.new(input: input, from: "codemeta")
      crosscite = JSON.parse(subject.crosscite)
      expect(crosscite["titles"]).to eq([{"title"=>"R Interface to the DataONE REST API"}])
      expect(crosscite["creators"].length).to eq(3)
      expect(crosscite["creators"].last).to eq("nameType" => "Organizational", "name"=>"University Of California, Santa Barbara")
      expect(crosscite["version"]).to eq("2.0.0")
    end

    it "rdataone codemeta v2" do
      input = fixture_path + 'codemeta_v2.json'
      subject = Bolognese::Metadata.new(input: input, from: "codemeta")
      crosscite = JSON.parse(subject.crosscite)
      expect(crosscite["titles"]).to eq([{"title"=>"R Interface to the DataONE REST API"}])
      expect(crosscite["creators"].length).to eq(3)
      expect(crosscite["creators"].last).to eq("nameType" => "Organizational", "name"=>"University Of California, Santa Barbara")
      expect(crosscite["version"]).to eq("2.0.0")
    end

    it "datacite database attributes" do
      input = "https://doi.org/10.5061/DRYAD.8515"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      crosscite = JSON.parse(subject.crosscite)
      expect(crosscite.fetch("url")).to eq("https://datadryad.org/resource/doi:10.5061/dryad.8515")
      expect(crosscite.fetch("titles")).to eq([{"title"=>"Data from: A new malaria agent in African hominids."}])
      expect(crosscite.fetch("creators").length).to eq(8)
      expect(crosscite.fetch("creators").first).to eq("familyName" => "Ollomo", "givenName" => "Benjamin", "name" => "Ollomo, Benjamin", "nameType" => "Personal")
      expect(crosscite.fetch("dates")).to eq([{"date"=>"2011", "dateType"=>"Issued"}])
      expect(crosscite.fetch("publication_year")).to eq("2011")
      expect(crosscite.fetch("provider_id")).to eq("dryad")
      expect(crosscite.fetch("client_id")).to eq("dryad.dryad")
    end

    it "maremma" do
      input = "https://github.com/datacite/maremma"
      subject = Bolognese::Metadata.new(input: input, from: "codemeta")
      crosscite = JSON.parse(subject.crosscite)
      expect(crosscite.fetch("titles")).to eq( [{"title"=>"Maremma: a Ruby library for simplified network calls"}])
      expect(crosscite.fetch("creators")).to eq([{"affiliation"=>"DataCite",
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
      crosscite = JSON.parse(subject.crosscite)
      expect(crosscite.fetch("titles")).to eq([{"title"=>"Eating your own Dog Food"}])
      expect(crosscite.fetch("related_identifiers").count).to eq(3)
      expect(crosscite.fetch("related_identifiers").first).to eq("relatedIdentifier"=>"10.5438/0000-00ss", "relatedIdentifierType"=>"DOI", "relationType"=>"IsPartOf", "resourceTypeGeneral"=>"Text")
      expect(crosscite.fetch("related_identifiers").last).to eq("relatedIdentifier"=>"10.5438/55e5-t5c0", "relatedIdentifierType"=>"DOI", "relationType"=>"References")
    end
  end
end
