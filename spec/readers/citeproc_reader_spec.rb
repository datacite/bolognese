# frozen_string_literal: true

require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  let(:input) { fixture_path + "citeproc.json" }

  subject { Bolognese::Metadata.new(input: input, from: "citeproc") }

  context "get citeproc raw" do
    it "BlogPosting" do
      expect(subject.raw).to eq(IO.read(input).strip)
    end
  end

  context "get citeproc metadata" do
    it "BlogPosting" do
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(subject.url).to eq("https://blog.datacite.org/eating-your-own-dog-food")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"post-weblog", "resource_type_general"=>"Text", "ris"=>"GEN", "type"=>"BlogPosting")
      expect(subject.creator).to eq([{"familyName"=>"Fenner", "givenName"=>"Martin", "name"=>"Martin Fenner", "type"=>"Person"}])
      expect(subject.titles).to eq([{"title"=>"Eating your own Dog Food"}])
      expect(subject.descriptions.first["description"]).to start_with("Eating your own dog food")
      expect(subject.dates).to eq([{"date"=>"2016-12-20", "date_type"=>"Issued"}])
      expect(subject.publication_year).to eq("2016")
    end
  end
end
