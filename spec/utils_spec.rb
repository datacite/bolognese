# frozen_string_literal: true

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

  context "validate_orcid" do
    it "validate_orcid" do
      orcid = "http://orcid.org/0000-0002-2590-225X"
      response = subject.validate_orcid(orcid)
      expect(response).to eq("0000-0002-2590-225X")
    end

    it "validate_orcid https" do
      orcid = "https://orcid.org/0000-0002-2590-225X"
      response = subject.validate_orcid(orcid)
      expect(response).to eq("0000-0002-2590-225X")
    end

    it "validate_orcid id" do
      orcid = "0000-0002-2590-225X"
      response = subject.validate_orcid(orcid)
      expect(response).to eq("0000-0002-2590-225X")
    end

    it "validate_orcid www" do
      orcid = "http://www.orcid.org/0000-0002-2590-225X"
      response = subject.validate_orcid(orcid)
      expect(response).to eq("0000-0002-2590-225X")
    end

    it "validate_orcid with spaces" do
      orcid = "0000 0002 1394 3097"
      response = subject.validate_orcid(orcid)
      expect(response).to eq("0000-0002-1394-3097")
    end

    it "validate_orcid wrong id" do
      orcid = "0000-0002-1394-309"
      response = subject.validate_orcid(orcid)
      expect(response).to be_nil
    end
  end

  context "validate_orcid_scheme" do
    it "validate_orcid_scheme" do
      orcid = "http://orcid.org"
      response = subject.validate_orcid_scheme(orcid)
      expect(response).to eq("orcid.org")
    end

    it "validate_orcid_scheme trailing slash" do
      orcid = "http://orcid.org/"
      response = subject.validate_orcid_scheme(orcid)
      expect(response).to eq("orcid.org")
    end

    it "validate_orcid_scheme https" do
      orcid = "https://orcid.org"
      response = subject.validate_orcid_scheme(orcid)
      expect(response).to eq("orcid.org")
    end

    it "validate_orcid_scheme www" do
      orcid = "http://www.orcid.org"
      response = subject.validate_orcid_scheme(orcid)
      expect(response).to eq("orcid.org")
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

    it "array of strings" do
      element = ["datacite", "doi", "metadata", "featured"]
      response = subject.parse_attributes(element)
      expect(response).to eq(["datacite", "doi", "metadata", "featured"])
    end

    it "nil" do
      element = nil
      response = subject.parse_attributes(element)
      expect(response).to be_nil
    end

    it "first" do
      element = [{ "__content__" => "10.5061/DRYAD.8515/1" }, { "__content__" => "10.5061/DRYAD.8515/2" }]
      response = subject.parse_attributes(element, first: true)
      expect(response).to eq("10.5061/DRYAD.8515/1")
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

    it "sandbox via url" do
      url = "https://handle.test.datacite.org/10.20375/0000-0001-ddb8-7"
      response = subject.normalize_id(url)
      expect(response).to eq("https://handle.test.datacite.org/10.20375/0000-0001-ddb8-7")
    end

    it "sandbox via options" do
      url = "10.20375/0000-0001-ddb8-7"
      response = subject.normalize_id(url, sandbox: true)
      expect(response).to eq("https://handle.test.datacite.org/10.20375/0000-0001-ddb8-7")
    end
  end

  context "normalize ids" do
    it "doi" do
      ids = [{"@type"=>"CreativeWork", "@id"=>"https://doi.org/10.5438/0012"}, {"@type"=>"CreativeWork", "@id"=>"https://doi.org/10.5438/55E5-T5C0"}]
      response = subject.normalize_ids(ids: ids)
      expect(response).to eq([{"relatedIdentifier"=>"10.5438/0012", "relatedIdentifierType"=>"DOI"}, {"relatedIdentifier"=>"10.5438/55e5-t5c0", "relatedIdentifierType"=>"DOI"}])
    end

    it "url" do
      ids = [{"@type"=>"CreativeWork", "@id"=>"https://blog.datacite.org/eating-your-own-dog-food/"}]
      response = subject.normalize_ids(ids: ids)
      expect(response).to eq("relatedIdentifier"=>"https://blog.datacite.org/eating-your-own-dog-food", "relatedIdentifierType"=>"URL")
    end
  end

  context "normalize url" do
    it "with trailing slash" do
      url = "http://creativecommons.org/publicdomain/zero/1.0/"
      response = subject.normalize_url(url)
      expect(response).to eq("http://creativecommons.org/publicdomain/zero/1.0")
    end

    it "with trailing slash and to https" do
      url = "http://creativecommons.org/publicdomain/zero/1.0/"
      response = subject.normalize_url(url, https: true)
      expect(response).to eq("https://creativecommons.org/publicdomain/zero/1.0")
    end

    it "uri" do
      url = "info:eu-repo/semantics/openAccess"
      response = subject.normalize_url(url)
      expect(response).to eq("info:eu-repo/semantics/openAccess")
    end
  end

  context "normalize cc url" do
    it "with trailing slash" do
      url = "http://creativecommons.org/publicdomain/zero/1.0/"
      response = subject.normalize_cc_url(url)
      expect(response).to eq("https://creativecommons.org/publicdomain/zero/1.0/legalcode")
    end

    it "with trailing slash and to https" do
      url = "http://creativecommons.org/publicdomain/zero/1.0/"
      response = subject.normalize_cc_url(url)
      expect(response).to eq("https://creativecommons.org/publicdomain/zero/1.0/legalcode")
    end

    it "not found" do
      url = "http://creativecommons.org/publicdomain/zero/2.0/"
      response = subject.normalize_cc_url(url)
      expect(response).to eq("https://creativecommons.org/publicdomain/zero/2.0")
    end
  end

  context "normalize issn" do
    it "from array" do
      input = [{"media_type"=>"print", "__content__"=>"13040855"}, {"media_type"=>"electronic", "__content__"=>"21468427"}]
      response = subject.normalize_issn(input)
      expect(response).to eq("2146-8427")
    end

    it "from empty array" do
      input = []
      response = subject.normalize_issn(input)
      expect(response).to be_nil
    end

    it "from hash" do
      input = {"media_type"=>"electronic", "__content__"=>"21468427"}
      response = subject.normalize_issn(input)
      expect(response).to eq("2146-8427")
    end

    it "from string" do
      input = "2146-8427"
      response = subject.normalize_issn(input)
      expect(response).to eq("2146-8427")
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

  context "from_schema_org_creators" do
    it "with affiliation" do
      authors = [{"@type"=>"Person", "@id"=>"http://orcid.org/0000-0003-1419-2405", "givenName"=>"Martin", "familyName"=>"Fenner", "name"=>"Martin Fenner", "affiliation" => {
        "@id" => "https://ror.org/04wxnsj81",
        "name" => "DataCite",
        "@type" => "Organization"
      }}]
      response = subject.from_schema_org_creators(authors)
      expect(response).to eq([{"affiliation"=>
        {"affiliationIdentifier"=>"https://ror.org/04wxnsj81",
         "affiliationIdentifierScheme"=>"ROR",
         "__content__"=>"DataCite",
         "schemeUri"=>"https://ror.org/"},
         "creatorName"=>{"__content__"=>"Martin Fenner", "nameType"=>"Personal"},
         "familyName"=>"Fenner",
         "givenName"=>"Martin",
         "nameIdentifier"=>
       [{"__content__"=>"http://orcid.org/0000-0003-1419-2405",
         "nameIdentifierScheme"=>"ORCID",
         "schemeUri"=>"https://orcid.org"}]}])
    end

    it "without affiliation" do
      authors = [{"@type"=>"Person", "@id"=>"http://orcid.org/0000-0003-1419-2405", "givenName"=>"Martin", "familyName"=>"Fenner", "name"=>"Martin Fenner" }]
      response = subject.from_schema_org_creators(authors)
      expect(response).to eq([{"creatorName"=>{"__content__"=>"Martin Fenner", "nameType"=>"Personal"},
        "familyName"=>"Fenner",
        "givenName"=>"Martin",
        "nameIdentifier"=>
      [{"__content__"=>"http://orcid.org/0000-0003-1419-2405",
        "nameIdentifierScheme"=>"ORCID",
        "schemeUri"=>"https://orcid.org"}]}])
    end
  end

  context "to_schema_org_identifiers" do
    it "with identifiers" do
      identifiers = [{"identifier" => "https://doi.org/10.23725/8na3-9s47", "identifierType" => "DOI"}, {"identifierType"=>"md5", "identifier"=>"3b33f6b9338fccab0901b7d317577ea3"}, {"identifierType"=>"minid", "identifier"=>"ark:/99999/fk41CrU4eszeLUDe"}, {"identifierType"=>"dataguid", "identifier"=>"dg.4503/c3d66dc9-58da-411c-83c4-dd656aa3c4b7"}]
      response = subject.to_schema_org_identifiers(identifiers, type: "Dataset")
      expect(response).to eq([{"@type"=>"PropertyValue", "propertyID"=>"DOI", "value"=>"https://doi.org/10.23725/8na3-9s47"},
        {"@type"=>"PropertyValue",
         "propertyID"=>"md5",
         "value"=>"3b33f6b9338fccab0901b7d317577ea3"},
        {"@type"=>"PropertyValue",
         "propertyID"=>"minid",
         "value"=>"ark:/99999/fk41CrU4eszeLUDe"},
        {"@type"=>"PropertyValue",
         "propertyID"=>"dataguid",
         "value"=>"dg.4503/c3d66dc9-58da-411c-83c4-dd656aa3c4b7"}])
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

  context "get_datetime_from_time" do
    it "present" do
      time = "20200226071709"
      response = subject.get_datetime_from_time(time)
      expect(response).to eq("2020-02-26T07:17:09Z")
    end

    it "past" do
      time = "18770312071709"
      response = subject.get_datetime_from_time(time)
      expect(response).to eq("1877-03-12T07:17:09Z")
    end

    it "future" do
      time = "20970114071709"
      response = subject.get_datetime_from_time(time)
      expect(response).to eq("2097-01-14T07:17:09Z")
    end

    it "invalid" do
      time = "20201587168864794"
      response = subject.get_datetime_from_time(time)
      expect(response).to be_nil
    end

    it "nil" do
      time = nil
      response = subject.get_datetime_from_time(time)
      expect(response).to be_nil
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

  context "get_date_from_parts" do
    it "date" do
      response = subject.get_date_from_parts(2016, 12, 20)
      expect(response).to eq("2016-12-20")
    end

    it "year-month" do
      response = subject.get_date_from_parts(2016, 12)
      expect(response).to eq("2016-12")
    end

    it "year" do
      response = subject.get_date_from_parts(2016)
      expect(response).to eq("2016")
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

  context "get_date" do
    it "publication date" do
      dates = [{ "date"=>"2016-12-20", "dateType" => "Issued" }]
      response = subject.get_date(dates, "Issued")
      expect(response).to eq("2016-12-20")
    end
  end

  context "get_series_information" do
    it "only title" do
      str = nil
      response = subject.get_series_information(str)
      expect(response).to eq({})
    end

    it "only title" do
      str = "DataCite Blog"
      response = subject.get_series_information(str)
      expect(response).to eq("title"=>"DataCite Blog")
    end

    it "title and pages" do
      str = "DataCite Blog, 1-3"
      response = subject.get_series_information(str)
      expect(response).to eq("firstPage"=>"1", "lastPage"=>"3", "title"=>"DataCite Blog")
    end

    it "title, volume and pages" do
      str = "DataCite Blog, 7, 1-3"
      response = subject.get_series_information(str)
      expect(response).to eq("firstPage"=>"1", "lastPage"=>"3", "title"=>"DataCite Blog", "volume"=>"7")
    end

    it "title, volume, issue and pages" do
      str = "DataCite Blog, 7(11), 1-3"
      response = subject.get_series_information(str)
      expect(response).to eq("firstPage"=>"1", "issue"=>"11", "lastPage"=>"3", "title"=>"DataCite Blog", "volume"=>"7")
    end
  end

  context "github" do
    it "github_from_url" do
      url = "https://github.com/datacite/bolognese"
      response = subject.github_from_url(url)
      expect(response).to eq(:owner=>"datacite", :repo=>"bolognese")
    end

    it "github_from_url file" do
      url = "https://github.com/datacite/metadata-reports/blob/master/software/codemeta.json"
      response = subject.github_from_url(url)
      expect(response).to eq(:owner=>"datacite", :repo=>"metadata-reports", :release=>"master", :path=>"software/codemeta.json")
    end

    it "github_as_codemeta_url" do
      url = "https://github.com/datacite/bolognese"
      response = subject.github_as_codemeta_url(url)
      expect(response).to eq("https://raw.githubusercontent.com/datacite/bolognese/master/codemeta.json")
    end

    it "github_from_url file" do
      url = "https://github.com/datacite/metadata-reports/blob/master/software/codemeta.json"
      response = subject.github_as_codemeta_url(url)
      expect(response).to eq("https://raw.githubusercontent.com/datacite/metadata-reports/master/software/codemeta.json")
    end
  end

  context "spdx" do
    it "name_to_spdx exists" do
      name = "Creative Commons Attribution 4.0 International"
      response = subject.name_to_spdx(name)
      expect(response).to eq({"rights"=>"Creative Commons Attribution 4.0 International", "rightsUri"=>"https://creativecommons.org/licenses/by/4.0/legalcode", "rightsIdentifier"=>"cc-by-4.0", "rightsIdentifierScheme"=>"SPDX", "schemeUri"=>"https://spdx.org/licenses/"})
    end

    it "name_to_spdx id" do
      name = "CC-BY-4.0"
      response = subject.name_to_spdx(name)
      expect(response).to eq({"rights"=>"Creative Commons Attribution 4.0 International", "rightsUri"=>"https://creativecommons.org/licenses/by/4.0/legalcode", "rightsIdentifier"=>"cc-by-4.0", "rightsIdentifierScheme"=>"SPDX", "schemeUri"=>"https://spdx.org/licenses/"})
    end

    it "hsh_to_spdx id" do
      hsh = { "rightsIdentifier" => "cc-by-4.0" }
      response = subject.hsh_to_spdx(hsh)
      expect(response).to eq({"rights"=>"Creative Commons Attribution 4.0 International", "rightsUri"=>"https://creativecommons.org/licenses/by/4.0/legalcode", "rightsIdentifier"=>"cc-by-4.0", "rightsIdentifierScheme"=>"SPDX", "schemeUri"=>"https://spdx.org/licenses/"})
    end

    it "hsh_to_spdx url" do
      hsh = { "rightsURI" => "http://creativecommons.org/licenses/by-nc/4.0/legalcode" }
      response = subject.hsh_to_spdx(hsh)
      expect(response).to eq("rights"=>"Creative Commons Attribution Non Commercial 4.0 International", "rightsUri"=>"https://creativecommons.org/licenses/by-nc/4.0/legalcode", "rightsIdentifier"=>"cc-by-nc-4.0", "rightsIdentifierScheme"=>"SPDX", "schemeUri"=>"https://spdx.org/licenses/")
    end

    it "hsh_to_spdx not found" do
      hsh = { "rightsURI" => "info:eu-repo/semantics/openAccess" }
      response = subject.hsh_to_spdx(hsh)
      expect(response).to eq({"rightsUri"=>"info:eu-repo/semantics/openAccess"})
    end
  end

  context "fos" do
    it "name_to_fos match" do
      name = "Biological sciences"
      response = subject.name_to_fos(name)
      expect(response).to eq([{"subject"=>"Biological sciences"},
       {"schemeUri"=>"http://www.oecd.org/science/inno/38235147.pdf",
        "subject"=>"FOS: Biological sciences",
        "subjectScheme"=>"Fields of Science and Technology (FOS)"}])
    end

    it "name_to_fos for match" do
      name = "Statistics"
      response = subject.name_to_fos(name)
      expect(response).to eq([{"subject"=>"Statistics"},
       {"schemeUri"=>"http://www.oecd.org/science/inno/38235147.pdf",
        "subject"=>"FOS: Mathematics",
        "subjectScheme"=>"Fields of Science and Technology (FOS)"}])
    end

    it "name_to_fos no match" do
      name = "Random tag"
      response = subject.name_to_fos(name)
      expect(response).to eq([{"subject"=>"Random tag"}])
    end

    it "hsh_to_fos match" do
      hsh = { "__content__" => "Biological sciences" }
      response = subject.hsh_to_fos(hsh)
      expect(response).to eq([{"subject"=>"Biological sciences"},
       {"schemeUri"=>"http://www.oecd.org/science/inno/38235147.pdf",
        "subject"=>"FOS: Biological sciences",
        "subjectScheme"=>"Fields of Science and Technology (FOS)"}])
    end

    it "hsh_to_fos for match" do
      hsh = { "__content__" => "Statistics" }
      response = subject.hsh_to_fos(hsh)
      expect(response).to eq([{"subject"=>"Statistics"},
       {"schemeUri"=>"http://www.oecd.org/science/inno/38235147.pdf",
        "subject"=>"FOS: Mathematics",
        "subjectScheme"=>"Fields of Science and Technology (FOS)"}])
    end

    it "hsh_to_fos for with schemeUri in hash" do
      hsh = {
      "subject" => "FOS: Computer and information sciences",
      "subjectScheme" => "Fields of Science and Technology (FOS)",
      "schemeUri" => "http://www.oecd.org/science/inno/38235147.pdf"}
      response = subject.hsh_to_fos(hsh)
      expect(response).to eq([{
      "subject" => "FOS: Computer and information sciences",
      "subjectScheme" => "Fields of Science and Technology (FOS)",
      "schemeUri" => "http://www.oecd.org/science/inno/38235147.pdf"}])
    end

    it "hsh_to_fos no match" do
      hsh = { "__content__"=>"Random tag" }
      response = subject.hsh_to_fos(hsh)
      expect(response).to eq([{"subject"=>"Random tag"}])
    end

  end
end
