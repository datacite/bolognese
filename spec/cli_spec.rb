# frozen_string_literal: true

require 'spec_helper'
require 'bolognese/cli'

describe Bolognese::CLI do
  let(:subject) do
    described_class.new
  end

  describe "convert from id", vcr: true do
    context "crossref" do
      let(:input) { "10.7554/eLife.01567" }

      it 'default' do
        expect { subject.convert input }.to output(/additionalType/).to_stdout
      end

      it 'to schema_org' do
        subject.options = { to: "schema_org" }
        expect { subject.convert input }.to output(/additionalType/).to_stdout
      end

      it 'to crossref' do
        subject.options = { to: "crossref" }
        expect { subject.convert input }.to output(/journal_metadata/).to_stdout
      end

      it 'to datacite' do
        subject.options = { to: "datacite" }
        expect { subject.convert input }.to output(/http:\/\/datacite.org\/schema\/kernel-4/).to_stdout
      end

      it 'to bibtex' do
        subject.options = { to: "bibtex" }
        expect { subject.convert input }.to output(/@article{https:\/\/doi.org\/10.7554\/elife.01567/).to_stdout
      end

      it 'to citation' do
        subject.options = { to: "citation", style: "vancouver" }
        expect { subject.convert input }.to output(/Sankar M, Nieminen K, Ragni L, Xenarios I/).to_stdout
      end

      it 'to jats' do
        subject.options = { to: "jats" }
        expect { subject.convert input }.to output(/article-title/).to_stdout
      end
    end

    context "datacite" do
      let(:input) { "10.5061/dryad.8515" }

      it 'default' do
        expect { subject.convert input }.to output(/Plasmodium, malaria, taxonomy, mitochondrial genome, Parasites/).to_stdout
      end

      it 'to schema_org' do
        subject.options = { to: "schema_org" }
        expect { subject.convert input }.to output(/http:\/\/schema.org/).to_stdout
      end

      it 'to bibtex' do
        subject.options = { to: "bibtex" }
        expect { subject.convert input }.to output(/@misc{https:\/\/doi.org\/10.5061\/dryad.8515/).to_stdout
      end

      it 'to datacite' do
        subject.options = { to: "datacite" }
        expect { subject.convert input }.to output(/http:\/\/datacite.org\/schema\/kernel-4/).to_stdout
      end

      it 'to datacite_json' do
        subject.options = { to: "datacite_json" }
        expect { subject.convert input }.to output(/Renaud, François/).to_stdout
      end

      it 'to citation' do
        subject.options = { to: "citation", style: "vancouver" }
        expect { subject.convert input }.to output(/Ollomo B, Durand P, Prugnolle F, Douzery EJP/).to_stdout
      end

      it 'to jats' do
        subject.options = { to: "jats" }
        expect { subject.convert input }.to output(/data-title/).to_stdout
      end
    end

    context "schema_org" do
      let(:id) { "https://blog.datacite.org/eating-your-own-dog-food" }

      it 'default' do
        expect { subject.convert id }.to output(/http:\/\/schema.org/).to_stdout
      end

      it 'to schema_org' do
        subject.options = { to: "schema_org" }
        expect { subject.convert id }.to output(/http:\/\/schema.org/).to_stdout
      end

      it 'to datacite' do
        subject.options = { to: "datacite" }
        expect { subject.convert id }.to output(/http:\/\/datacite.org\/schema\/kernel-4/).to_stdout
      end

      # TODO
      # it 'to bibtex' do
      #   subject.options = { to: "bibtex" }
      #   expect { subject.convert id }.to output(/@article{https:\/\/doi.org\/10.5438\/4k3m-nyvg/).to_stdout
      # end
    end
  end

  describe "convert file" do
    context "bibtex" do
      let(:file) { fixture_path + "crossref.bib" }

      it 'default' do
        expect { subject.convert file }.to output(/datePublished/).to_stdout
      end

      it 'to schema_org' do
        subject.options = { to: "schema_org" }
        expect { subject.convert file }.to output(/datePublished/).to_stdout
      end

      it 'to datacite' do
        subject.options = { to: "datacite" }
        expect { subject.convert file }.to output(/http:\/\/datacite.org\/schema\/kernel-4/).to_stdout
      end
    end

    context "crossref", vcr: true do
      let(:file) { fixture_path + "crossref.xml" }

      it 'default' do
        expect { subject.convert file }.to output(/datePublished/).to_stdout
      end

      it 'to schema_org' do
        subject.options = { to: "schema_org" }
        expect { subject.convert file }.to output(/datePublished/).to_stdout
      end

      it 'to crossref' do
        subject.options = { to: "crossref" }
        expect { subject.convert file }.to output(/journal_metadata/).to_stdout
      end

      it 'to datacite' do
        subject.options = { to: "datacite" }
        expect { subject.convert file }.to output(/http:\/\/datacite.org\/schema\/kernel-4/).to_stdout
      end

      it 'to bibtex' do
        subject.options = { to: "bibtex" }
        expect { subject.convert file }.to output(/@article{https:\/\/doi.org\/10.7554\/elife.01567/).to_stdout
      end
    end

    context "datacite", vcr: true do
      let(:file) { fixture_path + "datacite.xml" }

      it 'default' do
        expect { subject.convert file }.to output(/datePublished/).to_stdout
      end

      it 'to schema_org' do
        subject.options = { to: "schema_org" }
        expect { subject.convert file }.to output(/datePublished/).to_stdout
      end

      it 'to datacite' do
        subject.options = { to: "datacite" }
        expect { subject.convert file }.to output(/http:\/\/datacite.org\/schema\/kernel-4/).to_stdout
      end

      it 'to bibtex' do
        subject.options = { to: "bibtex" }
        expect { subject.convert file }.to output(/@article{https:\/\/doi.org\/10.5438\/4k3m-nyvg/).to_stdout
      end

      it 'to datacite invalid' do
        file = fixture_path + "datacite_missing_creator.xml"
        subject.options = { to: "datacite", show_errors: "true" }
        expect { subject.convert file }.to output("4:0: ERROR: Element '{http://datacite.org/schema/kernel-4}creators': Missing child element(s). Expected is ( {http://datacite.org/schema/kernel-4}creator ).\n").to_stderr
      end

      it 'to datacite invalid ignore errors' do
        file = fixture_path + "datacite_missing_creator.xml"
        subject.options = { to: "datacite" }
        expect { subject.convert file }.to output(/http:\/\/datacite.org\/schema\/kernel-4/).to_stdout
      end
    end

    context "codemeta" do
      let(:file) { fixture_path + "codemeta.json" }

      it 'default' do
        expect { subject.convert file }.to output(/datePublished/).to_stdout
      end

      it 'to schema_org' do
        subject.options = { to: "schema_org" }
        expect { subject.convert file }.to output(/datePublished/).to_stdout
      end

      it 'to datacite' do
        subject.options = { to: "datacite" }
        expect { subject.convert file }.to output(/http:\/\/datacite.org\/schema\/kernel-4/).to_stdout
      end

      it 'to bibtex' do
        subject.options = { to: "bibtex" }
        expect { subject.convert file }.to output(/@misc{https:\/\/doi.org\/10.5063\/f1m61h5x/).to_stdout
      end
    end

    # context "unsupported format" do
    #   let(:file) { fixture_path + "crossref.xxx" }
    #
    #   it 'error' do
    #     expect { subject.convert file }.to output(/datePublished/).to_stderr
    #   end
    # end
  end
end
