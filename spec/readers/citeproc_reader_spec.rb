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
      expect(subject.type).to eq("BlogPosting")
      expect(subject.resource_type_general).to eq("Text")
      expect(subject.creator).to eq("type"=>"Person", "name"=>"Martin Fenner", "givenName"=>"Martin", "familyName"=>"Fenner")
      expect(subject.title).to eq("Eating your own Dog Food")
      expect(subject.description["text"]).to start_with("Eating your own dog food")
      expect(subject.date_published).to eq("2016-12-20")
    end
  end
end
