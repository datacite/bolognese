# frozen_string_literal: true

require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  context "write metadata as bibtex" do
    it "with data citation" do
      input = "10.7554/eLife.01567"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      bibtex = BibTeX.parse(subject.bibtex).to_a(quotes: '').first
      expect(bibtex[:bibtex_type].to_s).to eq("article")
      expect(bibtex[:bibtex_key]).to eq("https://doi.org/10.7554/elife.01567")
      expect(bibtex[:doi]).to eq("10.7554/elife.01567")
      expect(bibtex[:url]).to eq("https://elifesciences.org/articles/01567")
      expect(bibtex[:title]).to eq("Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
      expect(bibtex[:author]).to eq("Sankar, Martial and Nieminen, Kaisa and Ragni, Laura and Xenarios, Ioannis and Hardtke, Christian S")
      expect(bibtex[:journal]).to eq("eLife")
      expect(bibtex[:year]).to eq("2014")
      expect(bibtex[:copyright]).to eq("Creative Commons Attribution 3.0 Unported")
    end

    it "with schema_3" do
      # input = fixture_path + "datacite_kernel_3.json"
      input = fixture_path + "datacite_schema_3.xml"
      json = Bolognese::Metadata.new(input: input, from: "datacite")
      subject = Bolognese::Metadata.new(input: json.meta.to_json, from: "datacite_json")
      bibtex = BibTeX.parse(subject.bibtex).to_a(quotes: '').first
      expect(bibtex[:bibtex_type].to_s).to eq("misc")
      expect(bibtex[:bibtex_key]).to eq("https://doi.org/10.5061/dryad.8515")
      expect(bibtex[:doi]).to eq("10.5061/dryad.8515")
      expect(bibtex[:year]).to eq("2011")
    end

    it "with pages" do
      input = "https://doi.org/10.1155/2012/291294"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      bibtex = BibTeX.parse(subject.bibtex).to_a(quotes: '').first
      expect(bibtex[:bibtex_type].to_s).to eq("article")
      expect(bibtex[:bibtex_key]).to eq("https://doi.org/10.1155/2012/291294")
      expect(bibtex[:doi]).to eq("10.1155/2012/291294")
      expect(bibtex[:url]).to eq("http://www.hindawi.com/journals/pm/2012/291294/")
      expect(bibtex[:title]).to eq("Delineating a Retesting Zone Using Receiver Operating Characteristic Analysis on Serial QuantiFERON Tuberculosis Test Results in US Healthcare Workers")
      expect(bibtex[:author]).to eq("Thanassi, Wendy and Noda, Art and Hernandez, Beatriz and Newell, Jeffery and Terpeluk, Paul and Marder, David and Yesavage, Jerome A.")
      expect(bibtex[:journal]).to eq("Pulmonary Medicine")
      expect(bibtex[:pages]).to eq("1-7")
      expect(bibtex[:year]).to eq("2012")
      expect(bibtex[:copyright]).to eq("Creative Commons Attribution 3.0 Unported")
    end

    it "text" do
      input = "10.3204/desy-2014-01645"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      expect(subject.valid?).to be true
      bibtex = BibTeX.parse(subject.bibtex).to_a(quotes: '').first
      expect(bibtex[:bibtex_type].to_s).to eq("phdthesis")
      expect(bibtex[:bibtex_key]).to eq("https://doi.org/10.3204/desy-2014-01645")
      expect(bibtex[:doi]).to eq("10.3204/desy-2014-01645")
      expect(bibtex[:title]).to eq("Dynamics of colloids in molecular glass forming liquids studied via X-ray photon correlation spectroscopy")
      expect(bibtex[:pages]).to eq("2014-")
      expect(bibtex[:year]).to eq("2014")
    end

    it "climate data" do
      input = "https://doi.org/10.5067/altcy-tj122"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      expect(subject.valid?).to be true
      bibtex = BibTeX.parse(subject.bibtex).to_a(quotes: '').first
      expect(bibtex[:bibtex_type].to_s).to eq("misc")
      expect(bibtex[:bibtex_key]).to eq("https://doi.org/10.5067/altcy-tj122")
      expect(bibtex[:doi]).to eq("10.5067/altcy-tj122")
      expect(bibtex[:title]).to eq("Integrated Multi-Mission Ocean Altimeter Data for Climate Research Version 2")
      expect(bibtex[:pages]).to be_nil
    end
    
    it "maremma" do
      input = "https://github.com/datacite/maremma"
      subject = Bolognese::Metadata.new(input: input, from: "codemeta")
      bibtex = BibTeX.parse(subject.bibtex).to_a(quotes: '').first
      expect(bibtex[:bibtex_type].to_s).to eq("misc")
      expect(bibtex[:bibtex_key]).to eq("https://doi.org/10.5438/qeg0-3gm3")
      expect(bibtex[:doi]).to eq("10.5438/qeg0-3gm3")
      expect(bibtex[:url]).to eq("https://github.com/datacite/maremma")
      expect(bibtex[:title]).to eq("Maremma: a Ruby library for simplified network calls")
      expect(bibtex[:author]).to eq("Fenner, Martin")
      expect(bibtex[:publisher]).to eq("DataCite")
      expect(bibtex[:keywords]).to eq("faraday, excon, net/http")
      expect(bibtex[:year]).to eq("2017")
      expect(bibtex[:copyright]).to eq("MIT License")
    end

    it "BlogPosting from string" do
      input = fixture_path + "datacite.json"
      subject = Bolognese::Metadata.new(input: input, from: "datacite_json")
      expect(subject.valid?).to be true
      bibtex = BibTeX.parse(subject.bibtex).to_a(quotes: '').first
      expect(bibtex[:bibtex_type].to_s).to eq("article")
      expect(bibtex[:bibtex_key]).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(bibtex[:doi]).to eq("10.5438/4k3m-nyvg")
      expect(bibtex[:title]).to eq("Eating your own Dog Food")
      expect(bibtex[:author]).to eq("Fenner, Martin")
      expect(bibtex[:publisher]).to eq("DataCite")
      expect(bibtex[:year]).to eq("2016")
    end

    it "BlogPosting" do
      input = "https://doi.org/10.5438/4K3M-NYVG"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      bibtex = BibTeX.parse(subject.bibtex).to_a(quotes: '').first
      expect(bibtex[:bibtex_type].to_s).to eq("article")
      expect(bibtex[:bibtex_key]).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(bibtex[:doi]).to eq("10.5438/4k3m-nyvg")
      expect(bibtex[:title]).to eq("Eating your own Dog Food")
      expect(bibtex[:author]).to eq("Fenner, Martin")
      expect(bibtex[:publisher]).to eq("DataCite")
      expect(bibtex[:year]).to eq("2016")
    end

    it "Dataset" do
      input = "https://doi.org/10.5061/dryad.8515"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      bibtex = BibTeX.parse(subject.bibtex).to_a(quotes: '').first
      expect(bibtex[:bibtex_type].to_s).to eq("misc")
      expect(bibtex[:bibtex_key]).to eq("https://doi.org/10.5061/dryad.8515")
      expect(bibtex[:doi]).to eq("10.5061/dryad.8515")
      expect(bibtex[:title]).to eq("Data from: A new malaria agent in African hominids.")
      expect(bibtex[:author]).to eq("Ollomo, Benjamin and Durand, Patrick and Prugnolle, Franck and Douzery, Emmanuel J. P. and Arnathau, Céline and Nkoghe, Dieudonné and Leroy, Eric and Renaud, François")
      expect(bibtex[:publisher]).to eq("Dryad")
      expect(bibtex[:year]).to eq("2011")
      expect(bibtex[:copyright]).to eq("Creative Commons Zero v1.0 Universal")
    end

    it "from schema_org" do
      input = "https://blog.datacite.org/eating-your-own-dog-food/"
      subject = Bolognese::Metadata.new(input: input, from: "schema_org")
      bibtex = BibTeX.parse(subject.bibtex).to_a(quotes: '').first
      expect(bibtex[:bibtex_type].to_s).to eq("article")
      expect(bibtex[:bibtex_key]).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(bibtex[:doi]).to eq("10.5438/4k3m-nyvg")
      expect(bibtex[:title]).to eq("Eating your own Dog Food")
      expect(bibtex[:author]).to eq("Fenner, Martin")
      expect(bibtex[:publisher]).to eq("DataCite")
      expect(bibtex[:keywords]).to eq("datacite, doi, metadata, featured")
      expect(bibtex[:year]).to eq("2016")
    end

    it "authors with affiliations" do
      input = "10.16910/jemr.9.1.2"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      bibtex = BibTeX.parse(subject.bibtex).to_a(quotes: '').first
      expect(bibtex[:bibtex_type].to_s).to eq("misc")
      expect(bibtex[:bibtex_key]).to eq("https://doi.org/10.16910/jemr.9.1.2")
      expect(bibtex[:doi]).to eq("10.16910/jemr.9.1.2")
      expect(bibtex[:title]).to eq("Eye tracking scanpath analysis techniques on web pages: A survey, evaluation and comparison")
      expect(bibtex[:author]).to eq("{Eraslan, Sukru; University Of Manchester, UK, & Middle East Technical University, Northern Cyprus Campus,  Kalkanli, Guzelyurt, Turkey} and {Yesilada, Yeliz; Middle East Technical University, Northern Cyprus Campus, 99738 Kalkanli, Guzelyurt, Mersin 10, Turkey} and {Harper, Simon; School Of Computer Science, University Of Manchester, Manchester, United Kingdom}")
      expect(bibtex[:publisher]).to eq("eyemovement.org")
      expect(bibtex[:keywords]).to eq("eye tracking; eye movements; scanpaths; eye movement sequence; web pages; visual elements; web pages; scanpath analysis techniques; scanpath analysis; pattern detection; common scanpaths")
      expect(bibtex[:year]).to eq("2015")
      expect(bibtex[:copyright]).to eq("Creative Commons Attribution 4.0 International")
    end

    it "keywords subject scheme" do
      input = "https://doi.org/10.1594/pangaea.721193"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      bibtex = BibTeX.parse(subject.bibtex).to_a(quotes: '').first
      expect(bibtex[:bibtex_type].to_s).to eq("misc")
      expect(bibtex[:bibtex_key]).to eq("https://doi.org/10.1594/pangaea.721193")
      expect(bibtex[:doi]).to eq("10.1594/pangaea.721193")
      expect(bibtex[:keywords]).to start_with("Animalia, Bottles or small containers/Aquaria (&lt;20 L), Calcification/Dissolution")
      expect(bibtex[:year]).to eq("2007")
      expect(bibtex[:copyright]).to eq("Creative Commons Attribution 3.0 Unported")
    end

    it "author is organization" do
      input = fixture_path + 'gtex.xml'
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      bibtex = BibTeX.parse(subject.bibtex).to_a(quotes: '').first
      expect(bibtex[:bibtex_type].to_s).to eq("misc")
      expect(bibtex[:bibtex_key]).to eq("https://doi.org/10.25491/9hx8-ke93")
      expect(bibtex[:author]).to eq("{The GTEx Consortium}")
    end

    it "dataset neurophysiology" do
      input = fixture_path + 'datacite-schema-2.2.xml'
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      bibtex = BibTeX.parse(subject.bibtex).to_a(quotes: '').first
      expect(bibtex[:bibtex_type].to_s).to eq("misc")
      expect(bibtex[:bibtex_key]).to eq("https://doi.org/10.6080/k0f769gp")
      expect(bibtex[:doi]).to eq("10.6080/k0f769gp")
      expect(bibtex[:title]).to eq("Single-unit recordings from two auditory areas in male zebra finches")
      expect(bibtex[:author]).to eq("Theunissen, Frederic E. and Hauber, ME and Woolley, Sarah M. N. and Gill, Patrick and Shaevitz, SS and Amin, Noopur and Hsu, A and Singh, NC and Grace, GA and Fremouw, Thane and Zhang, Junli and Cassey, P and Doupe, AJ and David, SV and Vinje, WE")
      expect(bibtex[:publisher]).to eq("CRCNS.org")
      expect(bibtex[:keywords]).to eq("Neuroscience, Electrophysiology, auditory area, avian (zebra finch)")
      expect(bibtex[:year]).to eq("2009")
    end
  end
end
