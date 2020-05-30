# frozen_string_literal: true

require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  context "write metadata as schema_org" do
    it "journal article" do
      input = "10.7554/eLife.01567"
      subject = Bolognese::Metadata.new(input: input, from: "crossref")
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.7554/elife.01567")
      expect(json["isPartOf"]).to eq("@type"=>"Periodical", "issn"=>"2050-084X")
      expect(json["periodical"]).to eq("@type"=>"Journal", "identifier"=>"2050-084X", "identifierType"=>"ISSN", "name"=>"eLife", "volume"=>"3")
      expect(json["citation"].length).to eq(26)
      expect(json["citation"].first).to eq("@id"=>"https://doi.org/10.1038/nature02100", "@type"=>"CreativeWork")
      expect(json["funder"]).to eq([{"name"=>"SystemsX", "@type"=>"Organization"},
                                     {"name"=>"EMBO",
                                      "@type"=>"Organization",
                                      "@id"=>"https://doi.org/10.13039/501100003043"},
                                     {"name"=>"Swiss National Science Foundation",
                                      "@type"=>"Organization",
                                      "@id"=>"https://doi.org/10.13039/501100001711"},
                                     {"name"=>"University of Lausanne",
                                      "@type"=>"Organization",
                                      "@id"=>"https://doi.org/10.13039/501100006390"}])
      expect(json["license"]).to eq("https://creativecommons.org/licenses/by/3.0/legalcode")
    end

    it "maremma schema.org JSON" do
      input = "https://github.com/datacite/maremma"
      subject = Bolognese::Metadata.new(input: input, from: "codemeta")
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.5438/qeg0-3gm3")
      expect(json["@type"]).to eq("SoftwareSourceCode")
      expect(json["name"]).to eq("Maremma: a Ruby library for simplified network calls")
      expect(json["author"]).to eq("name"=>"Martin Fenner", "givenName"=>"Martin", "familyName"=>"Fenner", "@type"=>"Person", "@id"=>"https://orcid.org/0000-0003-0077-4738", "affiliation" => {"@type"=>"Organization", "name"=>"DataCite"})
    end

    it "Schema.org JSON" do
      input = "https://doi.org/10.5281/ZENODO.48440"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.5281/zenodo.48440")
      expect(json["name"]).to eq("Analysis Tools For Crossover Experiment Of Ui Using Choice Architecture")
      expect(json["license"]).to eq(["https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode", "info:eu-repo/semantics/openAccess"])
    end

    it "Schema.org JSON isReferencedBy" do
      input = "https://doi.org/10.5061/DRYAD.8515"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.5061/dryad.8515")
      expect(json["@reverse"]).to eq("citation" => [{"@id"=>"https://doi.org/10.1371/journal.ppat.1000446", "@type"=>"ScholarlyArticle"}, {"@type"=>"ScholarlyArticle", "identifier"=>{"@type"=>"PropertyValue", "propertyID"=>"PMID", "value"=>"19478877"}}],
        "isBasedOn" => [{"@id"=>"https://doi.org/10.1371/journal.ppat.1000446", "@type"=>"ScholarlyArticle"}, {"@type"=>"ScholarlyArticle", "identifier"=>{"@type"=>"PropertyValue", "propertyID"=>"PMID", "value"=>"19478877"}}])
      expect(json["license"]).to eq("https://creativecommons.org/publicdomain/zero/1.0/legalcode")
    end

    it "Schema.org JSON IsSupplementTo" do
      input = "https://doi.org/10.5517/CC8H01S"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.5517/cc8h01s")
      expect(json["@reverse"]).to eq("isBasedOn"=>{"@id"=>"https://doi.org/10.1107/s1600536804021154", "@type"=>"ScholarlyArticle"})
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
                                     "@id"=>"https://orcid.org/0000-0003-0077-4738",
                                     "affiliation"=>{"@type"=>"Organization", "name"=>"NCEAS"}},
                                    {"name"=>"Peter Slaughter",
                                     "givenName"=>"Peter",
                                     "familyName"=>"Slaughter",
                                     "@type"=>"Person",
                                     "@id"=>"https://orcid.org/0000-0002-2192-403X",
                                     "affiliation"=>{"@type"=>"Organization", "name"=>"NCEAS"}},
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
      expect(json["funder"]).to eq("@id"=>"https://doi.org/10.13039/501100000780", "@type"=>"Organization", "name"=>"European Commission")
      expect(json["license"]).to eq("https://creativecommons.org/licenses/by/4.0/legalcode")
    end

    it "Funding OpenAIRE" do
      input = "https://doi.org/10.5281/ZENODO.1239"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.5281/zenodo.1239")
      expect(json["funder"]).to eq("@id"=>"https://doi.org/10.13039/501100000780", "@type"=>"Organization", "name"=>"European Commission")
      expect(json["license"]).to eq(["https://creativecommons.org/publicdomain/zero/1.0/legalcode", "info:eu-repo/semantics/openAccess"])
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
      expect(json["keywords"]).to eq("Animalia, Bottles or small containers/Aquaria ( 20 L), Calcification/Dissolution, Coast and continental shelf, Crassostrea gigas, Development, Growth/Morphology, Laboratory experiment, Mollusca, North Pacific, Pelagos, Single species, Temperate, Zooplankton, Experimental treatment, Carbonate system computation flag, Temperature, water, Salinity, pH, Alkalinity, total, Carbon, inorganic, dissolved, Carbon dioxide, Bicarbonate ion, Carbonate ion, Partial pressure of carbon dioxide (water) at sea surface temperature (wet air), Fugacity of carbon dioxide (water) at sea surface temperature (wet air), Aragonite saturation state, Calcite saturation state, Proportion, Crassostrea gigas, larvae length, Crassostrea gigas, larvae height, Crassostrea gigas, non mineralized, Crassostrea gigas, partially mineralized, Crassostrea gigas, fully mineralized, Calculated using seacarb after Nisumaa et al. (2010), Refractometer (Atago 100-S), pH meter (Mettler Toledo), pH meter (PHM290, Radiometer), Measured, European Project on Ocean Acidification (EPOCA), European network of excellence for Ocean Ecosystems Analysis (EUR-OCEANS), Ocean Acidification International Coordination Centre (OA-ICC)")
      expect(json["license"]).to eq("https://creativecommons.org/licenses/by/3.0/legalcode")
    end

    it "author is organization" do
      input = fixture_path + 'gtex.xml'
      url = "https://ors.datacite.org/doi:/10.25491/9hx8-ke93"
      content_url = "https://storage.googleapis.com/gtex_analysis_v7/single_tissue_eqtl_data/GTEx_Analysis_v7_eQTL_expression_matrices.tar.gz"  
      subject = Bolognese::Metadata.new(input: input, url: url, content_url: content_url, from: "datacite")
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.25491/9hx8-ke93")
      expect(json["author"]).to eq("@type"=>"Organization", "name"=>"The GTEx Consortium")
      expect(json["url"]).to eq("https://ors.datacite.org/doi:/10.25491/9hx8-ke93")
      expect(json["encodingFormat"]).to eq("application/tar")
      expect(json["contentSize"]).to eq("15.7M")
      expect(json["contentUrl"]).to eq("https://storage.googleapis.com/gtex_analysis_v7/single_tissue_eqtl_data/GTEx_Analysis_v7_eQTL_expression_matrices.tar.gz")
      expect(json["includedInDataCatalog"]).to eq("@id"=>"https://www.ebi.ac.uk/miriam/main/datatypes/MIR:00000663", "@type"=>"DataCatalog", "name"=>"GTEx")
      expect(json["@reverse"]).to eq("isBasedOn"=>{"@id"=>"https://doi.org/10.1038/nmeth.4407", "@type"=>"ScholarlyArticle"})
    end

    it "series information" do
      input = "10.4229/23RDEUPVSEC2008-5CO.8.3"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.4229/23rdeupvsec2008-5co.8.3")
      expect(json["@type"]).to eq("ScholarlyArticle")
      expect(json["name"]).to eq("Rural Electrification With Hybrid Power Systems Based on Renewables - Technical System Configurations From the Point of View of the European Industry")
      expect(json["author"].count).to eq(3)
      expect(json["author"].first).to eq("@type"=>"Person", "name"=>"P. Llamas", "givenName"=>"P.", "familyName"=>"Llamas")
      expect(json["periodical"]).to eq("@type"=>"Series", "firstPage"=>"Spain; 3353", "lastPage"=>"3356", "name"=>"23rd European Photovoltaic Solar Energy Conference and Exhibition", "volume"=>"1-5 September 2008")
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
      expect(json["identifier"]).to eq([{"@type"=>"PropertyValue", "propertyID"=>"DOI", "value"=>"https://doi.org/10.25491/8kmc-g314"},{"@type"=>"PropertyValue", "propertyID"=>"md5", "value"=>"c7c89fe7366d50cd75448aa603c9de58"}])
      expect(json["contentUrl"]).to eq("https://storage.googleapis.com/gtex_analysis_v7/single_tissue_eqtl_data/GTEx_Analysis_v7_eQTL_covariates.tar.gz")
    end

    it "alternate identifiers" do
      input = "10.23725/8na3-9s47"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.23725/8na3-9s47")
      expect(json["@type"]).to eq("Dataset")
      expect(json["name"]).to eq("NWD165827.recab.cram")
      expect(json["author"]).to eq("name"=>"TOPMed")
      expect(json["includedInDataCatalog"]).to be_nil
      expect(json["identifier"]).to eq(
        [{"@type"=>"PropertyValue",
          "propertyID"=>"DOI",
          "value"=>"https://doi.org/10.23725/8na3-9s47"},
         {"@type"=>"PropertyValue",
          "propertyID"=>"minid",
          "value"=>"ark:/99999/fk41CrU4eszeLUDe"},
         {"@type"=>"PropertyValue",
          "propertyID"=>"dataguid",
          "value"=>"dg.4503/c3d66dc9-58da-411c-83c4-dd656aa3c4b7"},
         {"@type"=>"PropertyValue",
          "propertyID"=>"md5",
          "value"=>"3b33f6b9338fccab0901b7d317577ea3"}]
      )
      expect(json["contentUrl"]).to include("s3://cgp-commons-public/topmed_open_access/197bc047-e917-55ed-852d-d563cdbc50e4/NWD165827.recab.cram", "gs://topmed-irc-share/public/NWD165827.recab.cram")
    end

    it "affiliation identifier" do
      input = fixture_path + 'datacite-example-affiliation.xml'
      subject = Bolognese::Metadata.new(input: input)
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.5072/example-full")
      expect(json["@type"]).to eq("SoftwareSourceCode")
      expect(json["name"]).to eq("Full DataCite XML Example")
      expect(json["author"].length).to eq(3)
      expect(json["author"].first).to eq("@id" => "https://orcid.org/0000-0001-5000-0007",
        "@type" => "Person",
        "affiliation" => {"@id"=>"https://ror.org/04wxnsj81", "@type"=>"Organization", "name"=>"DataCite"},
        "familyName" => "Miller",
        "givenName" => "Elizabeth",
        "name" => "Elizabeth Miller")
      expect(json["identifier"]).to eq(
        [{"@type"=>"PropertyValue",
          "propertyID"=>"DOI",
          "value"=>"https://doi.org/10.5072/example-full"},
         {"@type"=>"PropertyValue",
          "propertyID"=>"URL",
          "value"=>"https://schema.datacite.org/meta/kernel-4.2/example/datacite-example-full-v4.2.xml"}]
      )
      expect(json["license"]).to eq("https://creativecommons.org/publicdomain/zero/1.0/legalcode")
    end

    it "geo_location_point" do
      input = fixture_path + 'datacite-example-geolocation-2.xml'
      doi = "10.6071/Z7WC73"
      subject = Bolognese::Metadata.new(input: input, doi: doi)
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.6071/z7wc73")
      expect(json["@type"]).to eq("Dataset")
      expect(json["name"]).to eq("Southern Sierra Critical Zone Observatory (SSCZO), Providence Creek meteorological data, soil moisture and temperature, snow depth and air temperature")
      expect(json["author"].length).to eq(6)
      expect(json["author"][2]).to eq("@id"=>"https://orcid.org/0000-0002-8862-1404", "@type"=>"Person", "familyName"=>"Stacy", "givenName"=>"Erin", "name"=>"Erin Stacy", "affiliation" => {"@type"=>"Organization", "name"=>"UC Merced"})
      expect(json["includedInDataCatalog"]).to be_nil
      expect(json["spatialCoverage"]).to eq([{"@type"=>"Place",
        "geo"=>
        {"@type"=>"GeoCoordinates",
         "address"=>"Providence Creek (Lower, Upper and P301)",
         "latitude"=>"37.047756",
         "longitude"=>"-119.221094"}},
        {"@type"=>"Place",
         "geo"=>
        {"@type"=>"GeoShape",
         "address"=>"Providence Creek (Lower, Upper and P301)",
         "box"=>"37.046 -119.211 37.075 -119.182"}}])
      expect(json["license"]).to eq("https://creativecommons.org/licenses/by/4.0/legalcode")
    end

    it "geo_location_box" do
      input = "10.1594/PANGAEA.842237"
      subject = Bolognese::Metadata.new(input: input, from: "datacite")
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.1594/pangaea.842237")
      expect(json["@type"]).to eq("Dataset")
      expect(json["name"]).to eq("Registry of all stations from the Tara Oceans Expedition (2009-2013)")
      expect(json["author"]).to eq([{"familyName"=>"Tara Oceans Consortium",
        "givenName"=>"Coordinators",
        "name"=>"Coordinators Tara Oceans Consortium"},
       {"familyName"=>"Tara Oceans Expedition",
        "givenName"=>"Participants",
        "name"=>"Participants Tara Oceans Expedition"}])
      expect(json["includedInDataCatalog"]).to be_nil
      expect(json["identifier"]).to eq("@type"=>"PropertyValue", "propertyID"=>"DOI", "value"=>"https://doi.org/10.1594/pangaea.842237")
      expect(json["spatialCoverage"]).to eq("@type"=>"Place", "geo"=>{"@type"=>"GeoShape", "box"=>"-64.3088 -168.5182 79.6753 174.9006"})
      expect(json["license"]).to eq("https://creativecommons.org/licenses/by/3.0/legalcode")
    end

    it "geo_location_polygon" do
      input = fixture_path + 'datacite-example-polygon-v4.1.xml'
      subject = Bolognese::Metadata.new(input: input)
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.5072/example-polygon")
      expect(json["@type"]).to eq("Dataset")
      expect(json["name"]).to eq("Meteo measurements at the Sand Motor")
      expect(json["author"]).to eq("@type"=>"Person", "familyName"=>"Den Heijer", "givenName"=>"C", "name"=>"C Den Heijer")
      expect(json["includedInDataCatalog"]).to be_nil
      expect(json["identifier"]).to eq("@type"=>"PropertyValue", "propertyID"=>"DOI", "value"=>"https://doi.org/10.5072/example-polygon")
      expect(json["spatialCoverage"].dig("geo", "polygon").length).to eq(34)
      expect(json["spatialCoverage"].dig("geo", "polygon").first).to eq(["4.1738852605822", "52.03913926329928"])
    end

    it "from schema_org gtex" do
      input = fixture_path + 'schema_org_gtex.json'
      subject = Bolognese::Metadata.new(input: input, from: "schema_org")
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.25491/d50j-3083")
      expect(json["@type"]).to eq("Dataset")
      expect(json["identifier"]).to eq([{"@type"=>"PropertyValue", "propertyID"=>"DOI", "value"=>"https://doi.org/10.25491/d50j-3083"}, {"@type"=>"PropertyValue", "propertyID"=>"md5", "value"=>"687610993"}])
      expect(json["url"]).to eq("https://ors.datacite.org/doi:/10.25491/d50j-3083")
      expect(json["additionalType"]).to eq("Gene expression matrices")
      expect(json["name"]).to eq("Fully processed, filtered and normalized gene expression matrices (in BED format) for each tissue, which were used as input into FastQTL for eQTL discovery")
      expect(json["version"]).to eq("v7")
      expect(json["author"]).to eq("@type"=>"Organization", "name"=>"The GTEx Consortium")
      expect(json["keywords"]).to eq("gtex, annotation, phenotype, gene regulation, transcriptomics")
      expect(json["datePublished"]).to eq("2017")
      expect(json["contentUrl"]).to eq("https://storage.googleapis.com/gtex_analysis_v7/single_tissue_eqtl_data/GTEx_Analysis_v7_eQTL_expression_matrices.tar.gz")
      expect(json["schemaVersion"]).to eq("http://datacite.org/schema/kernel-4")
      expect(json["includedInDataCatalog"]).to eq("@type"=>"DataCatalog", "name"=>"GTEx")
      expect(json["publisher"]).to eq("@type"=>"Organization", "name"=>"GTEx")
      expect(json["funder"]).to eq([{"@id"=>"https://doi.org/10.13039/100000052",
        "name"=>"Common Fund of the Office of the Director of the NIH",
        "@type"=>"Organization"},
       {"@id"=>"https://doi.org/10.13039/100000054",
        "name"=>"National Cancer Institute (NCI)",
        "@type"=>"Organization"},
       {"@id"=>"https://doi.org/10.13039/100000051",
        "name"=>"National Human Genome Research Institute (NHGRI)",
        "@type"=>"Organization"},
       {"@id"=>"https://doi.org/10.13039/100000050",
        "name"=>"National Heart, Lung, and Blood Institute (NHLBI)",
        "@type"=>"Organization"},
       {"@id"=>"https://doi.org/10.13039/100000026",
        "name"=>"National Institute on Drug Abuse (NIDA)",
        "@type"=>"Organization"},
       {"@id"=>"https://doi.org/10.13039/100000025",
        "name"=>"National Institute of Mental Health (NIMH)",
        "@type"=>"Organization"},
       {"@id"=>"https://doi.org/10.13039/100000065",
        "name"=>"National Institute of Neurological Disorders and Stroke (NINDS)",
        "@type"=>"Organization"}])
      expect(json["provider"]).to eq("@type"=>"Organization", "name"=>"DataCite")
    end

    it "from schema_org topmed" do
      input = fixture_path + 'schema_org_topmed.json'
      subject = Bolognese::Metadata.new(input: input, from: "schema_org")
      json = JSON.parse(subject.schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.23725/8na3-9s47")
      expect(json["@type"]).to eq("Dataset")
      expect(json["identifier"]).to eq(
        [{"@type"=>"PropertyValue",
          "propertyID"=>"DOI",
          "value"=>"https://doi.org/10.23725/8na3-9s47"},
         {"@type"=>"PropertyValue",
          "propertyID"=>"md5",
          "value"=>"3b33f6b9338fccab0901b7d317577ea3"},
         {"@type"=>"PropertyValue",
          "propertyID"=>"minid",
          "value"=>"ark:/99999/fk41CrU4eszeLUDe"},
         {"@type"=>"PropertyValue",
          "propertyID"=>"dataguid",
          "value"=>"dg.4503/c3d66dc9-58da-411c-83c4-dd656aa3c4b7"}])
      expect(json["url"]).to eq("https://ors.datacite.org/doi:/10.23725/8na3-9s47")
      expect(json["additionalType"]).to eq("CRAM file")
      expect(json["name"]).to eq("NWD165827.recab.cram")
      expect(json["author"]).to eq("@type"=>"Organization", "name"=>"TOPMed IRC")
      expect(json["keywords"]).to eq("topmed, whole genome sequencing")
      expect(json["datePublished"]).to eq("2017-11-30")
      expect(json["contentUrl"]).to eq(["s3://cgp-commons-public/topmed_open_access/197bc047-e917-55ed-852d-d563cdbc50e4/NWD165827.recab.cram", "gs://topmed-irc-share/public/NWD165827.recab.cram"])
      expect(json["schemaVersion"]).to eq("http://datacite.org/schema/kernel-4")
      expect(json["publisher"]).to eq("@type"=>"Organization", "name"=>"TOPMed")
      expect(json["citation"]).to eq("@id"=>"https://doi.org/10.23725/2g4s-qv04", "@type"=>"Dataset")
      expect(json["funder"]).to eq("@id"=>"https://doi.org/10.13039/100000050", "@type"=>"Organization", "name"=>"National Heart, Lung, and Blood Institute (NHLBI)")
      expect(json["provider"]).to eq("@type"=>"Organization", "name"=>"DataCite")
    end
  end
end
