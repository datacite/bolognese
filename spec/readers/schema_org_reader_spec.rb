# frozen_string_literal: true

require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  let(:input) { "https://blog.datacite.org/eating-your-own-dog-food/" }
  let(:fixture_path) { "spec/fixtures/" }

  subject { Bolognese::Metadata.new(input: input) }

  context "get schema_org raw" do
    it "BlogPosting" do
      input = fixture_path + 'schema_org.json'
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.raw).to eq(IO.read(input).strip)
    end
  end

  context "get schema_org metadata" do
    it "BlogPosting" do
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(subject.b_url).to eq("https://blog.datacite.org/eating-your-own-dog-food")
      expect(subject.type).to eq("BlogPosting")
      expect(subject.author).to eq("type"=>"Person", "id"=>"https://orcid.org/0000-0003-1419-2405", "name"=>"Martin Fenner", "givenName"=>"Martin", "familyName"=>"Fenner")
      expect(subject.title).to eq("Eating your own Dog Food")
      expect(subject.description["text"]).to start_with("Eating your own dog food")
      expect(subject.keywords).to eq(["datacite", "doi", "metadata", "featured"])
      expect(subject.date_published).to eq("2016-12-20")
      expect(subject.date_modified).to eq("2016-12-20")
      expect(subject.is_part_of).to eq("id"=>"https://doi.org/10.5438/0000-00ss", "type"=>"Blog", "title"=>"DataCite Blog")
      expect(subject.references).to eq([{"id"=>"https://doi.org/10.5438/0012", "type"=>"CreativeWork"}, {"id"=>"https://doi.org/10.5438/55e5-t5c0", "type"=>"CreativeWork"}])
      expect(subject.publisher).to eq("DataCite")
    end

    it "BlogPosting with new DOI" do
      subject = Bolognese::Metadata.new(input: input, doi: "10.5438/0000-00ss")
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.5438/0000-00ss")
      expect(subject.doi).to eq("10.5438/0000-00ss")
      expect(subject.b_url).to eq("https://blog.datacite.org/eating-your-own-dog-food")
      expect(subject.type).to eq("BlogPosting")
    end

    it "zenodo" do
      input = "https://www.zenodo.org/record/1196821"
      subject = Bolognese::Metadata.new(input: input, from: "schema_org")
      expect(subject.errors.size).to eq(2)
      expect(subject.errors.first).to eq("43:0: ERROR: Element '{http://datacite.org/schema/kernel-4}publisher': [facet 'minLength'] The value has a length of '0'; this underruns the allowed minimum length of '1'.")
      expect(subject.identifier).to eq("https://doi.org/10.5281/zenodo.1196821")
      expect(subject.doi).to eq("10.5281/zenodo.1196821")
      expect(subject.b_url).to eq("https://zenodo.org/record/1196821")
      expect(subject.type).to eq("Dataset")
      expect(subject.title).to eq("PsPM-SC4B: SCR, ECG, EMG, PSR and respiration measurements in a delay fear conditioning task with auditory CS and electrical US")
      expect(subject.author.size).to eq(6)
      expect(subject.author.first).to eq("type"=>"Person", "id"=>"https://orcid.org/0000-0001-9688-838X", "name"=>"Matthias Staib", "givenName"=>"Matthias", "familyName"=>"Staib")
    end

    it "pangaea" do
      input = "https://doi.pangaea.de/10.1594/PANGAEA.836178"
      subject = Bolognese::Metadata.new(input: input, from: "schema_org")
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.1594/pangaea.836178")
      expect(subject.doi).to eq("10.1594/pangaea.836178")
      expect(subject.b_url).to eq("https://doi.pangaea.de/10.1594/PANGAEA.836178")
      expect(subject.type).to eq("Dataset")
      expect(subject.title).to eq("Hydrological and meteorological investigations in a lake near Kangerlussuaq, west Greenland")
      expect(subject.author.size).to eq(8)
      expect(subject.author.first).to eq("type"=>"Person", "name"=>"Johansson, Emma", "givenName"=>"Emma", "familyName"=>"Johansson")
    end

    # service doesn't return html to script
    # it "ornl daac" do
    #   input = "https://daac.ornl.gov/cgi-bin/dsviewer.pl?ds_id=1418"
    #   subject = Bolognese::Metadata.new(input: input, from: "schema_org")
    #   subject.id = "https://doi.org/10.3334/ornldaac/1418"
    #   #expect(subject.errors).to be true
    #   expect(subject.identifier).to eq("https://doi.org/10.3334/ornldaac/1418")
    #   expect(subject.doi).to eq("10.3334/ornldaac/1418")
    #   expect(subject.b_url).to eq("https://doi.org/10.3334/ornldaac/1418")
    #   expect(subject.type).to eq("DataSet")
    #   expect(subject.title).to eq("AirMOSS: L2/3 Volumetric Soil Moisture Profiles Derived From Radar, 2012-2015")
    #   expect(subject.author.size).to eq(8)
    #   expect(subject.author.first).to eq("type"=>"Person", "name"=>"M. MOGHADDAM", "givenName"=>"M.", "familyName"=>"MOGHADDAM")
    # end

    it "harvard dataverse" do
      input = "https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/NJ7XSO"
      subject = Bolognese::Metadata.new(input: input, from: "schema_org")
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.7910/dvn/nj7xso")
      expect(subject.doi).to eq("10.7910/dvn/nj7xso")
      expect(subject.type).to eq("Dataset")
      expect(subject.title).to eq("Summary data ankylosing spondylitis GWAS")
      expect(subject.container_title).to eq("Harvard Dataverse")
      expect(subject.author).to eq("name" => "International Genetics Of Ankylosing Spondylitis Consortium (IGAS)")
      expect(subject.schema_version).to eq("https://schema.org/version/3.3")
    end

    it "harvard dataverse via identifiers.org" do
      input = "https://identifiers.org/doi/10.7910/DVN/NJ7XSO"
      subject = Bolognese::Metadata.new(input: input, from: "schema_org")
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.7910/dvn/nj7xso")
      expect(subject.doi).to eq("10.7910/dvn/nj7xso")
      expect(subject.type).to eq("Dataset")
      expect(subject.title).to eq("Summary data ankylosing spondylitis GWAS")
      expect(subject.container_title).to eq("Harvard Dataverse")
      expect(subject.author).to eq("name" => "International Genetics Of Ankylosing Spondylitis Consortium (IGAS)")
    end
  end

  context "get schema_org metadata as string" do
    it "BlogPosting" do
      input = fixture_path + 'schema_org.json'
      subject = Bolognese::Metadata.new(input: input)

      expect(subject.identifier).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(subject.b_url).to eq("https://blog.datacite.org/eating-your-own-dog-food")
      expect(subject.type).to eq("BlogPosting")
      expect(subject.author).to eq("type"=>"Person", "id"=>"http://orcid.org/0000-0003-1419-2405", "name"=>"Martin Fenner", "givenName"=>"Martin", "familyName"=>"Fenner")
      expect(subject.title).to eq("Eating your own Dog Food")
      expect(subject.description["text"]).to start_with("Eating your own dog food")
      expect(subject.keywords).to eq(["datacite", "doi", "metadata", "featured"])
      expect(subject.date_published).to eq("2016-12-20")
      expect(subject.date_modified).to eq("2016-12-20")
      expect(subject.is_part_of).to eq("id"=>"https://doi.org/10.5438/0000-00ss", "type"=>"Blog", "title"=>"DataCite Blog")
      expect(subject.references).to eq([{"id"=>"https://doi.org/10.5438/0012", "type"=>"CreativeWork"}, {"id"=>"https://doi.org/10.5438/55e5-t5c0", "type"=>"CreativeWork"}])
      expect(subject.publisher).to eq("DataCite")
    end

    it "GTEx dataset" do
      input = fixture_path + 'schema_org_gtex.json'
      subject = Bolognese::Metadata.new(input: input, from: 'schema_org')

      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.25491/d50j-3083")
      expect(subject.alternate_identifier).to eq("name"=>"687610993", "type"=>"md5")
      expect(subject.b_url).to eq("https://ors.datacite.org/doi:/10.25491/d50j-3083")
      expect(subject.content_url).to eq("https://storage.googleapis.com/gtex_analysis_v7/single_tissue_eqtl_data/GTEx_Analysis_v7_eQTL_expression_matrices.tar.gz")
      expect(subject.type).to eq("Dataset")
      expect(subject.additional_type).to eq("Gene expression matrices")
      expect(subject.author).to eq("name"=>"The GTEx Consortium", "type"=>"Organization")
      expect(subject.title).to eq("Fully processed, filtered and normalized gene expression matrices (in BED format) for each tissue, which were used as input into FastQTL for eQTL discovery")
      expect(subject.b_version).to eq("v7")
      expect(subject.keywords).to eq(["gtex", "annotation", "phenotype", "gene regulation", "transcriptomics"])
      expect(subject.date_published).to eq("2017")
      expect(subject.container_title).to eq("GTEx")
      expect(subject.publisher).to eq("GTEx")
      expect(subject.funding).to eq([{"id"=>"https://doi.org/10.13039/100000052",
                                      "name"=>"Common Fund of the Office of the Director of the NIH",
                                      "type"=>"Organization"},
                                     {"id"=>"https://doi.org/10.13039/100000054",
                                      "name"=>"National Cancer Institute (NCI)",
                                      "type"=>"Organization"},
                                     {"id"=>"https://doi.org/10.13039/100000051",
                                      "name"=>"National Human Genome Research Institute (NHGRI)",
                                      "type"=>"Organization"},
                                     {"id"=>"https://doi.org/10.13039/100000050",
                                      "name"=>"National Heart, Lung, and Blood Institute (NHLBI)",
                                      "type"=>"Organization"},
                                     {"id"=>"https://doi.org/10.13039/100000026",
                                      "name"=>"National Institute on Drug Abuse (NIDA)",
                                      "type"=>"Organization"},
                                     {"id"=>"https://doi.org/10.13039/100000025",
                                      "name"=>"National Institute of Mental Health (NIMH)",
                                      "type"=>"Organization"},
                                     {"id"=>"https://doi.org/10.13039/100000065",
                                      "name"=>"National Institute of Neurological Disorders and Stroke (NINDS)",
                                      "type"=>"Organization"}])
    end

    it "TOPMed dataset" do
      input = fixture_path + 'schema_org_topmed.json'
      subject = Bolognese::Metadata.new(input: input, from: 'schema_org')

      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.23725/8na3-9s47")
      expect(subject.alternate_identifier).to eq([{"name"=>"3b33f6b9338fccab0901b7d317577ea3", "type"=>"md5"}, {"name"=>"ark:/99999/fk41CrU4eszeLUDe", "type"=>"minid"}, {"name"=>"dg.4503/c3d66dc9-58da-411c-83c4-dd656aa3c4b7", "type"=>"dataguid"}])
      expect(subject.b_url).to eq("https://ors.datacite.org/doi:/10.23725/8na3-9s47")
      expect(subject.content_url).to eq(["s3://cgp-commons-public/topmed_open_access/197bc047-e917-55ed-852d-d563cdbc50e4/NWD165827.recab.cram", "gs://topmed-irc-share/public/NWD165827.recab.cram"])
      expect(subject.type).to eq("Dataset")
      expect(subject.additional_type).to eq("CRAM file")
      expect(subject.author).to eq("name"=>"TOPMed IRC", "type"=>"Organization")
      expect(subject.title).to eq("NWD165827.recab.cram")
      expect(subject.keywords).to eq(["topmed", "whole genome sequencing"])
      expect(subject.date_published).to eq("2017-11-30")
      expect(subject.publisher).to eq("TOPMed")
      expect(subject.funding).to eq("id"=>"https://doi.org/10.13039/100000050", "name"=>"National Heart, Lung, and Blood Institute (NHLBI)", "type"=>"Organization")
    end
  end
end
