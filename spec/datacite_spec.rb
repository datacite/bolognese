require 'spec_helper'

describe Bolognese::Datacite, vcr: true do
  context "get metadata" do
    let(:id) { "https://doi.org/10.5061/DRYAD.8515" }

    subject { Bolognese::Datacite.new(id: id) }

    it "Dataset" do
      expect(subject.id).to eq("https://doi.org/10.5061/dryad.8515")
      expect(subject.type).to eq("Dataset")
      expect(subject.additional_type).to eq("DataPackage")
      expect(subject.author).to eq([{"@type"=>"Person", "givenName"=>"Benjamin", "familyName"=>"Ollomo"},
                                    {"@type"=>"Person", "givenName"=>"Patrick", "familyName"=>"Durand"},
                                    {"@type"=>"Person", "givenName"=>"Franck", "familyName"=>"Prugnolle"},
                                    {"@type"=>"Person", "givenName"=>"Emmanuel J. P.", "familyName"=>"Douzery"},
                                    {"@type"=>"Person", "givenName"=>"Céline", "familyName"=>"Arnathau"},
                                    {"@type"=>"Person", "givenName"=>"Dieudonné", "familyName"=>"Nkoghe"},
                                    {"@type"=>"Person", "givenName"=>"Eric", "familyName"=>"Leroy"},
                                    {"@type"=>"Person", "givenName"=>"François", "familyName"=>"Renaud"}])
      expect(subject.name).to eq("Data from: A new malaria agent in African hominids.")
      expect(subject.alternate_name).to eq("Ollomo B, Durand P, Prugnolle F, Douzery EJP, Arnathau C, Nkoghe D, Leroy E, Renaud F (2009) A new malaria agent in African hominids. PLoS Pathogens 5(5): e1000446.")
      expect(subject.license).to eq("http://creativecommons.org/publicdomain/zero/1.0/")
      expect(subject.date_published).to eq("2011")
      expect(subject.has_part).to eq([{"@type"=>"CreativeWork", "@id"=>"https://doi.org/10.5061/dryad.8515/1"},
                                      {"@type"=>"CreativeWork", "@id"=>"https://doi.org/10.5061/dryad.8515/2"}])
      expect(subject.citation).to eq([{"@type"=>"CreativeWork", "@id"=>"https://doi.org/10.1371/journal.ppat.1000446"}])
      expect(subject.publisher).to eq("@type"=>"Organization", "name"=>"Dryad Digital Repository")
      expect(subject.provider).to eq("@type"=>"Organization", "name"=>"DataCite")
    end

    it "BlogPosting" do
      id = "https://doi.org/10.5438/4K3M-NYVG"
      subject = Bolognese::Datacite.new(id: id)
      expect(subject.id).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(subject.type).to eq("ScholarlyArticle")
      expect(subject.additional_type).to eq("BlogPosting")
      expect(subject.author).to eq([{"@type"=>"Person", "@id"=>"http://orcid.org/0000-0003-1419-2405", "givenName"=>"Martin", "familyName"=>"Fenner"}])
      expect(subject.name).to eq("Eating your own Dog Food")
      expect(subject.alternate_name).to eq("MS-49-3632-5083")
      expect(subject.description).to start_with("Eating your own dog food")
      expect(subject.date_published).to eq("2016-12-20")
      expect(subject.date_modified).to eq("2016-12-20")
      expect(subject.is_part_of).to eq("@type"=>"CreativeWork", "@id"=>"https://doi.org/10.5438/0000-00ss")
      expect(subject.citation).to eq([{"@type"=>"CreativeWork", "@id"=>"https://doi.org/10.5438/0012"},
                                      {"@type"=>"CreativeWork", "@id"=>"https://doi.org/10.5438/55e5-t5c0"}])
      expect(subject.publisher).to eq("@type"=>"Organization", "name"=>"DataCite")
      expect(subject.provider).to eq("@type"=>"Organization", "name"=>"DataCite")
    end

    it "Date" do
      id = "https://doi.org/10.4230/lipics.tqc.2013.93"
      subject = Bolognese::Datacite.new(id: id)
      expect(subject.id).to eq("https://doi.org/10.4230/lipics.tqc.2013.93")
      expect(subject.type).to eq("ScholarlyArticle")
      expect(subject.additional_type).to eq("ConferencePaper")
      expect(subject.author).to eq([{"@type"=>"Person", "givenName"=>"Nathaniel", "familyName"=>"Johnston"}])
      expect(subject.name).to eq("The Minimum Size of Qubit Unextendible Product Bases")
      expect(subject.description).to start_with("We investigate the problem of constructing unextendible product bases in the qubit case")
      expect(subject.date_published).to eq("2013")
      expect(subject.publisher).to eq("@type"=>"Organization", "name"=>"Schloss Dagstuhl - Leibniz-Zentrum fuer Informatik GmbH, Wadern/Saarbruecken, Germany")
      expect(subject.provider).to eq("@type"=>"Organization", "name"=>"DataCite")
    end

    it "Schema.org JSON" do
      json = JSON.parse(subject.as_schema_org)
      expect(json["@id"]).to eq("https://doi.org/10.5061/dryad.8515")
    end
  end

  context "get metadata as string" do
    it "Dataset" do
      id = "https://doi.org/10.5061/DRYAD.8515"
      string = Bolognese::Datacite.new(id: id).as_datacite

      subject = Bolognese::Datacite.new(string: string)
      expect(subject.id).to eq("https://doi.org/10.5061/dryad.8515")
      expect(subject.type).to eq("Dataset")
      expect(subject.additional_type).to eq("DataPackage")
      expect(subject.author).to eq([{"@type"=>"Person", "givenName"=>"Benjamin", "familyName"=>"Ollomo"},
                                    {"@type"=>"Person", "givenName"=>"Patrick", "familyName"=>"Durand"},
                                    {"@type"=>"Person", "givenName"=>"Franck", "familyName"=>"Prugnolle"},
                                    {"@type"=>"Person", "givenName"=>"Emmanuel J. P.", "familyName"=>"Douzery"},
                                    {"@type"=>"Person", "givenName"=>"Céline", "familyName"=>"Arnathau"},
                                    {"@type"=>"Person", "givenName"=>"Dieudonné", "familyName"=>"Nkoghe"},
                                    {"@type"=>"Person", "givenName"=>"Eric", "familyName"=>"Leroy"},
                                    {"@type"=>"Person", "givenName"=>"François", "familyName"=>"Renaud"}])
      expect(subject.name).to eq("Data from: A new malaria agent in African hominids.")
      expect(subject.alternate_name).to eq("Ollomo B, Durand P, Prugnolle F, Douzery EJP, Arnathau C, Nkoghe D, Leroy E, Renaud F (2009) A new malaria agent in African hominids. PLoS Pathogens 5(5): e1000446.")
      expect(subject.license).to eq("http://creativecommons.org/publicdomain/zero/1.0/")
      expect(subject.date_published).to eq("2011")
      expect(subject.has_part).to eq([{"@type"=>"CreativeWork", "@id"=>"https://doi.org/10.5061/dryad.8515/1"},
                                      {"@type"=>"CreativeWork", "@id"=>"https://doi.org/10.5061/dryad.8515/2"}])
      expect(subject.citation).to eq([{"@type"=>"CreativeWork", "@id"=>"https://doi.org/10.1371/journal.ppat.1000446"}])
      expect(subject.provider).to eq("@type"=>"Organization", "name"=>"DataCite")
    end
  end
end
