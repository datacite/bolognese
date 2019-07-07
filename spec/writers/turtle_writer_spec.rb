# frozen_string_literal: true

require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  context "write metadata as turtle" do
    it "Crossref DOI" do
      input = fixture_path + "crossref.bib"
      subject = Bolognese::Metadata.new(input: input, from: "bibtex")
      ttl = subject.turtle.split("\n")
      expect(ttl[0]).to eq("@prefix schema: <http://schema.org/> .")
      expect(ttl[2]).to eq("<https://doi.org/10.7554/elife.01567> a schema:ScholarlyArticle;")
    end

    it "Dataset" do
      input = "https://doi.org/10.5061/DRYAD.8515"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      expect(subject.valid?).to be true
      ttl = subject.turtle.split("\n")
      expect(ttl[0]).to eq("@prefix schema: <http://schema.org/> .")
      expect(ttl[2]).to eq("<https://doi.org/10.1371/journal.ppat.1000446> a schema:ScholarlyArticle;")
    end

    # it "BlogPosting" do
    #   input= "https://doi.org/10.5438/4K3M-NYVG"
    #   subject = Bolognese::Metadata.new(input: input, from: "datacite")
    #   expect(subject.valid?).to be true
    #   ttl = subject.turtle.split("\n")
    #   expect(ttl[0]).to eq("@prefix schema: <http://schema.org/> .")
    #   expect(ttl[2]).to eq("<https://doi.org/10.5438/4k3m-nyvg> a schema:ScholarlyArticle;")
    # end

    it "BlogPosting Citeproc JSON" do
      input = fixture_path + "citeproc.json"
      subject = Bolognese::Metadata.new(input: input, from: "citeproc")
      ttl = subject.turtle.split("\n")
      expect(ttl[0]).to eq("@prefix schema: <http://schema.org/> .")
      expect(ttl[2]).to eq("<https://doi.org/10.5438/4k3m-nyvg> a schema:BlogPosting;")
    end

    # it "BlogPosting DataCite JSON" do
    #   input = fixture_path + "datacite.json"
    #   subject = Bolognese::Metadata.new(input: input, from: "datacite_json")
    #   ttl = subject.turtle.split("\n")
    #   expect(ttl[0]).to eq("@prefix schema: <http://schema.org/> .")
    #   expect(ttl[2]).to eq("<https://doi.org/10.5438/4k3m-nyvg> a schema:ScholarlyArticle;")
    # end

    # it "BlogPosting schema.org" do
    #   input = "https://blog.datacite.org/eating-your-own-dog-food/"
    #   subject = Bolognese::Metadata.new(input: input, from: "schema_org")
    #   expect(subject.valid?).to be true
    #   ttl = subject.turtle.split("\n")
    #   expect(ttl[0]).to eq("@prefix schema: <http://schema.org/> .")
    #   expect(ttl[2]).to eq("<https://doi.org/10.5438/4k3m-nyvg> a schema:ScholarlyArticle;")
    # end

    # it "DataONE" do
    #   input = fixture_path + 'codemeta.json'
    #   subject = Bolognese::Metadata.new(input: input, from: "codemeta")
    #   ttl = subject.turtle.split("\n")
    #   expect(ttl[0]).to eq("@prefix schema: <http://schema.org/> .")
    #   expect(ttl[2]).to eq("<https://doi.org/10.5063/f1m61h5x> a schema:SoftwareSourceCode;")
    # end

    # it "journal article" do
    #   input = "10.7554/eLife.01567"
    #   subject = Bolognese::Metadata.new(input: input, from: "crossref")
    #   expect(subject.valid?).to be true
    #   ttl = subject.turtle.split("\n")
    #   expect(ttl[0]).to eq("@prefix schema: <http://schema.org/> .")
    #   expect(ttl[2]).to eq("<https://doi.org/10.7554/elife.01567> a schema:ScholarlyArticle;")
    # end

    # it "with pages" do
    #   input = "https://doi.org/10.1155/2012/291294"
    #   subject = Bolognese::Metadata.new(input: input, from: "crossref")
    #   expect(subject.valid?).to be true
    #   ttl = subject.turtle.split("\n")
    #   expect(ttl[0]).to eq("@prefix schema: <http://schema.org/> .")
    #   expect(ttl[2]).to eq("<https://doi.org/10.1155/2012/291294> a schema:ScholarlyArticle;")
    # end
  end
end
