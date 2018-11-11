# frozen_string_literal: true

require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  context "write metadata as datacite json" do
    it "with data citation" do
      input = "10.7554/eLife.01567"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      datacite = JSON.parse(subject.datacite_json)
      expect(datacite.fetch("url")).to eq("https://elifesciences.org/articles/01567")
      expect(datacite.fetch("resource-type-general")).to eq("Text")
      expect(datacite.fetch("title")).to eq([{"text"=>"Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth"}])
      expect(datacite.fetch("related-identifiers").length).to eq(27)
      expect(datacite.fetch("related-identifiers").first).to eq("id"=>"2050-084X", "related_identifier_type"=>"ISSN", "relation_type"=>"IsPartOf", "title"=>"eLife", "type"=>"Periodical")
      expect(datacite.fetch("rights")).to eq([{"id"=>"http://creativecommons.org/licenses/by/3.0"}])
    end

    it "with ORCID ID" do
      input = "https://doi.org/10.1155/2012/291294"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      datacite = JSON.parse(subject.datacite_json)
      expect(datacite.fetch("url")).to eq("http://www.hindawi.com/journals/pm/2012/291294/")
      expect(datacite.fetch("resource-type-general")).to eq("Text")
      expect(datacite.fetch("creator").length).to eq(7)
      expect(datacite.fetch("creator").first).to eq("type"=>"Person", "name"=>"Wendy Thanassi", "givenName"=>"Wendy", "familyName"=>"Thanassi")
    end

    it "Crossref DOI" do
      input = fixture_path + "crossref.bib"
      subject = Bolognese::Metadata.new(input: input, from: "bibtex")
      datacite = JSON.parse(subject.datacite_json)
      expect(datacite.fetch("resource-type-general")).to eq("Text")
      expect(datacite.fetch("title")).to eq([{"text"=>"Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth"}])
      expect(datacite.dig("description", 0, "text")).to start_with("Among various advantages, their small size makes model organisms preferred subjects of investigation.")
      expect(datacite.fetch("creator").length).to eq(5)
      expect(datacite.fetch("creator").first).to eq("type"=>"Person", "name"=>"Martial Sankar", "givenName"=>"Martial", "familyName"=>"Sankar")
    end

    it "BlogPosting Citeproc JSON" do
      input = fixture_path + "citeproc.json"
      subject = Bolognese::Metadata.new(input: input, from: "citeproc")
      datacite = JSON.parse(subject.datacite_json)
      expect(datacite.fetch("resource-type-general")).to eq("Text")
      expect(datacite.fetch("title")).to eq([{"text"=>"Eating your own Dog Food"}])
      expect(datacite.dig("description", 0, "text")).to start_with("Eating your own dog food")
      expect(datacite.fetch("creator")).to eq("type"=>"Person", "name"=>"Martin Fenner", "givenName"=>"Martin", "familyName"=>"Fenner")
    end

    it "rdataone" do
      input = fixture_path + 'codemeta.json'
      subject = Bolognese::Metadata.new(input: input, from: "codemeta")
      datacite = JSON.parse(subject.datacite_json)
      expect(datacite.fetch("title")).to eq([{"text"=>"R Interface to the DataONE REST API"}])
      expect(datacite.fetch("creator").length).to eq(3)
      expect(datacite.fetch("creator").first).to eq("type"=>"Person", "id"=>"http://orcid.org/0000-0003-0077-4738", "name"=>"Matt Jones", "givenName"=>"Matt", "familyName"=>"Jones")
      expect(datacite.fetch("version")).to eq("2.0.0")
    end

    it "maremma" do
      input = "https://github.com/datacite/maremma"
      subject = Bolognese::Metadata.new(input: input, from: "codemeta")
      datacite = JSON.parse(subject.datacite_json)
      expect(datacite.fetch("title")).to eq([{"text"=>"Maremma: a Ruby library for simplified network calls"}])
      expect(datacite.fetch("creator")).to eq("type"=>"Person", "id"=>"http://orcid.org/0000-0003-0077-4738", "name"=>"Martin Fenner", "givenName"=>"Martin", "familyName"=>"Fenner")
    end

    it "with data citation schema.org" do
      input = "https://blog.datacite.org/eating-your-own-dog-food/"
      subject = Bolognese::Metadata.new(input: input, from: "schema_org")
      expect(subject.valid?).to be true
      datacite = JSON.parse(subject.datacite_json)
      expect(datacite.fetch("title")).to eq([{"text"=>"Eating your own Dog Food"}])
      expect(datacite.fetch("related-identifiers").count).to eq(3)
      expect(datacite.fetch("related-identifiers").first).to eq("id"=>"10.5438/0000-00ss", "related_identifier_type"=>"DOI", "relation_type"=>"IsPartOf", "resource_type_general"=>"Text", "title"=>"DataCite Blog")
    end
  end
end
