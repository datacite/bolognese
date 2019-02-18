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
      expect(subject.identifiers).to eq([{"identifier"=>"https://doi.org/10.5438/4k3m-nyvg", "identifierType"=>"DOI"}])
      expect(subject.url).to eq("https://blog.datacite.org/eating-your-own-dog-food")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"post-weblog", "resourceTypeGeneral"=>"Text", "ris"=>"GEN", "schemaOrg"=>"BlogPosting")
      expect(subject.creators).to eq([{"familyName"=>"Fenner", "givenName"=>"Martin", "name"=>"Fenner, Martin", "nameIdentifiers"=> [{"nameIdentifier"=>"https://orcid.org/0000-0003-1419-2405", "nameIdentifierScheme"=>"ORCID"}], "nameType"=>"Personal"}])
      expect(subject.titles).to eq([{"title"=>"Eating your own Dog Food"}])
      expect(subject.descriptions.first["description"]).to start_with("Eating your own dog food")
      expect(subject.subjects).to eq([{"subject"=>"datacite"}, {"subject"=>"doi"}, {"subject"=>"metadata"}, {"subject"=>"featured"}])
      expect(subject.dates).to eq([{"date"=>"2016-12-20", "dateType"=>"Issued"}, {"date"=>"2016-12-20", "dateType"=>"Created"}, {"date"=>"2016-12-20", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2016")
      expect(subject.related_identifiers.length).to eq(3)
      expect(subject.related_identifiers.last).to eq("relatedIdentifier"=>"10.5438/55e5-t5c0", "relatedIdentifierType"=>"DOI", "relationType"=>"References")
      expect(subject.publisher).to eq("DataCite")
    end

    it "BlogPosting with new DOI" do
      subject = Bolognese::Metadata.new(input: input, doi: "10.5438/0000-00ss")
      expect(subject.valid?).to be true
      expect(subject.identifiers).to eq([{"identifier"=>"https://doi.org/10.5438/0000-00ss", "identifierType"=>"DOI"}])
      expect(subject.doi).to eq("10.5438/0000-00ss")
      expect(subject.url).to eq("https://blog.datacite.org/eating-your-own-dog-food")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"post-weblog", "resourceTypeGeneral"=>"Text", "ris"=>"GEN", "schemaOrg"=>"BlogPosting")
    end

    it "zenodo" do
      input = "https://www.zenodo.org/record/1196821"
      subject = Bolognese::Metadata.new(input: input, from: "schema_org")
      expect(subject.valid?).to be false
      expect(subject.errors.size).to eq(2)
      expect(subject.errors.first).to eq("43:0: ERROR: Element '{http://datacite.org/schema/kernel-4}publisher': [facet 'minLength'] The value has a length of '0'; this underruns the allowed minimum length of '1'.")
      expect(subject.identifiers).to eq([{"identifier"=>"https://doi.org/10.5281/zenodo.1196821", "identifierType"=>"DOI"}])
      expect(subject.doi).to eq("10.5281/zenodo.1196821")
      expect(subject.url).to eq("https://zenodo.org/record/1196821")
      expect(subject.types).to eq("bibtex"=>"misc", "citeproc"=>"dataset", "resourceTypeGeneral"=>"Dataset", "ris"=>"DATA", "schemaOrg"=>"Dataset")
      expect(subject.titles).to eq([{"title"=>"PsPM-SC4B: SCR, ECG, EMG, PSR and respiration measurements in a delay fear conditioning task with auditory CS and electrical US"}])
      expect(subject.creators.size).to eq(6)
      expect(subject.creators.first).to eq("name" => "Staib, Matthias",
        "nameIdentifiers" => [{"nameIdentifier"=>"https://orcid.org/0000-0001-9688-838X", "nameIdentifierScheme"=>"ORCID"}],
        "nameType" => "Personal", "givenName"=>"Matthias", "familyName"=>"Staib", "affiliation" => "University of Zurich, Zurich, Switzerland")
      expect(subject.publisher).to be_nil
      expect(subject.publication_year).to eq("2018")
    end

    it "pangaea" do
      input = "https://doi.pangaea.de/10.1594/PANGAEA.836178"
      subject = Bolognese::Metadata.new(input: input, from: "schema_org")
      expect(subject.valid?).to be true
      expect(subject.identifiers).to eq([{"identifier"=>"https://doi.org/10.1594/pangaea.836178", "identifierType"=>"DOI"}])
      expect(subject.doi).to eq("10.1594/pangaea.836178")
      expect(subject.url).to eq("https://doi.pangaea.de/10.1594/PANGAEA.836178")
      expect(subject.types).to eq("bibtex"=>"misc", "citeproc"=>"dataset", "resourceTypeGeneral"=>"Dataset", "ris"=>"DATA", "schemaOrg"=>"Dataset")
      expect(subject.titles).to eq([{"title"=>"Hydrological and meteorological investigations in a lake near Kangerlussuaq, west Greenland"}])
      expect(subject.creators.size).to eq(8)
      expect(subject.creators.first).to eq("nameType" => "Personal", "name"=>"Johansson, Emma", "givenName"=>"Emma", "familyName"=>"Johansson")
      expect(subject.publisher).to eq("PANGAEA")
      expect(subject.publication_year).to eq("2014")
    end

    it "ornl" do
      input = "https://doi.org/10.3334/ornldaac/1339"
      subject = Bolognese::Metadata.new(input: input, from: "schema_org")
      expect(subject.valid?).to be true
      expect(subject.identifiers).to eq([{"identifier"=>"https://doi.org/10.3334/ornldaac/1339", "identifierType"=>"DOI"}])
      expect(subject.doi).to eq("10.3334/ornldaac/1339")
      expect(subject.url).to eq("https://doi.org/10.3334/ornldaac/1339")
      expect(subject.types).to eq("bibtex"=>"misc", "citeproc"=>"article-journal", "ris"=>"GEN", "schemaOrg"=>"DataSet")
      expect(subject.titles).to eq([{"title"=>"Soil Moisture Profiles and Temperature Data from SoilSCAPE Sites, USA"}])
      expect(subject.creators.size).to eq(12)
      expect(subject.creators.first).to eq("familyName"=>"MOGHADDAM", "givenName"=>"M.", "name"=>"MOGHADDAM, M.", "nameType"=>"Personal")
    end

    it "harvard dataverse" do
      input = "https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/NJ7XSO"
      subject = Bolognese::Metadata.new(input: input, from: "schema_org")
      expect(subject.valid?).to be true
      expect(subject.identifiers).to eq([{"identifier"=>"https://doi.org/10.7910/dvn/nj7xso", "identifierType"=>"DOI"}])
      expect(subject.doi).to eq("10.7910/dvn/nj7xso")
      expect(subject.types).to eq("bibtex"=>"misc", "citeproc"=>"dataset", "resourceTypeGeneral"=>"Dataset", "ris"=>"DATA", "schemaOrg"=>"Dataset")
      expect(subject.titles).to eq([{"title"=>"Summary data ankylosing spondylitis GWAS"}])
      expect(subject.container).to eq("identifier"=>"https://dataverse.harvard.edu", "identifierType"=>"URL", "title"=>"Harvard Dataverse", "type"=>"DataRepository")
      expect(subject.creators).to eq([{"name" => "International Genetics Of Ankylosing Spondylitis Consortium (IGAS)"}])
      expect(subject.schema_version).to eq("https://schema.org/version/3.3")
    end

    it "harvard dataverse via identifiers.org" do
      input = "https://identifiers.org/doi/10.7910/DVN/NJ7XSO"
      subject = Bolognese::Metadata.new(input: input, from: "schema_org")
      expect(subject.valid?).to be true
      expect(subject.identifiers).to eq([{"identifier"=>"https://doi.org/10.7910/dvn/nj7xso", "identifierType"=>"DOI"}])
      expect(subject.doi).to eq("10.7910/dvn/nj7xso")
      expect(subject.types).to eq("bibtex"=>"misc", "citeproc"=>"dataset", "resourceTypeGeneral"=>"Dataset", "ris"=>"DATA", "schemaOrg"=>"Dataset")
      expect(subject.titles).to eq([{"title"=>"Summary data ankylosing spondylitis GWAS"}])
      expect(subject.container).to eq("identifier"=>"https://dataverse.harvard.edu", "identifierType"=>"URL", "title"=>"Harvard Dataverse", "type"=>"DataRepository")
      expect(subject.creators).to eq([{"name" => "International Genetics Of Ankylosing Spondylitis Consortium (IGAS)"}])
    end
  end

  context "get schema_org metadata as string" do
    it "BlogPosting" do
      input = fixture_path + 'schema_org.json'
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifiers).to eq([{"identifier"=>"https://doi.org/10.5438/4k3m-nyvg", "identifierType"=>"DOI"}])
      expect(subject.url).to eq("https://blog.datacite.org/eating-your-own-dog-food")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"post-weblog", "resourceTypeGeneral"=>"Text", "ris"=>"GEN", "schemaOrg"=>"BlogPosting")
      expect(subject.creators).to eq([{"familyName"=>"Fenner", "givenName"=>"Martin", "name"=>"Fenner, Martin", "nameIdentifiers"=> [{"nameIdentifier"=>"https://orcid.org/0000-0003-1419-2405", "nameIdentifierScheme"=>"ORCID"}], "nameType"=>"Personal"}])
      expect(subject.titles).to eq([{"title"=>"Eating your own Dog Food"}])
      expect(subject.descriptions.first["description"]).to start_with("Eating your own dog food")
      expect(subject.subjects).to eq([{"subject"=>"datacite"}, {"subject"=>"doi"}, {"subject"=>"metadata"}, {"subject"=>"featured"}])
      expect(subject.dates).to eq([{"date"=>"2016-12-20", "dateType"=>"Issued"}, {"date"=>"2016-12-20", "dateType"=>"Created"}, {"date"=>"2016-12-20", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2016")
      expect(subject.related_identifiers.length).to eq(3)
      expect(subject.related_identifiers.last).to eq("relatedIdentifier"=>"10.5438/55e5-t5c0", "relatedIdentifierType"=>"DOI", "relationType"=>"References")
      expect(subject.publisher).to eq("DataCite")
    end

    it "GTEx dataset" do
      input = fixture_path + 'schema_org_gtex.json'
      subject = Bolognese::Metadata.new(input: input)

      expect(subject.valid?).to be true
      expect(subject.identifiers).to eq([{"identifier"=>"https://doi.org/10.25491/d50j-3083", "identifierType"=>"DOI"}, {"identifier"=>"687610993", "identifierType"=>"md5"}])
      expect(subject.url).to eq("https://ors.datacite.org/doi:/10.25491/d50j-3083")
      expect(subject.content_url).to eq(["https://storage.googleapis.com/gtex_analysis_v7/single_tissue_eqtl_data/GTEx_Analysis_v7_eQTL_expression_matrices.tar.gz"])
      expect(subject.types).to eq("bibtex"=>"misc", "citeproc"=>"dataset", "resourceType"=>"Gene expression matrices", "resourceTypeGeneral"=>"Dataset", "ris"=>"DATA", "schemaOrg"=>"Dataset")
      expect(subject.creators).to eq([{"name"=>"The GTEx Consortium", "nameType"=>"Organizational"}])
      expect(subject.titles).to eq([{"title"=>"Fully processed, filtered and normalized gene expression matrices (in BED format) for each tissue, which were used as input into FastQTL for eQTL discovery"}])
      expect(subject.version_info).to eq("v7")
      expect(subject.subjects).to eq([{"subject"=>"gtex"}, {"subject"=>"annotation"}, {"subject"=>"phenotype"}, {"subject"=>"gene regulation"}, {"subject"=>"transcriptomics"}])
      expect(subject.dates).to eq([{"date"=>"2017", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2017")
      expect(subject.container).to eq("title"=>"GTEx", "type"=>"DataRepository")
      expect(subject.publisher).to eq("GTEx")
      expect(subject.funding_references.length).to eq(7)
      expect(subject.funding_references.first).to eq("funderIdentifier"=>"https://doi.org/10.13039/100000052", "funderIdentifierType"=>"Crossref Funder ID", "funderName"=>"Common Fund of the Office of the Director of the NIH")
    end

    it "TOPMed dataset" do
      input = fixture_path + 'schema_org_topmed.json'
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifiers).to eq([{"identifier"=>"https://doi.org/10.23725/8na3-9s47", "identifierType"=>"DOI"},
        {"identifier"=>"3b33f6b9338fccab0901b7d317577ea3", "identifierType"=>"md5"},
        {"identifier"=>"ark:/99999/fk41CrU4eszeLUDe", "identifierType"=>"minid"},
        {"identifier"=>"dg.4503/c3d66dc9-58da-411c-83c4-dd656aa3c4b7", "identifierType"=>"dataguid"}])
      expect(subject.url).to eq("https://ors.datacite.org/doi:/10.23725/8na3-9s47")
      expect(subject.content_url).to eq(["s3://cgp-commons-public/topmed_open_access/197bc047-e917-55ed-852d-d563cdbc50e4/NWD165827.recab.cram", "gs://topmed-irc-share/public/NWD165827.recab.cram"])
      expect(subject.types).to eq("bibtex"=>"misc", "citeproc"=>"dataset", "resourceType"=>"CRAM file", "resourceTypeGeneral"=>"Dataset", "ris"=>"DATA", "schemaOrg"=>"Dataset")
      expect(subject.creators).to eq([{"name"=>"TOPMed IRC", "nameType"=>"Organizational"}])
      expect(subject.titles).to eq([{"title"=>"NWD165827.recab.cram"}])
      expect(subject.subjects).to eq([{"subject"=>"topmed"}, {"subject"=>"whole genome sequencing"}])
      expect(subject.dates).to eq([{"date"=>"2017-11-30", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2017")
      expect(subject.publisher).to eq("TOPMed")
      expect(subject.related_identifiers).to eq([{"relatedIdentifier"=>"10.23725/2g4s-qv04", "relatedIdentifierType"=>"DOI", "relationType"=>"References", "resourceTypeGeneral"=>"Dataset"}])
      expect(subject.funding_references).to eq([{"funderIdentifier"=>"https://doi.org/10.13039/100000050", "funderIdentifierType"=>"Crossref Funder ID", "funderName"=>"National Heart, Lung, and Blood Institute (NHLBI)"}])
    end

    it "geolocation" do
      input = fixture_path + 'schema_org_geolocation.json'
      subject = Bolognese::Metadata.new(input: input)

      expect(subject.valid?).to be true
      expect(subject.identifiers).to eq([{"identifier"=>"https://doi.org/10.6071/z7wc73", "identifierType"=>"DOI"}])
      expect(subject.types).to eq("bibtex"=>"misc", "citeproc"=>"dataset", "resourceType"=>"dataset", "resourceTypeGeneral"=>"Dataset", "ris"=>"DATA", "schemaOrg"=>"Dataset")
      expect(subject.creators.length).to eq(6)
      expect(subject.creators.first).to eq("familyName"=>"Bales", "givenName"=>"Roger", "name"=>"Bales, Roger", "nameType"=>"Personal")
      expect(subject.titles).to eq([{"title"=>"Southern Sierra Critical Zone Observatory (SSCZO), Providence Creek meteorological data, soil moisture and temperature, snow depth and air temperature"}])
      expect(subject.subjects).to eq([{"subject"=>"Earth sciences"},
        {"subject"=>"soil moisture"},
        {"subject"=>"soil temperature"},
        {"subject"=>"snow depth"},
        {"subject"=>"air temperature"},
        {"subject"=>"water balance"},
        {"subject"=>"Nevada"},
        {"subject"=>"Sierra (mountain range)"}])
      expect(subject.dates).to eq([{"date"=>"2013", "dateType"=>"Issued"}, {"date"=>"2014-10-17", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2013")
      expect(subject.publisher).to eq("UC Merced")
      expect(subject.funding_references).to eq([{"funderName"=>"National Science Foundation, Division of Earth Sciences, Critical Zone Observatories"}])
      expect(subject.geo_locations).to eq([{"geoLocationPlace"=>"Providence Creek (Lower, Upper and P301)", "geoLocationPoint"=>{"pointLatitude"=>"37.047756", "pointLongitude"=>"-119.221094"}}])
    end

    it "geolocation geoshape" do
      input = fixture_path + 'schema_org_geoshape.json'
      subject = Bolognese::Metadata.new(input: input)

      expect(subject.valid?).to be true
      expect(subject.identifiers).to eq([{"identifier"=>"https://doi.org/10.1594/pangaea.842237", "identifierType"=>"DOI"}])
      expect(subject.types).to eq("bibtex"=>"misc", "citeproc"=>"dataset", "resourceTypeGeneral"=>"Dataset", "ris"=>"DATA", "schemaOrg"=>"Dataset")
      expect(subject.creators.length).to eq(2)
      expect(subject.creators.first).to eq("name"=>"Tara Oceans Consortium, Coordinators", "nameType"=>"Organizational")
      expect(subject.titles).to eq([{"title"=>"Registry of all stations from the Tara Oceans Expedition (2009-2013)"}])
      expect(subject.dates).to eq([{"date"=>"2015-02-03", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2015")
      expect(subject.publisher).to eq("PANGAEA")
      expect(subject.geo_locations).to eq([{"geoLocationBox"=>{"eastBoundLongitude"=>"174.9006", "northBoundLatitude"=>"79.6753", "southBoundLatitude"=>"-64.3088", "westBoundLongitude"=>"-168.5182"}}])
    end

    it "schema_org list" do
      data = IO.read(fixture_path + 'schema_org_list.json').strip
      input = JSON.parse(data).first.to_json
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifiers).to eq([{"identifier"=>"https://doi.org/10.23725/7jg3-v803", "identifierType"=>"DOI"},
        {"identifier"=>"ark:/99999/fk4E1n6n1YHKxPk", "identifierType"=>"minid"},
        {"identifier"=>"dg.4503/01b048d0-e128-4cb0-94e9-b2d2cab7563d",
         "identifierType"=>"dataguid"},
        {"identifier"=>"f9e72bdf25bf4b4f0e581d9218fec2eb", "identifierType"=>"md5"}])
      expect(subject.url).to eq("https://ors.datacite.org/doi:/10.23725/7jg3-v803")
      expect(subject.content_url).to eq(["s3://cgp-commons-public/topmed_open_access/44a8837b-4456-5709-b56b-54e23000f13a/NWD100953.recab.cram","gs://topmed-irc-share/public/NWD100953.recab.cram","dos://dos.commons.ucsc-cgp.org/01b048d0-e128-4cb0-94e9-b2d2cab7563d?version=2018-05-26T133719.491772Z"])
      expect(subject.types).to eq("bibtex"=>"misc", "citeproc"=>"dataset", "resourceType"=>"CRAM file", "resourceTypeGeneral"=>"Dataset", "ris"=>"DATA", "schemaOrg"=>"Dataset")
      expect(subject.creators).to eq([{"name"=>"TOPMed", "nameType"=>"Organizational"}])
      expect(subject.titles).to eq([{"title"=>"NWD100953.recab.cram"}])
      expect(subject.subjects).to eq([{"subject"=>"topmed"}, {"subject"=>"whole genome sequencing"}])
      expect(subject.dates).to eq([{"date"=>"2017-11-30", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2017")
      expect(subject.publisher).to eq("TOPMed")
      expect(subject.funding_references).to eq([{"funderIdentifier"=>"https://doi.org/10.13039/100000050", "funderIdentifierType"=>"Crossref Funder ID", "funderName"=>"National Heart, Lung, and Blood Institute (NHLBI)"}])
    end

    it "from attributes" do
      subject = Bolognese::Metadata.new(input: nil,
        from: "schema_org",
        doi: "10.5281/zenodo.1239",
        creators: [{"type"=>"Person", "name"=>"Jahn, Najko", "givenName"=>"Najko", "familyName"=>"Jahn"}],
        titles: [{ "title" => "Publication Fp7 Funding Acknowledgment - Plos Openaire" }],
        descriptions: [{ "description" => "The dataset contains a sample of metadata describing papers" }],
        publisher: "Zenodo",
        publication_year: "2013",
        dates: [{"date"=>"2013-04-03", "dateType"=>"Issued"}],
        funding_references: [{"awardNumber"=>"246686",
          "awardTitle"=>"Open Access Infrastructure for Research in Europe",
          "awardUri"=>"info:eu-repo/grantAgreement/EC/FP7/246686/",
          "funderIdentifier"=>"https://doi.org/10.13039/501100000780",
          "funderIdentifierType"=>"Crossref Funder ID",
          "funderName"=>"European Commission"}],
        types: { "resourceTypeGeneral" => "Dataset", "schemaOrg" => "Dataset" })
      
      expect(subject.valid?).to be true
      expect(subject.doi).to eq("10.5281/zenodo.1239")
      expect(subject.identifiers).to eq([{"identifier"=>"https://doi.org/10.5281/zenodo.1239", "identifierType"=>"DOI"}])
      expect(subject.types["schemaOrg"]).to eq("Dataset")
      expect(subject.types["resourceTypeGeneral"]).to eq("Dataset")
      expect(subject.creators).to eq([{"familyName"=>"Jahn", "givenName"=>"Najko", "name"=>"Jahn, Najko", "type"=>"Person"}])
      expect(subject.titles).to eq([{"title"=>"Publication Fp7 Funding Acknowledgment - Plos Openaire"}])
      expect(subject.descriptions.first["description"]).to start_with("The dataset contains a sample of metadata describing papers")
      expect(subject.dates).to eq([{"date"=>"2013-04-03", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2013")
      expect(subject.publisher).to eq("Zenodo")
      expect(subject.funding_references).to eq([{"awardNumber"=>"246686",
        "awardTitle"=>"Open Access Infrastructure for Research in Europe",
        "awardUri"=>"info:eu-repo/grantAgreement/EC/FP7/246686/",
        "funderIdentifier"=>"https://doi.org/10.13039/501100000780",
        "funderIdentifierType"=>"Crossref Funder ID",
        "funderName"=>"European Commission"}])
    end
  end
end
