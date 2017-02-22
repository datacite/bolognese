require 'spec_helper'
require 'bolognese/cli'

describe Bolognese::CLI do
  let(:subject) do
    described_class.new
  end

  describe "convert from id", vcr: true do
    context "crossref" do
      let(:id) { "10.7554/eLife.01567" }

      it 'default' do
        expect { subject.convert id }.to output(/additionalType/).to_stdout
      end

      it 'to schema_org' do
        subject.options = { to: "schema_org" }
        expect { subject.convert id }.to output(/additionalType/).to_stdout
      end

      it 'to crossref' do
        subject.options = { to: "crossref" }
        expect { subject.convert id }.to output(/journal_metadata/).to_stdout
      end

      it 'to datacite' do
        subject.options = { to: "datacite" }
        expect { subject.convert id }.to output(/http:\/\/datacite.org\/schema\/kernel-4/).to_stdout
      end

      it 'to bibtex' do
        subject.options = { to: "bibtex" }
        expect { subject.convert id }.to output(/@article{https:\/\/doi.org\/10.7554\/elife.01567/).to_stdout
      end
    end

    context "datacite" do
      let(:id) { "10.5061/dryad.8515" }

      it 'default' do
        expect { subject.convert id }.to output(/Phylogeny, Malaria, Parasites, Taxonomy, Mitochondrial genome, Africa, Plasmodium/).to_stdout
      end

      it 'to schema_org' do
        subject.options = { to: "schema_org" }
        expect { subject.convert id }.to output(/Phylogeny, Malaria, Parasites, Taxonomy, Mitochondrial genome, Africa, Plasmodium/).to_stdout
      end

      it 'to bibtex' do
        subject.options = { to: "bibtex" }
        expect { subject.convert id }.to output(/@misc{https:\/\/doi.org\/10.5061\/dryad.8515/).to_stdout
      end

      it 'to datacite' do
        subject.options = { to: "datacite" }
        expect { subject.convert id }.to output(/http:\/\/datacite.org\/schema\/kernel-3/).to_stdout
      end
    end

    context "schema_org" do
      let(:id) { "https://blog.datacite.org/eating-your-own-dog-food" }

      it 'default' do
        expect { subject.convert id }.to output(/datacite, doi, metadata, featured/).to_stdout
      end

      it 'to schema_org' do
        subject.options = { to: "schema_org" }
        expect { subject.convert id }.to output(/datacite, doi, metadata, featured/).to_stdout
      end

      it 'to datacite' do
        subject.options = { to: "datacite" }
        expect { subject.convert id }.to output(/http:\/\/datacite.org\/schema\/kernel-4/).to_stdout
      end

      it 'to bibtex' do
        subject.options = { to: "bibtex" }
        expect { subject.convert id }.to output(/@article{https:\/\/doi.org\/10.5438\/4k3m-nyvg/).to_stdout
      end
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

    context "crossref" do
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
        expect { subject.convert file }.to output(/@article{https:\/\/doi.org\/10.1371\/journal.pone.0000030/).to_stdout
      end
    end

    context "datacite" do
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
        subject.options = { to: "datacite" }
        expect { subject.convert file }.to output(/http:\/\/datacite.org\/schema\/kernel-4/).to_stdout
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
