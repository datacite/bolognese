require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  context "write metadata as citation" do
    it "Journal article" do
      input = "10.7554/eLife.01567"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      expect(subject.style).to eq("apa")
      expect(subject.locale).to eq("en-US")
      expect(subject.citation).to eq("Sankar, M., Nieminen, K., Ragni, L., Xenarios, I., & Hardtke, C. S. (2014). Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth. eLife, 3. https://doi.org/10.7554/elife.01567")
    end

    it "Journal article vancouver style" do
      input = "10.7554/eLife.01567"
      subject = Bolognese::Metadata.new(input: input, from: "crossref", style: "vancouver", locale: "de-de")
      expect(subject.style).to eq("vancouver")
      expect(subject.locale).to eq("de-de")
      expect(subject.citation).to eq("1. Sankar M, Nieminen K, Ragni L, Xenarios I, Hardtke CS. Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth. eLife [Internet]. 2014 Feb 11;3. Available from: http://elifesciences.org/lookup/doi/10.7554/eLife.01567")
    end

    it "Dataset" do
      input = "https://doi.org/10.5061/DRYAD.8515"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      expect(subject.citation).to eq("Ollomo, B., Durand, P., Prugnolle, F., Douzery, E. J. P., Arnathau, C., Nkoghe, D., … Renaud, F. (2011). Data from: A new malaria agent in African hominids. (Version 1) [Data set]. Dryad Digital Repository. https://doi.org/10.5061/dryad.8515")
    end
  end
end
