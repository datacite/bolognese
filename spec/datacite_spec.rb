require 'spec_helper'

describe Bolognese::Datacite, vcr: true do
  context "get metadata" do
    let(:id) { "https://doi.org/10.5061/DRYAD.8515" }

    subject { Bolognese::Datacite.new(id) }

    let(:datacite_doi) { "10.5061/DRYAD.8515" }

    it "Dataset" do
      expect(subject.id).to eq("https://doi.org/10.5061/dryad.8515")
      expect(subject.type).to eq("Dataset")
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

    it "BlogPosting" do
      id = "https://doi.org/10.5438/4K3M-NYVG"
      subject = Bolognese::Datacite.new(id)
      expect(subject.id).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(subject.type).to eq("CreativeWork")
      expect(subject.author).to eq([{"@type"=>"Person", "@id"=>"http://orcid.org/0000-0003-1419-2405", "givenName"=>"Martin", "familyName"=>"Fenner"}])
      expect(subject.name).to eq("Eating your own Dog Food")
      expect(subject.alternate_name).to eq("MS-49-3632-5083")
      expect(subject.description).to start_with("Eating your own dog food")
      expect(subject.date_published).to eq("2016")
      expect(subject.is_part_of).to eq("@type"=>"CreativeWork", "@id"=>"https://doi.org/10.5438/0000-00ss")
      expect(subject.citation).to eq([{"@type"=>"CreativeWork", "@id"=>"https://doi.org/10.5438/0012"},
                                      {"@type"=>"CreativeWork", "@id"=>"https://doi.org/10.5438/55e5-t5c0"}])
      expect(subject.provider).to eq("@type"=>"Organization", "name"=>"DataCite")
    end

    # it "get_datacite_metadata" do
    #   response = subject.get_datacite_metadata(datacite_doi)
    #   expect(response["DOI"]).to eq(datacite_doi)
    #   expect(response["title"]).to eq("Data from: A new malaria agent in African hominids")
    #   expect(response["container-title"]).to eq("Dryad Digital Repository")
    #   expect(response["author"]).to eq([{"family"=>"Ollomo", "given"=>"Benjamin"}, {"family"=>"Durand", "given"=>"Patrick"}, {"family"=>"Prugnolle", "given"=>"Franck"}, {"family"=>"Douzery", "given"=>"Emmanuel J. P."}, {"family"=>"Arnathau", "given"=>"Céline"}, {"family"=>"Nkoghe", "given"=>"Dieudonné"}, {"family"=>"Leroy", "given"=>"Eric"}, {"family"=>"Renaud", "given"=>"François"}])
    #   expect(response["issued"]).to be_nil
    #   expect(response["published"]).to eq("2011")
    #   expect(response["deposited"]).to eq("2011-02-01T17:32:02Z")
    #   expect(response["updated"]).to eq("2017-02-04T17:54:39Z")
    #   expect(response["resource_type_id"]).to eq("Dataset")
    #   expect(response["resource_type"]).to eq("DataPackage")
    #   expect(response["publisher_id"]).to eq("CDL.DRYAD")
    #   expect(response["registration_agency_id"]).to eq("datacite")
    # end

    # it "get_datacite_metadata with not found error" do
    #   ids = { "pmcid" => "PMC1762313", "pmid" => "17183658", "doi" => "10.5061/dryad.8515", "versions" => [{ "pmcid" => "PMC1762313.1", "current" => "true" }] }
    #   response = subject.get_datacite_metadata("#{datacite_doi}x")
    #   expect(response).to eq(error: "Resource not found.", status: 404)
    # end
  end
end
