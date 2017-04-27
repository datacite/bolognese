require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  let(:input) { fixture_path + "citeproc.json" }

  subject { Bolognese::Metadata.new(input: input) }

  context "get metadata as datacite xml" do
    it "BlogPosting" do
      datacite = Maremma.from_xml(subject.datacite).fetch("resource", {})
      expect(datacite.dig("resourceType", "resourceTypeGeneral")).to eq("Text")
      expect(datacite.dig("titles", "title")).to eq("Eating your own Dog Food")
      expect(datacite.dig("descriptions", "description", "__content__")).to start_with("Eating your own dog food")
      expect(datacite.dig("creators", "creator")).to eq("creatorName"=>"Fenner, Martin", "givenName"=>"Martin", "familyName"=>"Fenner")
    end
  end

  context "get metadata as ris" do
    it "BlogPosting" do
      ris = subject.ris.split("\r\n")
      expect(ris[0]).to eq("TY - GEN")
      expect(ris[1]).to eq("T1 - Eating your own Dog Food")
      expect(ris[2]).to eq("T2 - DataCite Blog")
      expect(ris[3]).to eq("AU - Fenner, Martin")
      expect(ris[4]).to eq("DO - 10.5438/4k3m-nyvg")
      expect(ris[5]).to eq("UR - https://blog.datacite.org/eating-your-own-dog-food")
      expect(ris[6]).to eq("AB - Eating your own dog food is a slang term to describe that an organization should itself use the products and services it provides. For DataCite this means that we should use DOIs with appropriate metadata and strategies for long-term preservation for...")
      expect(ris[7]).to eq("PY - 2016")
      expect(ris[8]).to eq("PB - DataCite")
      expect(ris[9]).to eq("ER - ")
    end
  end

  context "get metadata as turtle" do
    it "BlogPosting" do
      ttl = subject.turtle.split("\n")
      expect(ttl[0]).to eq("@prefix schema: <http://schema.org/> .")
      expect(ttl[2]).to eq("<https://doi.org/10.5438/4k3m-nyvg> a schema:BlogPosting;")
    end
  end

  context "get metadata as rdf_xml" do
    it "BlogPosting" do
      rdf_xml = Maremma.from_xml(subject.rdf_xml).fetch("RDF", {})
      expect(rdf_xml.dig("BlogPosting", "rdf:about")).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(rdf_xml.dig("BlogPosting", "author", "Person", "name")).to eq("Martin Fenner")
      expect(rdf_xml.dig("BlogPosting", "name")).to eq("Eating your own Dog Food")
      expect(rdf_xml.dig("BlogPosting", "datePublished", "__content__")).to eq("2016-12-20")
    end
  end
end
