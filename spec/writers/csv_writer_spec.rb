# frozen_string_literal: true

require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  context "write metadata as csv" do
    it "with data citation" do
      input = "10.7554/eLife.01567"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      csv = (subject.csv).parse_csv
      
      expect(csv[0]).to eq("10.7554/elife.01567")
      expect(csv[1]).to eq("https://elifesciences.org/articles/01567")
      expect(csv[2]).to eq("2018-08-23")
      expect(csv[3]).to eq("findable")
      expect(csv[4]).to eq("Text")
      expect(csv[5]).to eq("JournalArticle")
      expect(csv[6]).to eq("Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
      expect(csv[7]).to eq("Sankar, Martial and Nieminen, Kaisa and Ragni, Laura and Xenarios, Ioannis and Hardtke, Christian S")
      expect(csv[8]).to eq("eLife Sciences Publications, Ltd")
      expect(csv[9]).to eq("2014")
    end

    it "with pages" do
      input = "https://doi.org/10.1155/2012/291294"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      csv = (subject.csv).parse_csv

      expect(csv[0]).to eq("10.1155/2012/291294")
      expect(csv[1]).to eq("http://www.hindawi.com/journals/pm/2012/291294/")
      expect(csv[2]).to eq("2016-08-02")
      expect(csv[3]).to eq("findable")
      expect(csv[4]).to eq("Text")
      expect(csv[5]).to eq("JournalArticle")
      expect(csv[6]).to eq("Delineating a Retesting Zone Using Receiver Operating Characteristic Analysis on Serial QuantiFERON Tuberculosis Test Results in US Healthcare Workers")
      expect(csv[7]).to eq("Thanassi, Wendy and Noda, Art and Hernandez, Beatriz and Newell, Jeffery and Terpeluk, Paul and Marder, David and Yesavage, Jerome A.")
      expect(csv[8]).to eq("Hindawi Limited")
      expect(csv[9]).to eq("2012")
    end

    it "text" do
      input = "https://doi.org/10.3204/desy-2014-01645"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")

      expect(subject.valid?).to be true
      csv = (subject.csv).parse_csv

      expect(csv[0]).to eq("10.3204/desy-2014-01645")
      expect(csv[1]).to eq("http://bib-pubdb1.desy.de/record/166827")
      expect(csv[2]).to eq("2018-01-25")
      expect(csv[3]).to eq("findable")
      expect(csv[4]).to eq("Text")
      expect(csv[5]).to eq("Dissertation")
      expect(csv[6]).to eq("Dynamics of colloids in molecular glass forming liquids studied via X-ray photon correlation spectroscopy")
      expect(csv[7]).to eq("Conrad, Heiko")
      expect(csv[9]).to eq("2014")
    end

    it "climate data" do
      input = "https://doi.org/10.5067/altcy-tj122"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      expect(subject.valid?).to be true
      csv = (subject.csv).parse_csv

      expect(csv[0]).to eq("10.5067/altcy-tj122")
      expect(csv[1]).to eq("http://podaac.jpl.nasa.gov/dataset/MERGED_TP_J1_OSTM_OST_CYCLES_V2")
      expect(csv[2]).to eq("2014-01-15")
      expect(csv[3]).to eq("findable")
      expect(csv[4]).to eq("Dataset")
      expect(csv[5]).to be_nil
      expect(csv[6]).to eq("Integrated Multi-Mission Ocean Altimeter Data for Climate Research Version 2")
      expect(csv[7]).to eq("{GSFC}")
      expect(csv[8]).to eq("NASA Physical Oceanography DAAC")
      expect(csv[9]).to eq("2012")
    end
    
    it "maremma" do
      input = "https://github.com/datacite/maremma"
      subject = Bolognese::Metadata.new(input: input, from: "codemeta")
      csv = (subject.csv).parse_csv

      expect(csv[0]).to eq("10.5438/qeg0-3gm3")
      expect(csv[1]).to eq("https://github.com/datacite/maremma")
      expect(csv[2]).to be_nil
      expect(csv[3]).to eq("findable")
      expect(csv[4]).to eq("Software")
      expect(csv[5]).to be_nil
      expect(csv[6]).to eq("Maremma: a Ruby library for simplified network calls")
      expect(csv[7]).to eq("Fenner, Martin")
      expect(csv[8]).to eq("DataCite")
      expect(csv[9]).to eq("2017")
    end
  end
end
