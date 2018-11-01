# frozen_string_literal: true

require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  context "write metadata as crosscite" do
    it "with data citation" do
      input = "10.7554/eLife.01567"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      crosscite = JSON.parse(subject.crosscite)
      expect(crosscite.fetch("url")).to eq("https://elifesciences.org/articles/01567")
      expect(crosscite.fetch("resource_type_general")).to eq("Text")
      expect(crosscite.fetch("title")).to eq("Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
      expect(crosscite.fetch("related_identifiers").length).to eq(27)
      expect(crosscite.fetch("related_identifiers").first).to eq("id"=>"2050-084X", "related_identifier_type"=>"ISSN", "relation_type"=>"IsPartOf", "title"=>"eLife", "type"=>"Periodical")
      expect(crosscite.fetch("related_identifiers").last).to eq(       +"id" => "10.1038/ncb2764",
        "related_identifier_type" => "DOI",
        "relation_type" => "References",
        "title" => "A screen for morphological complexity identifies regulators of switch-like transitions between discrete cell shapes")
      expect(crosscite.fetch("rights")).to eq("id"=>"http://creativecommons.org/licenses/by/3.0")
    end

    it "with ORCID ID" do
      input = "https://doi.org/10.1155/2012/291294"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      crosscite = JSON.parse(subject.crosscite)
      expect(crosscite.fetch("resource_type_general")).to eq("Text")
      expect(crosscite.fetch("creator").count).to eq(7)
      expect(crosscite.fetch("creator")[2]).to eq("type"=>"Person", "id"=>"http://orcid.org/0000-0003-2043-4925", "name"=>"Beatriz Hernandez", "givenName"=>"Beatriz", "familyName"=>"Hernandez")
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
      expect(crosscite.fetch("resource_type_general")).to eq("Text")
      expect(crosscite.fetch("title")).to eq("Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
      expect(crosscite.dig("description", "text")).to start_with("Among various advantages, their small size makes model organisms preferred subjects of investigation.")
      expect(crosscite.fetch("creator").count).to eq(5)
      expect(crosscite.fetch("creator").first).to eq("type"=>"Person", "name"=>"Martial Sankar", "givenName"=>"Martial", "familyName"=>"Sankar")
    end

    it "BlogPosting Citeproc JSON" do
      input = fixture_path + "citeproc.json"
      subject = Bolognese::Metadata.new(input: input, from: "citeproc")
      expect(subject.valid?).to be true
      crosscite = JSON.parse(subject.crosscite)
      expect(crosscite["resource_type_general"]).to eq("Text")
      expect(crosscite.fetch("title")).to eq("Eating your own Dog Food")
      expect(crosscite.dig("description", "text")).to start_with("Eating your own dog food")
      expect(crosscite.fetch("creator")).to eq("type"=>"Person", "name"=>"Martin Fenner", "givenName"=>"Martin", "familyName"=>"Fenner")
    end

    it "rdataone" do
      input = fixture_path + 'codemeta.json'
      subject = Bolognese::Metadata.new(input: input, from: "codemeta")
      crosscite = JSON.parse(subject.crosscite)
      expect(crosscite["title"]).to eq("R Interface to the DataONE REST API")
      expect(crosscite["creator"].length).to eq(3)
      expect(crosscite["creator"].last).to eq("type"=>"Organization", "name"=>"University Of California, Santa Barbara")
      expect(crosscite["version"]).to eq("2.0.0")
    end

    it "datacite database attributes" do
      input = "https://doi.org/10.5061/DRYAD.8515"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      crosscite = JSON.parse(subject.crosscite)
      expect(crosscite.fetch("url")).to eq("http://datadryad.org/resource/doi:10.5061/dryad.8515")
      expect(crosscite.fetch("title")).to eq("Data from: A new malaria agent in African hominids.")
      expect(crosscite.fetch("creator").length).to eq(8)
      expect(crosscite.fetch("creator").first).to eq("type"=>"Person", "familyName" => "Ollomo", "givenName" => "Benjamin", "name" => "Benjamin Ollomo")
      expect(crosscite.fetch("date_published")).to eq("2011")
      expect(crosscite.fetch("provider_id")).to eq("DRYAD")
      expect(crosscite.fetch("client_id")).to eq("DRYAD.DRYAD")
    end

    it "maremma" do
      input = "https://github.com/datacite/maremma"
      subject = Bolognese::Metadata.new(input: input, from: "codemeta")
      crosscite = JSON.parse(subject.crosscite)
      expect(crosscite.fetch("title")).to eq("Maremma: a Ruby library for simplified network calls")
      expect(crosscite.fetch("creator")).to eq("type"=>"Person", "id"=>"http://orcid.org/0000-0003-0077-4738", "name"=>"Martin Fenner", "givenName"=>"Martin", "familyName"=>"Fenner")
    end

    it "with data citation schema.org" do
      input = "https://blog.datacite.org/eating-your-own-dog-food/"
      subject = Bolognese::Metadata.new(input: input, from: "schema_org")
      expect(subject.valid?).to be true
      crosscite = JSON.parse(subject.crosscite)
      expect(crosscite.fetch("title")).to eq("Eating your own Dog Food")
      expect(crosscite.fetch("related_identifiers").count).to eq(3)
      expect(crosscite.fetch("related_identifiers").first).to eq("id"=>"10.5438/0000-00ss", "related_identifier_type"=>"DOI", "relation_type"=>"IsPartOf", "resource_type_general"=>"Text", "title"=>"DataCite Blog")
      expect(crosscite.fetch("related_identifiers").last).to eq("id"=>"10.5438/55e5-t5c0", "related_identifier_type"=>"DOI", "relation_type"=>"References")
    end
  end
end
