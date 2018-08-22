# frozen_string_literal: true

require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  context "write metadata as schema_org" do
    it "journal article" do
      input = "10.7554/eLife.01567"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.7554/elife.01567")
      expect(json["isPartOf"]).to eq("@type"=>"Periodical", "name"=>"eLife", "issn"=>"2050-084X")
      expect(json["citation"].length).to eq(26)
      expect(json["citation"].first).to eq("@id"=>"https://doi.org/10.1038/nature02100", "@type"=>"CreativeWork", "name" => "APL regulates vascular tissue identity in Arabidopsis")
      expect(json["funding"]).to eq([{"name"=>"SystemsX", "@type"=>"Organization"},
                                     {"name"=>"EMBO",
                                      "@type"=>"Organization",
                                      "@id"=>"https://doi.org/10.13039/501100003043"},
                                     {"name"=>"Swiss National Science Foundation",
                                      "@type"=>"Organization",
                                      "@id"=>"https://doi.org/10.13039/501100001711"},
                                     {"name"=>"University of Lausanne",
                                      "@type"=>"Organization",
                                      "@id"=>"https://doi.org/10.13039/501100006390"}])
    end

    it "maremma schema.org JSON" do
      input = "https://github.com/datacite/maremma"
      subject = Bolognese::Metadata.new(input: input, from: "codemeta")
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.5438/qeg0-3gm3")
      expect(json["@type"]).to eq("SoftwareSourceCode")
      expect(json["name"]).to eq("Maremma: a Ruby library for simplified network calls")
      expect(json["author"]).to eq("name"=>"Martin Fenner", "givenName"=>"Martin", "familyName"=>"Fenner", "@type"=>"Person", "@id"=>"http://orcid.org/0000-0003-0077-4738")
    end

    it "Schema.org JSON" do
      input = "https://doi.org/10.5281/ZENODO.48440"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.5281/zenodo.48440")
      expect(json["name"]).to eq("Analysis Tools For Crossover Experiment Of Ui Using Choice Architecture")
    end

    it "Schema.org JSON isReferencedBy" do
      input = "https://doi.org/10.5061/DRYAD.8515"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.5061/dryad.8515")
      expect(json["@reverse"]).to eq("citation"=>{"@id"=>"https://doi.org/10.1371/journal.ppat.1000446"}, "isBasedOn"=>{"@id"=>"https://doi.org/10.1371/journal.ppat.1000446"})
    end

    it "Schema.org JSON IsSupplementTo" do
      input = "https://doi.org/10.5517/CC8H01S"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.5517/cc8h01s")
      expect(json["@reverse"]).to eq("isBasedOn"=>{"@id"=>"https://doi.org/10.1107/s1600536804021154"})
    end

    it "rdataone" do
      input = fixture_path + 'codemeta.json'
      subject = Bolognese::Metadata.new(input: input, from: "codemeta")
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.5063/f1m61h5x")
      expect(json["@type"]).to eq("SoftwareSourceCode")
      expect(json["name"]).to eq("R Interface to the DataONE REST API")
      expect(json["author"]).to eq([{"name"=>"Matt Jones",
                                     "givenName"=>"Matt",
                                     "familyName"=>"Jones",
                                     "@type"=>"Person",
                                     "@id"=>"http://orcid.org/0000-0003-0077-4738"},
                                    {"name"=>"Peter Slaughter",
                                     "givenName"=>"Peter",
                                     "familyName"=>"Slaughter",
                                     "@type"=>"Person",
                                     "@id"=>"http://orcid.org/0000-0002-2192-403X"},
                                    {"name"=>"University Of California, Santa Barbara", "@type"=>"Organization"}])
      expect(json["version"]).to eq("2.0.0")
    end

    it "Funding" do
      input = "https://doi.org/10.5438/6423"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.5438/6423")
      expect(json["hasPart"].length).to eq(25)
      expect(json["hasPart"].first).to eq("@type"=>"CreativeWork", "@id"=>"https://doi.org/10.5281/zenodo.30799")
      expect(json["funding"]).to eq("@type" => "Award",
                                    "funder" => {"@type"=>"Organization", "@id"=>"https://doi.org/10.13039/501100000780", "name"=>"European Commission"},
                                    "identifier" => "654039",
                                    "name" => "THOR – Technical and Human Infrastructure for Open Research",
                                    "url" => "http://cordis.europa.eu/project/rcn/194927_en.html")
    end

    it "Funding OpenAIRE" do
      input = "https://doi.org/10.5281/ZENODO.1239"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.5281/zenodo.1239")
      expect(json["funding"]).to eq("@type" => "Award",
                                    "funder" => {"@type"=>"Organization", "@id"=>"https://doi.org/10.13039/501100000780", "name"=>"European Commission"},
                                    "identifier" => "246686",
                                    "name" => "Open Access Infrastructure for Research in Europe",
                                    "url" => "info:eu-repo/grantAgreement/EC/FP7/246686/")
    end

    it "subject scheme" do
      input = "https://doi.org/10.4232/1.2745"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.4232/1.2745")
      expect(json["name"]).to eq("Flash Eurobarometer 54 (Madrid Summit)")
      expect(json["keywords"]).to eq("KAT12 International Institutions, Relations, Conditions")
    end

    it "subject scheme multiple keywords" do
      input = "https://doi.org/10.1594/pangaea.721193"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.1594/pangaea.721193")
      expect(json["name"]).to eq("Seawater carbonate chemistry and processes during experiments with Crassostrea gigas, 2007, supplement to: Kurihara, Haruko; Kato, Shoji; Ishimatsu, Atsushi (2007): Effects of increased seawater pCO2 on early development of the oyster Crassostrea gigas. Aquatic Biology, 1(1), 91-98")
      expect(json["keywords"]).to eq("GetInfo, Animalia, Bottles or small containers/Aquaria ( 20 L), Calcification/Dissolution, Coast and continental shelf, Development, Growth/Morphology, Laboratory experiment, Mollusca, Pelagos, Single species, Temperate, Zooplankton, Experimental treatment, Carbonate system computation flag, Temperature, water, Salinity, pH, Alkalinity, total, Carbon, inorganic, dissolved, Carbon dioxide, Bicarbonate ion, Carbonate ion, Partial pressure of carbon dioxide (water) at sea surface temperature (wet air), Fugacity of carbon dioxide (water) at sea surface temperature (wet air), Aragonite saturation state, Calcite saturation state, Proportion, Crassostrea gigas, larvae length, Crassostrea gigas, larvae height, Crassostrea gigas, non mineralized, Crassostrea gigas, partially mineralized, Crassostrea gigas, fully mineralized, Calculated using seacarb after Nisumaa et al. (2010), Refractometer (Atago 100-S), pH meter (Mettler Toledo), pH meter (PHM290, Radiometer), Measured, European Project on Ocean Acidification (EPOCA), European network of excellence for Ocean Ecosystems Analysis (EUR-OCEANS), Ocean Acidification International Coordination Centre (OA-ICC)")
    end

    it "author is organization" do
      input = fixture_path + 'gtex.xml'
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.25491/9hx8-ke93")
      expect(json["author"]).to eq("@type"=>"Organization", "name"=>"The GTEx Consortium")
    end

    it "series information" do
      input = "10.4229/23RDEUPVSEC2008-5CO.8.3"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      json = JSON.parse(subject.schema_org)
      expect(json["isPartOf"]).to eq("@type"=>"Periodical", "name"=>"23rd European Photovoltaic Solar Energy Conference and Exhibition, 1-5 September 2008, Valencia, Spain; 3353-3356")
      expect(json["@id"]).to eq("https://doi.org/10.4229/23rdeupvsec2008-5co.8.3")
      expect(json["@type"]).to eq("ScholarlyArticle")
      expect(json["name"]).to eq("Rural Electrification With Hybrid Power Systems Based on Renewables - Technical System Configurations From the Point of View of the European Industry")
      expect(json["author"].count).to eq(3)
      expect(json["author"].first).to eq("@type"=>"Person", "name"=>"P. Llamas", "givenName"=>"P.", "familyName"=>"Llamas")
    end

    it "data catalog" do
      input = "10.25491/8KMC-G314"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.25491/8kmc-g314")
      expect(json["@type"]).to eq("Dataset")
      expect(json["name"]).to eq("Covariates used in eQTL analysis. Includes genotyping principal components and PEER factors")
      expect(json["author"]).to eq("@type"=>"Organization", "name"=>"The GTEx Consortium")
      expect(json["includedInDataCatalog"]).to eq("@type"=>"DataCatalog", "name"=>"GTEx")
      expect(json["identifier"]).to eq(["https://doi.org/10.25491/8kmc-g314", {"@type"=>"PropertyValue", "propertyID"=>"md5", "value"=>"c7c89fe7366d50cd75448aa603c9de58"}])
      expect(json["contentUrl"]).to eq(["https://storage.googleapis.com/gtex_analysis_v7/single_tissue_eqtl_data/GTEx_Analysis_v7_eQTL_covariates.tar.gz"])
    end

    it "alternate identifiers" do
      input = "10.23725/8na3-9s47"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.23725/8na3-9s47")
      expect(json["@type"]).to eq("Dataset")
      expect(json["name"]).to eq("NWD165827.recab.cram")
      expect(json["author"]).to eq("@type"=>"Organization", "name"=>"TOPMed IRC")
      expect(json["includedInDataCatalog"]).to be_nil
      expect(json["identifier"]).to eq(["https://doi.org/10.23725/8na3-9s47",
        {"@type"=>"PropertyValue",
         "propertyID"=>"md5",
         "value"=>"3b33f6b9338fccab0901b7d317577ea3"},
        {"@type"=>"PropertyValue",
         "propertyID"=>"minid",
         "value"=>"ark:/99999/fk41CrU4eszeLUDe"},
        {"@type"=>"PropertyValue",
          "propertyID"=>"dataguid",
          "value"=>"dg.4503/c3d66dc9-58da-411c-83c4-dd656aa3c4b7"}])
      expect(json["contentUrl"]).to eq(["s3://cgp-commons-public/topmed_open_access/197bc047-e917-55ed-852d-d563cdbc50e4/NWD165827.recab.cram", "gs://topmed-irc-share/public/NWD165827.recab.cram"])
    end
  end
end
