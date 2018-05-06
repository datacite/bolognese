require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  let(:input) { fixture_path + "crosscite.json" }

  subject { Bolognese::Metadata.new(input: input) }

  context "get crosscite raw" do
    it "SoftwareSourceCode" do
      expect(subject.raw).to eq(IO.read(input).strip)
    end
  end

  context "get crosscite metadata" do
    it "SoftwareSourceCode" do
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.5281/zenodo.48440")
      expect(subject.type).to eq("SoftwareSourceCode")
      expect(subject.resource_type_general).to eq("Software")
      expect(subject.author).to eq("type"=>"Person", "familyName" => "Garza", "givenName" => "Kristian", "name" => "Kristian Garza")
      expect(subject.title).to eq("Analysis Tools for Crossover Experiment of UI using Choice Architecture")
      expect(subject.description["text"]).to start_with("This tools are used to analyse the data produced by the Crosssover Experiment")
      expect(subject.date_published).to eq("2016-03-27")
    end

    it "SoftwareSourceCode as string" do
      input = IO.read(fixture_path + "crosscite.json")
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.5281/zenodo.48440")
      expect(subject.type).to eq("SoftwareSourceCode")
      expect(subject.resource_type_general).to eq("Software")
      expect(subject.author).to eq("type"=>"Person", "familyName" => "Garza", "givenName" => "Kristian", "name" => "Kristian Garza")
      expect(subject.title).to eq("Analysis Tools for Crossover Experiment of UI using Choice Architecture")
      expect(subject.description["text"]).to start_with("This tools are used to analyse the data produced by the Crosssover Experiment")
      expect(subject.date_published).to eq("2016-03-27")
    end
  end
end
