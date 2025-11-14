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

      expect(subject.citation).to eq("Ollomo, B., Durand, P., Prugnolle, F., Douzery, E. J. P., Arnathau, C., Nkoghe, D., Leroy, E., &amp; Renaud, F. (2011). <i>Data from: A new malaria agent in African hominids.</i> (Version 1) [Dataset]. Dryad. https://doi.org/10.5061/dryad.8515")
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

    it "software w/version with 'book' citeproc type" do
      input = "https://doi.org/10.5281/zenodo.2598836"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      subject.types["citeproc"] = "book"
      expect(subject.style).to eq("apa")
      expect(subject.locale).to eq("en-US")
      expect(subject.citation).to eq("Lab for Exosphere and Near Space Environment Studies. (2019). <i>lenses-lab/LYAO_RT-2018JA026426: Original Release</i> (Version 1.0.0) [Computer software]. Zenodo. https://doi.org/10.5281/zenodo.2598836")
    end

    it "software w/version with 'article' citeproc type and no version" do
      input = "https://doi.org/10.5281/zenodo.17597949"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      subject.types["citeproc"] = "article"
      expect(subject.style).to eq("apa")
      expect(subject.locale).to eq("en-US")
      expect(subject.citation).to eq("Garreau, A., &amp; Shestov, A. (2025). <i>Python scripts for GLOB</i> [Computer software]. Zenodo. https://doi.org/10.5281/zenodo.17597949")
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

    it "article-journal with apa" do
      input = "https://doi.org/10.34989/swp-2024-1"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      expect(subject.style).to eq("apa")
      expect(subject.locale).to eq("en-US")
      expect(subject.citation).to eq('Xie, S., Xie, V. W., &amp; zhang, xu. (2024). Extreme Weather and Low-Income Household Finance: Evidence from Payday Loans. <i>Bank of Canada</i>. https://doi.org/10.34989/swp-2024-1')
    end

    it "article-journal with harvard" do
      input = "https://doi.org/10.34989/swp-2024-1"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      subject.style = "harvard-cite-them-right"
      expect(subject.style).to eq("harvard-cite-them-right")
      expect(subject.locale).to eq("en-US")
      expect(subject.citation).to eq('Xie, S., Xie, V.W. and zhang, xu (2024) “Extreme Weather and Low-Income Household Finance: Evidence from Payday Loans,” <i>Bank of Canada</i> [Preprint]. Available at: https://doi.org/10.34989/swp-2024-1.')
    end

    it "article-journal with mla" do
      input = "https://doi.org/10.34989/swp-2024-1"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      subject.style = "modern-language-association"
      expect(subject.style).to eq("modern-language-association")
      expect(subject.locale).to eq("en-US")
      expect(subject.citation).to eq('Xie, Shihan, et al. “Extreme Weather and Low-Income Household Finance: Evidence from Payday Loans.” <i>Bank of Canada</i>, 2024, https://doi.org/10.34989/swp-2024-1.')
    end

    it "article-journal with vacouver" do
      input = "https://doi.org/10.34989/swp-2024-1"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      subject.style = "vancouver"
      expect(subject.style).to eq("vancouver")
      expect(subject.locale).to eq("en-US")
      expect(subject.citation).to eq('Xie S, Xie VW, zhang xu. Extreme Weather and Low-Income Household Finance: Evidence from Payday Loans. Bank of Canada [Internet]. 2024; Available from: https://www.bankofcanada.ca/2024/01/staff-working-paper-2024-1/')
    end

    it "article-journal with chicago" do
      input = "https://doi.org/10.34989/swp-2024-1"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      subject.style = "chicago-notes-bibliography"
      expect(subject.style).to eq("chicago-notes-bibliography")
      expect(subject.locale).to eq("en-US")
      expect(subject.citation).to eq('Xie, Shihan, Victoria Wenxin Xie, and xu zhang. “Extreme Weather and Low-Income Household Finance: Evidence from Payday Loans.” . . <i>Bank of Canada</i>, ahead of print, , Bank of Canada, 2024. https://doi.org/10.34989/swp-2024-1. .')
    end

    it "article-journal with ieee" do
      input = "https://doi.org/10.34989/swp-2024-1"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      subject.style = "ieee"
      expect(subject.style).to eq("ieee")
      expect(subject.locale).to eq("en-US")
      expect(subject.citation).to eq('S. Xie, V. W. Xie, and xu zhang, “Extreme Weather and Low-Income Household Finance: Evidence from Payday Loans,” <i>Bank of Canada</i>, 2024, doi: 10.34989/swp-2024-1.')
    end
  end
end
