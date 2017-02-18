require 'spec_helper'
require 'bolognese/cli'

describe Bolognese::CLI do
  let(:subject) do
    described_class.new
  end

  describe "read", vcr: true do
    context "crossref" do
      let(:id) { "10.7554/eLife.01567" }

      it 'default' do
        expect { subject.read id }.to output(/additionalType/).to_stdout
      end

      it 'as schema_org' do
        subject.options = { as: "schema_org" }
        expect { subject.read id }.to output(/additionalType/).to_stdout
      end

      it 'as crossref' do
        subject.options = { as: "crossref" }
        expect { subject.read id }.to output(/journal_metadata/).to_stdout
      end

      it 'as datacite' do
        subject.options = { as: "datacite" }
        expect { subject.read id }.to output(/http:\/\/datacite.org\/schema\/kernel-4/).to_stdout
      end
    end

    context "datacite" do
      let(:id) { "10.5061/dryad.8515" }

      it 'default' do
        expect { subject.read id }.to output(/Phylogeny, Malaria, Parasites, Taxonomy, Mitochondrial genome, Africa, Plasmodium/).to_stdout
      end

      it 'as schema_org' do
        subject.options = { as: "schema_org" }
        expect { subject.read id }.to output(/Phylogeny, Malaria, Parasites, Taxonomy, Mitochondrial genome, Africa, Plasmodium/).to_stdout
      end

      it 'as datacite' do
        subject.options = { as: "datacite" }
        expect { subject.read id }.to output(/http:\/\/datacite.org\/schema\/kernel-3/).to_stdout
      end
    end

    context "schema_org" do
      let(:id) { "https://blog.datacite.org/eating-your-own-dog-food" }

      it 'default' do
        expect { subject.read id }.to output(/datacite, doi, metadata, featured/).to_stdout
      end

      it 'as schema_org' do
        subject.options = { as: "schema_org" }
        expect { subject.read id }.to output(/datacite, doi, metadata, featured/).to_stdout
      end

      it 'as datacite' do
        subject.options = { as: "datacite" }
        expect { subject.read id }.to output(/http:\/\/datacite.org\/schema\/kernel-4/).to_stdout
      end
    end
  end
end
