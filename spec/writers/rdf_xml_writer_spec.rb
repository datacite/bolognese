# frozen_string_literal: true

require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  context "write metadata as rdf xml" do
    it "journal article" do
      input = "10.7554/eLife.01567"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      expect(subject.valid?).to be true
      rdf_xml = Maremma.from_xml(subject.rdf_xml).fetch("RDF", {})
      expect(rdf_xml.dig("ScholarlyArticle", "rdf:about")).to eq("https://doi.org/10.7554/elife.01567")
      expect(rdf_xml.dig("ScholarlyArticle", "name")).to eq("Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
      expect(rdf_xml.dig("ScholarlyArticle", "datePublished", "__content__")).to eq("2014-02-11")
      expect(rdf_xml.dig("ScholarlyArticle", "publisher", "Organization", "name")).to eq("eLife Sciences Publications, Ltd")
    end
    
    it "with pages" do
      input = "https://doi.org/10.1155/2012/291294"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      expect(subject.valid?).to be true
      rdf_xml = Maremma.from_xml(subject.rdf_xml).fetch("RDF", {})
      expect(rdf_xml.dig("ScholarlyArticle", "rdf:about")).to eq("https://doi.org/10.1155/2012/291294")
      expect(rdf_xml.dig("ScholarlyArticle", "name")).to eq("Delineating a Retesting Zone Using Receiver Operating Characteristic Analysis on Serial QuantiFERON Tuberculosis Test Results in US Healthcare Workers")
      expect(rdf_xml.dig("ScholarlyArticle", "datePublished", "__content__")).to eq("2012")
      expect(rdf_xml.dig("ScholarlyArticle", "pageStart")).to eq("1")
      expect(rdf_xml.dig("ScholarlyArticle", "pageEnd")).to eq("7")
      expect(rdf_xml.dig("ScholarlyArticle", "publisher", "Organization", "name")).to eq("Hindawi Limited")
    end

    it "Crossref DOI" do
      input = fixture_path + "crossref.bib"
      subject = Bolognese::Metadata.new(input: input, from: "bibtex")
      expect(subject.valid?).to be true
      rdf_xml = Maremma.from_xml(subject.rdf_xml).fetch("RDF", {})

      expect(rdf_xml.dig("ScholarlyArticle", "rdf:about")).to eq("https://doi.org/10.7554/elife.01567")
      expect(rdf_xml.dig("ScholarlyArticle", "name")).to eq("Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
      expect(rdf_xml.dig("ScholarlyArticle", "datePublished", "__content__")).to eq("2014")
      expect(rdf_xml.dig("ScholarlyArticle", "periodical", "Journal", "name")).to eq("eLife")
      expect(rdf_xml.dig("ScholarlyArticle", "publisher", "Organization", "name")).to eq("{eLife} Sciences Organisation, Ltd.")
    end

    it "BlogPosting" do
      input = "https://doi.org/10.5438/4K3M-NYVG"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      expect(subject.valid?).to be true
      rdf_xml = Maremma.from_xml(subject.rdf_xml).fetch("RDF", {})
      expect(rdf_xml.dig("ScholarlyArticle", "rdf:about")).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(rdf_xml.dig("ScholarlyArticle", "name")).to eq("Eating your own Dog Food")
      expect(rdf_xml.dig("ScholarlyArticle", "keywords")).to eq("datacite, doi, metadata, FOS: Computer and information sciences, FOS: Computer and information sciences")
      expect(rdf_xml.dig("ScholarlyArticle", "datePublished", "__content__")).to eq("2016-12-20")
      expect(rdf_xml.dig("ScholarlyArticle", "publisher", "Organization", "name")).to eq("DataCite")
    end
    
    it "BlogPosting Citeproc JSON" do
      input = fixture_path + "citeproc.json"
      subject = Bolognese::Metadata.new(input: input, from: "citeproc")
      rdf_xml = Maremma.from_xml(subject.rdf_xml).fetch("RDF", {})
      expect(rdf_xml.dig("BlogPosting", "rdf:about")).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(rdf_xml.dig("BlogPosting", "name")).to eq("Eating your own Dog Food")
      expect(rdf_xml.dig("BlogPosting", "datePublished", "__content__")).to eq("2016-12-20")
      expect(rdf_xml.dig("BlogPosting", "publisher", "Organization", "name")).to eq("DataCite")
    end
    
    it "maremma" do
      input = "https://github.com/datacite/maremma"
      subject = Bolognese::Metadata.new(input: input, from: "codemeta")
      rdf_xml = Maremma.from_xml(subject.rdf_xml).fetch("RDF", {})
      expect(rdf_xml.dig("SoftwareSourceCode", "rdf:about")).to eq("https://doi.org/10.5438/qeg0-3gm3")
      expect(rdf_xml.dig("SoftwareSourceCode", "author", "Person", "rdf:about")).to eq("https://orcid.org/0000-0003-0077-4738")
      expect(rdf_xml.dig("SoftwareSourceCode", "author", "Person", "name")).to eq("Martin Fenner")
      expect(rdf_xml.dig("SoftwareSourceCode", "name")).to eq("Maremma: a Ruby library for simplified network calls")
      expect(rdf_xml.dig("SoftwareSourceCode", "keywords")).to eq("faraday, excon, net/http")
      expect(rdf_xml.dig("SoftwareSourceCode", "datePublished", "__content__")).to eq("2017-02-24")
      expect(rdf_xml.dig("SoftwareSourceCode", "publisher", "Organization", "name")).to eq("DataCite")
    end

    it "BlogPosting schema.org" do
      input = "https://blog.datacite.org/eating-your-own-dog-food/"
      subject = Bolognese::Metadata.new(input: input, from: "schema_org")
      expect(subject.valid?).to be true
      rdf_xml = Maremma.from_xml(subject.rdf_xml).fetch("RDF", {})
      expect(rdf_xml.dig("BlogPosting", "rdf:about")).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(rdf_xml.dig("BlogPosting", "author", "Person", "rdf:about")).to eq("https://orcid.org/0000-0003-1419-2405")
      expect(rdf_xml.dig("BlogPosting", "author", "Person", "name")).to eq("Martin Fenner")
      expect(rdf_xml.dig("BlogPosting", "name")).to eq("Eating your own Dog Food")
      expect(rdf_xml.dig("BlogPosting", "keywords")).to eq("datacite, doi, metadata, featured")
      expect(rdf_xml.dig("BlogPosting", "datePublished", "__content__")).to eq("2016-12-20")
      expect(rdf_xml.dig("BlogPosting", "publisher", "Organization", "name")).to eq("DataCite")
    end
  end
end
