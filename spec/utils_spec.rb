require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  let(:input) { "https://doi.org/10.1101/097196" }

  subject { Bolognese::Metadata.new(input: input, from: "crossref") }

  context "validate url" do
    it "DOI" do
      str = "https://doi.org/10.5438/0000-00ss"
      response = subject.validate_url(str)
      expect(response).to eq("DOI")
    end

    it "URL" do
      str = "https://blog.datacite.org/eating-your-own-dog-food"
      response = subject.validate_url(str)
      expect(response).to eq("URL")
    end

    it "ISSN" do
      str = "ISSN 2050-084X"
      response = subject.validate_url(str)
      expect(response).to eq("ISSN")
    end

    it "string" do
      str = "eating-your-own-dog-food"
      response = subject.validate_url(str)
      expect(response).to be_nil
    end
  end

  context "parse attributes" do
    it "string" do
      element = "10.5061/DRYAD.8515"
      response = subject.parse_attributes(element)
      expect(response).to eq("10.5061/DRYAD.8515")
    end

    it "hash" do
      element = { "__content__" => "10.5061/DRYAD.8515" }
      response = subject.parse_attributes(element)
      expect(response).to eq("10.5061/DRYAD.8515")
    end

    it "array" do
      element = [{ "__content__" => "10.5061/DRYAD.8515" }]
      response = subject.parse_attributes(element)
      expect(response).to eq("10.5061/DRYAD.8515")
    end

    it "nil" do
      element = nil
      response = subject.parse_attributes(element)
      expect(response).to be_nil
    end
  end

  context "normalize id" do
    it "doi" do
      doi = "10.5061/DRYAD.8515"
      response = subject.normalize_id(doi)
      expect(response).to eq("https://doi.org/10.5061/dryad.8515")
    end

    it "doi as url" do
      doi = "http://dx.doi.org/10.5061/DRYAD.8515"
      response = subject.normalize_id(doi)
      expect(response).to eq("https://doi.org/10.5061/dryad.8515")
    end

    it "url" do
      url = "https://blog.datacite.org/eating-your-own-dog-food/"
      response = subject.normalize_id(url)
      expect(response).to eq("https://blog.datacite.org/eating-your-own-dog-food")
    end

    it "url with utf-8" do
      url = "http://www.詹姆斯.com/eating-your-own-dog-food/"
      response = subject.normalize_id(url)
      expect(response).to eq("http://www.xn--8ws00zhy3a.com/eating-your-own-dog-food")
    end

    it "ftp" do
      url = "ftp://blog.datacite.org/eating-your-own-dog-food/"
      response = subject.normalize_id(url)
      expect(response).to be_nil
    end

    it "invalid url" do
      url = "http://"
      response = subject.normalize_id(url)
      expect(response).to be_nil
    end

    it "string" do
      url = "eating-your-own-dog-food"
      response = subject.normalize_id(url)
      expect(response).to be_nil
    end
  end

  context "normalize ids" do
    it "doi" do
      ids = [{"@type"=>"CreativeWork", "@id"=>"https://doi.org/10.5438/0012"}, {"@type"=>"CreativeWork", "@id"=>"https://doi.org/10.5438/55E5-T5C0"}]
      response = subject.normalize_ids(ids: ids)
      expect(response).to eq([{"id"=>"https://doi.org/10.5438/0012", "type"=>"CreativeWork"}, {"id"=>"https://doi.org/10.5438/55e5-t5c0", "type"=>"CreativeWork"}])
    end

    it "url" do
      ids = [{"@type"=>"CreativeWork", "@id"=>"https://blog.datacite.org/eating-your-own-dog-food/"}]
      response = subject.normalize_ids(ids: ids)
      expect(response).to eq("id"=>"https://blog.datacite.org/eating-your-own-dog-food", "type" => "CreativeWork")
    end
  end

  context "normalize url" do
    it "with trailing slash" do
      url = "http://creativecommons.org/publicdomain/zero/1.0/"
      response = subject.normalize_url(url)
      expect(response).to eq("http://creativecommons.org/publicdomain/zero/1.0")
    end

    it "uri" do
      url = "info:eu-repo/semantics/openAccess"
      response = subject.normalize_url(url)
      expect(response).to be_nil
    end
  end

  context "to_schema_org" do
    it "with id" do
      author = {"type"=>"Person", "id"=>"http://orcid.org/0000-0003-1419-2405", "givenName"=>"Martin", "familyName"=>"Fenner", "name"=>"Martin Fenner" }
      response = subject.to_schema_org(author)
      expect(response).to eq("givenName"=>"Martin", "familyName"=>"Fenner", "name"=>"Martin Fenner", "@type"=>"Person", "@id"=>"http://orcid.org/0000-0003-1419-2405")
    end
  end

  context "from_schema_org" do
    it "with @id" do
      author = {"@type"=>"Person", "@id"=>"http://orcid.org/0000-0003-1419-2405", "givenName"=>"Martin", "familyName"=>"Fenner", "name"=>"Martin Fenner" }
      response = subject.from_schema_org(author)
      expect(response).to eq("givenName"=>"Martin", "familyName"=>"Fenner", "name"=>"Martin Fenner", "type"=>"Person", "id"=>"http://orcid.org/0000-0003-1419-2405")
    end
  end

  context "sanitize" do
    it 'should remove a tags' do
      text = "In 1998 <strong>Tim Berners-Lee</strong> coined the term <a href=\"https://www.w3.org/Provider/Style/URI\">cool URIs</a>"
      content = subject.sanitize(text)
      expect(content).to eq("In 1998 <strong>Tim Berners-Lee</strong> coined the term cool URIs")
    end

    it 'should only keep specific tags' do
      text = "In 1998 <strong>Tim Berners-Lee</strong> coined the term <a href=\"https://www.w3.org/Provider/Style/URI\">cool URIs</a>"
      content = subject.sanitize(text, tags: ["a"])
      expect(content).to eq("In 1998 Tim Berners-Lee coined the term <a href=\"https://www.w3.org/Provider/Style/URI\">cool URIs</a>")
    end
  end

  context "get_date_parts" do
    it "date" do
      date = "2016-12-20"
      response = subject.get_date_parts(date)
      expect(response).to eq("date-parts"=>[[2016, 12, 20]])
    end

    it "year-month" do
      date = "2016-12"
      response = subject.get_date_parts(date)
      expect(response).to eq("date-parts"=>[[2016, 12]])
    end

    it "year" do
      date = "2016"
      response = subject.get_date_parts(date)
      expect(response).to eq("date-parts"=>[[2016]])
    end
  end

  context "get_date_from_date_parts" do
    it "date" do
      date_as_parts = { "date-parts"=>[[2016, 12, 20]] }
      response = subject.get_date_from_date_parts(date_as_parts)
      expect(response).to eq("2016-12-20")
    end

    it "year-month" do
      date_as_parts = { "date-parts"=>[[2016, 12]] }
      response = subject.get_date_from_date_parts(date_as_parts)
      expect(response).to eq("2016-12")
    end

    it "year" do
      date_as_parts = { "date-parts"=>[[2016]] }
      response = subject.get_date_from_date_parts(date_as_parts)
      expect(response).to eq("2016")
    end
  end
end
