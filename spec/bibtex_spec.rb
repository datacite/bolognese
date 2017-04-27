require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  let(:input) { fixture_path + "crossref.bib" }

  subject { Bolognese::Metadata.new(input: input) }

  context "get metadata as datacite xml" do
    it "Crossref DOI" do
      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.dig("resourceType", "resourceTypeGeneral")).to eq("Text")
      expect(datacite.dig("titles", "title")).to eq("Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
      expect(datacite.dig("descriptions", "description", "__content__")).to start_with("Among various advantages, their small size makes model organisms preferred subjects of investigation.")
      expect(datacite.dig("creators", "creator").count).to eq(5)
      expect(datacite.dig("creators", "creator").first).to eq("creatorName"=>"Sankar, Martial", "givenName"=>"Martial", "familyName"=>"Sankar")
    end
  end

  context "get metadata as citeproc" do
    it "Crossref DOI" do
      json = JSON.parse(subject.citeproc)
      expect(json["type"]).to eq("article-journal")
      expect(json["id"]).to eq("https://doi.org/10.7554/elife.01567")
      expect(json["DOI"]).to eq("10.7554/elife.01567")
      expect(json["URL"]).to eq("http://elifesciences.org/lookup/doi/10.7554/eLife.01567")
      expect(json["title"]).to eq("Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
      expect(json["author"]).to eq([{"family"=>"Sankar", "given"=>"Martial"},
                                    {"family"=>"Nieminen", "given"=>"Kaisa"},
                                    {"family"=>"Ragni", "given"=>"Laura"},
                                    {"family"=>"Xenarios", "given"=>"Ioannis"},
                                    {"family"=>"Hardtke", "given"=>"Christian S"}])
      expect(json["container-title"]).to eq("eLife")
      expect(json["issued"]).to eq("date-parts" => [[2014]])
    end
  end

  context "get metadata as ris" do
    it "Crossref DOI" do
      ris = subject.ris.split("\r\n")
      expect(ris[0]).to eq("TY - JOUR")
      expect(ris[1]).to eq("T1 - Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
      expect(ris[2]).to eq("T2 - eLife")
      expect(ris[3]).to eq("AU - Sankar, Martial")
      expect(ris[8]).to eq("DO - 10.7554/elife.01567")
      expect(ris[9]).to eq("UR - http://elifesciences.org/lookup/doi/10.7554/eLife.01567")
      expect(ris[10]).to eq("AB - Among various advantages, their small size makes model organisms preferred subjects of investigation. Yet, even in model systems detailed analysis of numerous developmental processes at cellular level is severely hampered by their scale.")
      expect(ris[11]).to eq("PY - 2014")
      expect(ris[12]).to eq("PB - {eLife} Sciences Organisation, Ltd.")
      expect(ris[13]).to eq("VL - 3")
      expect(ris[14]).to eq("ER - ")
    end
  end

  context "get metadata as turtle" do
    it "Crossref DOI" do
      ttl = subject.turtle.split("\n")
      expect(ttl[0]).to eq("@prefix schema: <http://schema.org/> .")
      expect(ttl[2]).to eq("<https://doi.org/10.7554/elife.01567> a schema:ScholarlyArticle;")
    end
  end

  context "get metadata as rdf_xml" do
    it "Crossref DOI" do
      rdf_xml = Maremma.from_xml(subject.rdf_xml).fetch("RDF", {})
      expect(rdf_xml.dig("ScholarlyArticle", "rdf:about")).to eq("https://doi.org/10.7554/elife.01567")
      expect(rdf_xml.dig("ScholarlyArticle", "name")).to eq("Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
      expect(rdf_xml.dig("ScholarlyArticle", "datePublished", "__content__")).to eq("2014")
      expect(rdf_xml.dig("ScholarlyArticle", "isPartOf", "Periodical", "name")).to eq("eLife")
    end
  end
end
