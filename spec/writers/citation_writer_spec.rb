# frozen_string_literal: true

require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  context "write metadata as citation" do
    it "Journal article" do
      input = "10.7554/eLife.01567"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      expect(subject.style).to eq("apa")
      expect(subject.locale).to eq("en-US")
      expect(subject.citation).to eq("Sankar, M., Nieminen, K., Ragni, L., Xenarios, I., &amp; Hardtke, C. S. (2014). Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth. <i>ELife</i>, <i>3</i>, e01567. https://doi.org/10.7554/elife.01567")
    end

    it "Journal article vancouver style" do
      input = "10.7554/eLife.01567"
      subject = Bolognese::Metadata.new(input: input, from: "crossref", style: "vancouver", locale: "en-US")
      expect(subject.style).to eq("vancouver")
      expect(subject.locale).to eq("en-US")
      expect(subject.citation).to eq("Sankar M, Nieminen K, Ragni L, Xenarios I, Hardtke CS. Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth. eLife [Internet]. 2014Feb11;3:e01567. Available from: https://elifesciences.org/articles/01567")
    end

    it "Dataset" do
      input = "https://doi.org/10.5061/DRYAD.8515"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")

      expect(subject.citation).to eq("Ollomo, B., Durand, P., Prugnolle, F., Douzery, E. J. P., Arnathau, C., Nkoghe, D., Leroy, E., &amp; Renaud, F. (2011). <i>Data from: A new malaria agent in African hominids.</i> (Version 1) [Data set]. Dryad. https://doi.org/10.5061/dryad.8515")
    end

    it "Missing author" do
      input = "https://doi.org/10.3390/publications6020015"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      expect(subject.citation).to eq("Alexander Kohls, &amp; Salvatore Mele. (2018). Converting the Literature of a Scientific Field to Open Access through Global Collaboration: The Experience of SCOAP3 in Particle Physics. <i>Publications</i>, <i>6</i>(2), 15. https://doi.org/10.3390/publications6020015")
    end

    it "software w/version" do
      input = "https://doi.org/10.5281/zenodo.2598836"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      expect(subject.style).to eq("apa")
      expect(subject.locale).to eq("en-US")
      expect(subject.citation).to eq("Lab for Exosphere and Near Space Environment Studies. (2019). <i>lenses-lab/LYAO_RT-2018JA026426: Original Release</i> (Version 1.0.0) [Computer software]. Zenodo. https://doi.org/10.5281/zenodo.2598836")
    end

    it "interactive resource without dates" do
      input = "https://doi.org/10.34747/g6yb-3412"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      expect(subject.style).to eq("apa")
      expect(subject.locale).to eq("en-US")
      expect(subject.citation).to eq("Clark, D. (2019). <i>Exploring the \"Many analysts, one dataset\" project from COS</i>. Gigantum, Inc. https://doi.org/10.34747/g6yb-3412")
    end

    it "journal article with container title" do
      input = fixture_path + "datacite_journal_article.xml"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      expect(subject.types["citeproc"]).to eq("article-journal")
      expect(subject.style).to eq("apa")
      expect(subject.locale).to eq("en-US")
      expect(subject.citation).to eq('Feldman, H. L. (1995). Science and Uncertainty in Mass Exposure Litigation. <i>Texas Law Review</i>. https://doi.org/10.60843/5egy-vc42')
    end

    # Citation styles used in DataCite Commons and Fabrica

    it "journal article with full container apa citation" do
      input = fixture_path + "datacite_with_container_and_seriesinformation_and_relateditem.json"
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.style).to eq("apa")
      expect(subject.locale).to eq("en-US")
      expect(subject.citation).to eq('Fenner, M. (2016). Eating your own Dog Food. In <i>Understanding the fictional John Smith</i> (No.1; Version 1.0, 1st ed., Vol. 776, Issue 1, pp. 50–60). DataCite. https://doi.org/10.5438/4k3m-nyvg')
    end

    it "journal article with full container harvard citation" do
      input = fixture_path + "datacite_with_container_and_seriesinformation_and_relateditem.json"
      subject = Bolognese::Metadata.new(input: input)
      subject.style = "harvard-cite-them-right"
      expect(subject.style).to eq("harvard-cite-them-right")
      expect(subject.locale).to eq("en-US")
      expect(subject.citation).to eq('Fenner, M. (2016) “Eating your own Dog Food,” <i>Understanding the fictional John Smith</i>. 1st edn. DataCite. doi: 10.5438/4k3m-nyvg.')
    end

    it "journal article with full container and mla citation" do
      input = fixture_path + "datacite_with_container_and_seriesinformation_and_relateditem.json"
      subject = Bolognese::Metadata.new(input: input)
      subject.style = "modern-language-association"
      expect(subject.style).to eq("modern-language-association")
      expect(subject.locale).to eq("en-US")
      expect(subject.citation).to eq('Fenner, Martin. “Eating Your Own Dog Food.” <i>Understanding the Fictional John Smith</i>, 1st ed., 1.0, vol. 776, no. 1, 1, DataCite, 20 Dec. 2016, pp. 50–60, doi:10.5438/4k3m-nyvg.')
    end

    it "journal article with full container and vancouver citation" do
      input = fixture_path + "datacite_with_container_and_seriesinformation_and_relateditem.json"
      subject = Bolognese::Metadata.new(input: input)
      subject.style = "vancouver"
      expect(subject.style).to eq("vancouver")
      expect(subject.locale).to eq("en-US")
      expect(subject.citation).to eq('Fenner M. Eating your own Dog Food [Internet]. 1st ed. Vol. 776, Understanding the fictional John Smith. DataCite; 2016. p. 50–60. Available from: https://datacite.org/blog/eating-your-own-dog-food.html')
    end

    it "journal article with full container and chicago citation" do
      input = fixture_path + "datacite_with_container_and_seriesinformation_and_relateditem.json"
      subject = Bolognese::Metadata.new(input: input)
      subject.style = "chicago-fullnote-bibliography"
      expect(subject.style).to eq("chicago-fullnote-bibliography")
      expect(subject.locale).to eq("en-US")
      expect(subject.citation).to eq('Fenner, Martin. “Eating Your Own Dog Food.” <i>Understanding the Fictional John Smith</i>. DataCite, December 20, 2016. https://doi.org/10.5438/4k3m-nyvg.')
    end

    it "journal article with full container and ieee citation" do
      input = fixture_path + "datacite_with_container_and_seriesinformation_and_relateditem.json"
      subject = Bolognese::Metadata.new(input: input)
      subject.style = "ieee"
      expect(subject.style).to eq("ieee")
      expect(subject.locale).to eq("en-US")
      expect(subject.citation).to eq('M. Fenner, “Eating your own Dog Food,” <i>Understanding the fictional John Smith</i>, vol. 776, no. 1. DataCite, pp. 50–60, Dec. 20, 2016, doi: 10.5438/4k3m-nyvg.')
    end
  end
end
