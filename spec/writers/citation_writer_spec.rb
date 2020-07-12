# frozen_string_literal: true

require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  context "write metadata as citation" do
    it "Journal article" do
      input = "10.7554/eLife.01567"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      expect(subject.style).to eq("apa")
      expect(subject.locale).to eq("en-US")
      expect(subject.citation).to eq("Sankar, M., Nieminen, K., Ragni, L., Xenarios, I., &amp; Hardtke, C. S. (2014). Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth. <i>ELife</i>, <i>3</i>. https://doi.org/10.7554/elife.01567")
    end

    it "Journal article vancouver style" do
      input = "10.7554/eLife.01567"
      subject = Bolognese::Metadata.new(input: input, from: "crossref", style: "vancouver", locale: "en-US")
      expect(subject.style).to eq("vancouver")
      expect(subject.locale).to eq("en-US")
      expect(subject.citation).to eq("Sankar M, Nieminen K, Ragni L, Xenarios I, Hardtke CS. Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth. eLife [Internet]. 2014Feb11;3. Available from: https://elifesciences.org/articles/01567")
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
      expect(subject.citation).to eq("Lab For Exosphere And Near Space Environment Studies. (2019). <i>lenses-lab/LYAO_RT-2018JA026426: Original Release</i> (Version 1.0.0) [Computer software]. Zenodo. https://doi.org/10.5281/zenodo.2598836")
    end

    it "interactive resource without dates" do
      input = "https://doi.org/10.34747/g6yb-3412"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      expect(subject.style).to eq("apa")
      expect(subject.locale).to eq("en-US")
      expect(subject.citation).to eq("Clark, D. (2019). <i>Exploring the \"Many analysts, one dataset\" project from COS</i>. Gigantum, Inc. https://doi.org/10.34747/g6yb-3412")
    end
  end
end
