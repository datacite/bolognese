# frozen_string_literal: true

require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  context "write metadata as ris" do
    it "journal article" do
      input = "10.7554/eLife.01567"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      expect(subject.valid?).to be true
      ris = subject.ris.split("\r\n")
      expect(ris[0]).to eq("TY  - JOUR")
      expect(ris[1]).to eq("T1  - Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
      expect(ris[2]).to eq("T2  - eLife")
      expect(ris[3]).to eq("AU  - Sankar, Martial")
      expect(ris[8]).to eq("DO  - 10.7554/elife.01567")
      expect(ris[9]).to eq("UR  - https://elifesciences.org/articles/01567")
      expect(ris[10]).to  start_with("AB  - Among various advantages")
      expect(ris[11]).to eq("PY  - 2014")
      expect(ris[12]).to eq("VL  - 3")
      expect(ris[13]).to eq("ER  - ")
    end

    it "with pages" do
      input = "https://doi.org/10.1155/2012/291294"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      expect(subject.valid?).to be true
      ris = subject.ris.split("\r\n")
      expect(ris[0]).to eq("TY  - JOUR")
      expect(ris[1]).to eq("T1  - Delineating a Retesting Zone Using Receiver Operating Characteristic Analysis on Serial QuantiFERON Tuberculosis Test Results in US Healthcare Workers")
      expect(ris[2]).to eq("T2  - Pulmonary Medicine")
      expect(ris[3]).to eq("AU  - Thanassi, Wendy")
      expect(ris[10]).to eq("DO  - 10.1155/2012/291294")
      expect(ris[11]).to eq("UR  - http://www.hindawi.com/journals/pm/2012/291294/")
      expect(ris[12]).to start_with("AB  - . To find a statistically significant separation point for the QuantiFERON")
      expect(ris[13]).to eq("PY  - 2012")
      expect(ris[14]).to eq("VL  - 2012")
      expect(ris[15]).to eq("SP  - 1")
      expect(ris[16]).to eq("EP  - 7")
      expect(ris[17]).to eq("ER  - ")
    end

    it "alternate name" do
      input = "https://doi.org/10.3205/ZMA001102"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      expect(subject.valid?).to be true
      ris = subject.ris.split("\r\n")
      expect(ris[0]).to eq("TY  - RPRT")
      expect(ris[1]).to eq("T1  - Visions and reality: the idea of competence-oriented assessment for German medical students is not yet realised in licensing examinations")
      expect(ris[2]).to eq("T2  - GMS Journal for Medical Education; 34(2):Doc25")
      expect(ris[3]).to eq("AU  - Huber-Lang, Markus")
      expect(ris[9]).to eq("DO  - 10.3205/zma001102")
      expect(ris[10]).to start_with("AB  - Objective: Competence orientation")
      expect(ris[11]).to eq("KW  - medical competence")
      expect(ris[21]).to eq("PY  - 2017")
      expect(ris[22]).to eq("PB  - German Medical Science GMS Publishing House")
      expect(ris[23]).to eq("AN  - urn:nbn:de:0183-zma0011024")
      expect(ris[25]).to eq("LA  - en")
      expect(ris[26]).to eq("ER  - ")
    end

    it "Crossref DOI" do
      input = fixture_path + "crossref.bib"
      subject = Bolognese::Metadata.new(input: input, from: "bibtex")
      ris = subject.ris.split("\r\n")
      expect(ris[0]).to eq("TY  - JOUR")
      expect(ris[1]).to eq("T1  - Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
      expect(ris[2]).to eq("T2  - eLife")
      expect(ris[3]).to eq("AU  - Sankar, Martial")
      expect(ris[8]).to eq("DO  - 10.7554/elife.01567")
      expect(ris[9]).to eq("UR  - http://elifesciences.org/lookup/doi/10.7554/eLife.01567")
      expect(ris[10]).to eq("AB  - Among various advantages, their small size makes model organisms preferred subjects of investigation. Yet, even in model systems detailed analysis of numerous developmental processes at cellular level is severely hampered by their scale.")
      expect(ris[11]).to eq("PY  - 2014")
      expect(ris[12]).to eq("PB  - {eLife} Sciences Organisation, Ltd.")
      expect(ris[13]).to eq("VL  - 3")
      expect(ris[14]).to eq("ER  - ")
    end

    it "BlogPosting" do
      input = "https://doi.org/10.5438/4K3M-NYVG"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      expect(subject.valid?).to be true
      ris = subject.ris.split("\r\n")
      expect(ris[0]).to eq("TY  - RPRT")
      expect(ris[1]).to eq("T1  - Eating your own Dog Food")
      expect(ris[2]).to eq("AU  - Fenner, Martin")
      expect(ris[3]).to eq("DO  - 10.5438/4k3m-nyvg")
      expect(ris[4]).to eq("AB  - Eating your own dog food is a slang term to describe that an organization should itself use the products and services it provides. For DataCite this means that we should use DOIs with appropriate metadata and strategies for long-term preservation for...")
      expect(ris[5]).to eq("KW  - datacite")
      expect(ris[8]).to eq("PY  - 2016")
      expect(ris[9]).to eq("PB  - DataCite")
      expect(ris[10]).to eq("AN  - MS-49-3632-5083")
      expect(ris[11]).to eq("ER  - ")
    end

    it "BlogPosting Citeproc JSON" do
      input = fixture_path + "citeproc.json"
      subject = Bolognese::Metadata.new(input: input, from: "citeproc")
      ris = subject.ris.split("\r\n")
      expect(ris[0]).to eq("TY  - GEN")
      expect(ris[1]).to eq("T1  - Eating your own Dog Food")
      expect(ris[2]).to eq("T2  - DataCite Blog")
      expect(ris[3]).to eq("AU  - Fenner, Martin")
      expect(ris[4]).to eq("DO  - 10.5438/4k3m-nyvg")
      expect(ris[5]).to eq("UR  - https://blog.datacite.org/eating-your-own-dog-food")
      expect(ris[6]).to eq("AB  - Eating your own dog food is a slang term to describe that an organization should itself use the products and services it provides. For DataCite this means that we should use DOIs with appropriate metadata and strategies for long-term preservation for...")
      expect(ris[7]).to eq("KW  - Phylogeny")
      expect(ris[14]).to eq("PY  - 2016")
      expect(ris[15]).to eq("PB  - DataCite")
      expect(ris[16]).to eq("ER  - ")
    end

    it "BlogPosting DataCite JSON" do
      input = fixture_path + "datacite.json"
      subject = Bolognese::Metadata.new(input: input, from: "datacite_json")
      ris = subject.ris.split("\r\n")
      expect(ris[0]).to eq("TY  - GEN")
      expect(ris[1]).to eq("T1  - Eating your own Dog Food")
      expect(ris[2]).to eq("AU  - Fenner, Martin")
      expect(ris[3]).to eq("DO  - 10.5438/4k3m-nyvg")
      expect(ris[4]).to eq("AB  - Eating your own dog food is a slang term to describe that an organization should itself use the products and services it provides. For DataCite this means that we should use DOIs with appropriate metadata and strategies for long-term preservation for...")
      expect(ris[5]).to eq("KW  - datacite")
      expect(ris[8]).to eq("PY  - 2016")
      expect(ris[9]).to eq("PB  - DataCite")
      expect(ris[10]).to eq("AN  - MS-49-3632-5083")
      expect(ris[11]).to eq("ER  - ")
    end

    it "BlogPosting schema.org" do
      input = "https://blog.datacite.org/eating-your-own-dog-food/"
      subject = Bolognese::Metadata.new(input: input, from: "schema_org")
      ris = subject.ris.split("\r\n")
      expect(ris[0]).to eq("TY  - GEN")
      expect(ris[1]).to eq("T1  - Eating your own Dog Food")
      expect(ris[2]).to eq("T2  - DataCite Blog")
      expect(ris[3]).to eq("AU  - Fenner, Martin")
      expect(ris[4]).to eq("DO  - 10.5438/4k3m-nyvg")
      expect(ris[5]).to eq("UR  - https://blog.datacite.org/eating-your-own-dog-food")
      expect(ris[6]).to eq("AB  - Eating your own dog food is a slang term to describe that an organization should itself use the products and services it provides. For DataCite this means that we should use DOIs with appropriate metadata and strategies for long-term preservation for...")
      expect(ris[7]).to eq("KW  - datacite")
      expect(ris[11]).to eq("PY  - 2016")
      expect(ris[12]).to eq("PB  - DataCite")
      expect(ris[13]).to eq("AN  - MS-49-3632-5083")
      expect(ris[14]).to eq("ER  - ")
    end

    it "Dataset" do
      input = "10.5061/DRYAD.8515"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      expect(subject.valid?).to be true
      ris = subject.ris.split("\r\n")
      expect(ris[0]).to eq("TY  - DATA")
      expect(ris[1]).to eq("T1  - Data from: A new malaria agent in African hominids.")
      expect(ris[2]).to eq("AU  - Ollomo, Benjamin")
      expect(ris[10]).to eq("DO  - 10.5061/dryad.8515")
      expect(ris[11]).to eq("UR  - http://datadryad.org/resource/doi:10.5061/dryad.8515")
      expect(ris[13]).to eq("KW  - Malaria")
      expect(ris[19]).to eq("PY  - 2011")
      expect(ris[20]).to eq("PB  - Dryad Digital Repository")
      expect(ris[21]).to eq("AN  - Ollomo B, Durand P, Prugnolle F, Douzery EJP, Arnathau C, Nkoghe D, Leroy E, Renaud F (2009) A new malaria agent in African hominids. PLoS Pathogens 5(5): e1000446.")
      expect(ris[22]).to eq("ER  - ")
    end

    it "maremma" do
      input = "https://github.com/datacite/maremma"
      subject = Bolognese::Metadata.new(input: input, from: "codemeta")
      ris = subject.ris.split("\r\n")
      expect(ris[0]).to eq("TY  - COMP")
      expect(ris[1]).to eq("T1  - Maremma: a Ruby library for simplified network calls")
      expect(ris[2]).to eq("AU  - Fenner, Martin")
      expect(ris[3]).to eq("DO  - 10.5438/qeg0-3gm3")
      expect(ris[4]).to eq("UR  - https://github.com/datacite/maremma")
      expect(ris[5]).to eq("AB  - Ruby utility library for network requests. Based on Faraday and Excon, provides a wrapper for XML/JSON parsing and error handling. All successful responses are returned as hash with key data, all errors in a JSONAPI-friendly hash with key errors.")
      expect(ris[6]).to eq("KW  - faraday")
      expect(ris[9]).to eq("PY  - 2017")
      expect(ris[10]).to eq("PB  - DataCite")
      expect(ris[11]).to eq("ER  - ")
    end

    it "keywords with subject scheme" do
      input = "https://doi.org/10.1594/pangaea.721193"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      ris = subject.ris.split("\r\n")
      expect(ris[0]).to eq("TY  - DATA")
      expect(ris[1]).to eq("T1  - Seawater carbonate chemistry and processes during experiments with Crassostrea gigas, 2007, supplement to: Kurihara, Haruko; Kato, Shoji; Ishimatsu, Atsushi (2007): Effects of increased seawater pCO2 on early development of the oyster Crassostrea gigas. Aquatic Biology, 1(1), 91-98")
      expect(ris[2]).to eq("AU  - Kurihara, Haruko")
      expect(ris[5]).to eq("DO  - 10.1594/pangaea.721193")
      expect(ris[6]).to eq("UR  - https://doi.pangaea.de/10.1594/PANGAEA.721193")
      expect(ris[8]).to eq("KW  - GetInfo")
      expect(ris[9]).to eq("KW  - Animalia")
      expect(ris[10]).to eq("KW  - Bottles or small containers/Aquaria ( 20 L)")
      expect(ris[49]).to eq("PY  - 2007")
      expect(ris[50]).to eq("PB  - PANGAEA - Data Publisher for Earth & Environmental Science")
      expect(ris[51]).to eq("LA  - eng")
      expect(ris[52]).to eq("ER  - ")
    end
  end
end
