# frozen_string_literal: true

require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  let(:input) { fixture_path + "citeproc.json" }

  subject { Bolognese::Metadata.new(input: input, from: "citeproc") }

  context "get citeproc raw" do
    it "BlogPosting" do
      expect(subject.raw).to eq(IO.read(input).strip)
    end
  end

  context "get citeproc metadata" do
    it "BlogPosting" do
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(subject.url).to eq("https://blog.datacite.org/eating-your-own-dog-food")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"post-weblog", "resourceTypeGeneral"=>"Text", "ris"=>"GEN", "schemaOrg"=>"BlogPosting")
      expect(subject.creators).to eq([{"familyName"=>"Fenner", "givenName"=>"Martin", "name"=>"Fenner, Martin"}])
      expect(subject.publisher).to eq({"name"=>"DataCite"})
      expect(subject.titles).to eq([{"title"=>"Eating your own Dog Food"}])
      expect(subject.descriptions.first["description"]).to start_with("Eating your own dog food")
      expect(subject.dates).to eq([{"date"=>"2016-12-20", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2016")
    end
  end

  context "get citeproc no categories" do
    it "BlogPosting" do
      input = fixture_path + "citeproc-no-categories.json"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.5072/4k3m-nyvg")
      expect(subject.url).to eq("https://blog.datacite.org/eating-your-own-dog-food")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"post-weblog", "resourceTypeGeneral"=>"Text", "ris"=>"GEN", "schemaOrg"=>"BlogPosting")
      expect(subject.creators).to eq([{"familyName"=>"Fenner", "givenName"=>"Martin", "name"=>"Fenner, Martin"}])
      expect(subject.publisher).to eq({"name"=>"DataCite"})
      expect(subject.titles).to eq([{"title"=>"Eating your own Dog Food"}])
      expect(subject.descriptions.first["description"]).to start_with("Eating your own dog food")
      expect(subject.dates).to eq([{"date"=>"2016-12-20", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2016")
    end
  end

  context "get citeproc no author" do
    it "Journal article" do
      input = fixture_path + "citeproc-no-author.json"
      subject = Bolognese::Metadata.new(input: input)
      #expect(subject.valid?).to be true
      expect(subject.id).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(subject.url).to eq("https://blog.datacite.org/eating-your-own-dog-food")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"post-weblog", "resourceTypeGeneral"=>"Text", "ris"=>"GEN", "schemaOrg"=>"BlogPosting")
      expect(subject.creators).to eq([{"name"=>":(unav)", "nameType"=>"Organizational"}])
      expect(subject.publisher).to eq({"name"=>"DataCite"})
      expect(subject.titles).to eq([{"title"=>"Eating your own Dog Food"}])
      expect(subject.descriptions.first["description"]).to start_with("Eating your own dog food")
      expect(subject.dates).to eq([{"date"=>"2016-12-20", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2016")
    end
  end
end
