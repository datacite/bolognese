require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  context "write metadata as citeproc" do
    it "Dataset" do
      input = "https://doi.org/10.5061/DRYAD.8515"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      expect(subject.valid?).to be true
      json = JSON.parse(subject.citeproc)
      expect(json["type"]).to eq("dataset")
      expect(json["id"]).to eq("https://doi.org/10.5061/dryad.8515")
      expect(json["DOI"]).to eq("10.5061/dryad.8515")
      expect(json["title"]).to eq("Data from: A new malaria agent in African hominids.")
      expect(json["author"]).to eq([{"family"=>"Ollomo", "given"=>"Benjamin"},
                                    {"family"=>"Durand", "given"=>"Patrick"},
                                    {"family"=>"Prugnolle", "given"=>"Franck"},
                                    {"family"=>"Douzery", "given"=>"Emmanuel J. P."},
                                    {"family"=>"Arnathau", "given"=>"Céline"},
                                    {"family"=>"Nkoghe", "given"=>"Dieudonné"},
                                    {"family"=>"Leroy", "given"=>"Eric"},
                                    {"family"=>"Renaud", "given"=>"François"}])
      expect(json["publisher"]).to eq("Dryad Digital Repository")
      expect(json["issued"]).to eq("date-parts" => [[2011]])
    end

    it "BlogPosting" do
      input = "https://doi.org/10.5438/4K3M-NYVG"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      expect(subject.valid?).to be true
      json = JSON.parse(subject.citeproc)
      expect(json["type"]).to eq("report")
      expect(json["id"]).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(json["DOI"]).to eq("10.5438/4k3m-nyvg")
      expect(json["title"]).to eq("Eating your own Dog Food")
      expect(json["author"]).to eq([{"family"=>"Fenner", "given"=>"Martin"}])
      expect(json["publisher"]).to eq("DataCite")
      expect(json["issued"]).to eq("date-parts"=>[[2016, 12, 20]])
    end

    it "BlogPosting DataCite JSON" do
      input = fixture_path + "datacite.json"
      subject = Bolognese::Metadata.new(input: input, from: "datacite_json")
      json = JSON.parse(subject.citeproc)
      expect(json["type"]).to eq("report")
      expect(json["id"]).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(json["DOI"]).to eq("10.5438/4k3m-nyvg")
      expect(json["title"]).to eq("Eating your own Dog Food")
      expect(json["author"]).to eq([{"family"=>"Fenner", "given"=>"Martin"}])
      expect(json["publisher"]).to eq("DataCite")
      expect(json["issued"]).to eq("date-parts" => [[2016, 12, 20]])
    end

    it "BlogPosting schema.org" do
      input = "https://blog.datacite.org/eating-your-own-dog-food/"
      subject = Bolognese::Metadata.new(input: input, from: "schema_org")
      json = JSON.parse(subject.citeproc)
      expect(json["type"]).to eq("post-weblog")
      expect(json["id"]).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(json["DOI"]).to eq("10.5438/4k3m-nyvg")
      expect(json["title"]).to eq("Eating your own Dog Food")
      expect(json["author"]).to eq([{"family"=>"Fenner", "given"=>"Martin"}])
      expect(json["publisher"]).to eq("DataCite")
      expect(json["issued"]).to eq("date-parts" => [[2016, 12, 20]])
    end

    it "journal article" do
      input = "10.7554/eLife.01567"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      expect(subject.valid?).to be true
      json = JSON.parse(subject.citeproc)
      expect(json["type"]).to eq("article-journal")
      expect(json["id"]).to eq("https://doi.org/10.7554/elife.01567")
      expect(json["DOI"]).to eq("10.7554/elife.01567")
      expect(json["title"]).to eq("Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
      expect(json["author"]).to eq([{"family"=>"Sankar", "given"=>"Martial"},
                                    {"family"=>"Nieminen", "given"=>"Kaisa"},
                                    {"family"=>"Ragni", "given"=>"Laura"},
                                    {"family"=>"Xenarios", "given"=>"Ioannis"},
                                    {"family"=>"Hardtke", "given"=>"Christian S"}])
      expect(json["container-title"]).to eq("eLife")
      expect(json["volume"]).to eq("3")
      expect(json["issued"]).to eq("date-parts" => [[2014, 2, 11]])
    end

    it "software" do
      input = "https://doi.org/10.6084/m9.figshare.4906367.v1"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      json = JSON.parse(subject.citeproc)
      expect(json["type"]).to eq("article")
      expect(json["DOI"]).to eq("10.6084/m9.figshare.4906367.v1")
      expect(json["title"]).to eq("Scimag catalogue of LibGen as of January 1st, 2014")
    end

    it "multiple abstracts" do
      input = "https://doi.org/10.12763/ona1045"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      json = JSON.parse(subject.citeproc)
      expect(json["type"]).to eq("report")
      expect(json["DOI"]).to eq("10.12763/ona1045")
      expect(json["abstract"]).to eq("Le code est accompagné de commentaires de F. A. Vogel, qui signe l'épitre dédicatoire")
    end

    it "with pages" do
      input = "https://doi.org/10.1155/2012/291294"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      expect(subject.valid?).to be true
      json = JSON.parse(subject.citeproc)
      expect(json["type"]).to eq("article-journal")
      expect(json["id"]).to eq("https://doi.org/10.1155/2012/291294")
      expect(json["DOI"]).to eq("10.1155/2012/291294")
      expect(json["title"]).to eq("Delineating a Retesting Zone Using Receiver Operating Characteristic Analysis on Serial QuantiFERON Tuberculosis Test Results in US Healthcare Workers")
      expect(json["author"]).to eq([{"family"=>"Thanassi", "given"=>"Wendy"},
                                    {"family"=>"Noda", "given"=>"Art"},
                                    {"family"=>"Hernandez", "given"=>"Beatriz"},
                                    {"family"=>"Newell", "given"=>"Jeffery"},
                                    {"family"=>"Terpeluk", "given"=>"Paul"},
                                    {"family"=>"Marder", "given"=>"David"},
                                    {"family"=>"Yesavage", "given"=>"Jerome A."}])
      expect(json["container-title"]).to eq("Pulmonary Medicine")
      expect(json["volume"]).to eq("2012")
      expect(json["page"]).to eq("1-7")
      expect(json["issued"]).to eq("date-parts"=>[[2012]])
    end

    it "container title" do
      input = "https://doi.org/10.6102/ZIS146"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      json = JSON.parse(subject.citeproc)
      expect(json["type"]).to eq("report")
      expect(json["id"]).to eq("https://doi.org/10.6102/zis146")
      expect(json["DOI"]).to eq("10.6102/zis146")
      expect(json["title"]).to eq("Deutsche Version der Positive and Negative Affect Schedule (PANAS)")
      expect(json["author"]).to eq([{"family"=>"Janke", "given"=>"S."},
                                    {"family"=>"Glöckner-Rist", "given"=>"A."}])
      expect(json["container-title"]).to be_nil
      expect(json["issued"]).to eq("date-parts" => [[2012]])
    end

    it "Crossref DOI" do
      input = fixture_path + "crossref.bib"
      subject = Bolognese::Metadata.new(input: input, from: "bibtex")
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

    it "maremma" do
      input = "https://github.com/datacite/maremma"
      subject = Bolognese::Metadata.new(input: input, from: "codemeta")
      json = JSON.parse(subject.citeproc)
      expect(json["type"]).to eq("article-journal")
      expect(json["id"]).to eq("https://doi.org/10.5438/qeg0-3gm3")
      expect(json["DOI"]).to eq("10.5438/qeg0-3gm3")
      expect(json["title"]).to eq("Maremma: a Ruby library for simplified network calls")
      expect(json["author"]).to eq([{"family"=>"Fenner", "given"=>"Martin"}])
      expect(json["publisher"]).to eq("DataCite")
      expect(json["issued"]).to eq("date-parts" => [[2017, 2, 24]])
    end
  end
end
