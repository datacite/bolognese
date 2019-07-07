# frozen_string_literal: true

module Bolognese
  module Utils
    LICENSE_NAMES = {
      "http://creativecommons.org/publicdomain/zero/1.0/" => "Public Domain (CC0 1.0)",
      "http://creativecommons.org/licenses/by/3.0/" => "Creative Commons Attribution 3.0 (CC-BY 3.0)",
      "http://creativecommons.org/licenses/by/4.0/" => "Creative Commons Attribution 4.0 (CC-BY 4.0)",
      "http://creativecommons.org/licenses/by-nc/4.0/" => "Creative Commons Attribution Noncommercial 4.0 (CC-BY-NC 4.0)",
      "http://creativecommons.org/licenses/by-sa/4.0/" => "Creative Commons Attribution Share Alike 4.0 (CC-BY-SA 4.0)",
      "http://creativecommons.org/licenses/by-nc-nd/4.0/" => "Creative Commons Attribution Noncommercial No Derivatives 4.0 (CC-BY-NC-ND 4.0)"
    }

    DC_TO_SO_TRANSLATIONS = {
      "Audiovisual" => "MediaObject",
      "Collection" => "Collection",
      "Dataset" => "Dataset",
      "Event" => "Event",
      "Image" => "ImageObject",
      "InteractiveResource" => nil,
      "Model" => nil,
      "PhysicalObject" => nil,
      "Service" => "Service",
      "Software" => "SoftwareSourceCode",
      "Sound" => "AudioObject",
      "Text" => "ScholarlyArticle",
      "Workflow" => nil,
      "Other" => "CreativeWork",
      # not part of DataCite schema, but used internally
      "Periodical" => "Periodical",
      "DataCatalog" => "DataCatalog"
    }

    DC_TO_CP_TRANSLATIONS = {
      "Audiovisual" => "motion_picture",
      "Collection" => nil,
      "Dataset" => "dataset",
      "Event" => nil,
      "Image" => "graphic",
      "InteractiveResource" => nil,
      "Model" => nil,
      "PhysicalObject" => nil,
      "Service" => nil,
      "Sound" => "song",
      "Text" => "report",
      "Workflow" => nil,
      "Other" => nil
    }

    CR_TO_CP_TRANSLATIONS = {
      "Proceedings" => nil,
      "ReferenceBook" => nil,
      "JournalIssue" => nil,
      "ProceedingsArticle" => "paper-conference",
      "Other" => nil,
      "Dissertation" => "thesis",
      "Dataset" => "dataset",
      "EditedBook" => "book",
      "JournalArticle" => "article-journal",
      "Journal" => nil,
      "Report" => "report",
      "BookSeries" => nil,
      "ReportSeries" => nil,
      "BookTrack" => nil,
      "Standard" => nil,
      "BookSection" => "chapter",
      "BookPart" => nil,
      "Book" => "book",
      "BookChapter" => "chapter",
      "StandardSeries" => nil,
      "Monograph" => "book",
      "Component" => nil,
      "ReferenceEntry" => "entry-dictionary",
      "JournalVolume" => nil,
      "BookSet" => nil
    }

    CR_TO_SO_TRANSLATIONS = {
      "Proceedings" => nil,
      "ReferenceBook" => "Book",
      "JournalIssue" => "PublicationIssue",
      "ProceedingsArticle" => nil,
      "Other" => "CreativeWork",
      "Dissertation" => "Thesis",
      "Dataset" => "Dataset",
      "EditedBook" => "Book",
      "JournalArticle" => "ScholarlyArticle",
      "Journal" => nil,
      "Report" => nil,
      "BookSeries" => nil,
      "ReportSeries" => nil,
      "BookTrack" => nil,
      "Standard" => nil,
      "BookSection" => nil,
      "BookPart" => nil,
      "Book" => "Book",
      "BookChapter" => "Chapter",
      "StandardSeries" => nil,
      "Monograph" => "Book",
      "Component" => "CreativeWork",
      "ReferenceEntry" => nil,
      "JournalVolume" => "PublicationVolume",
      "BookSet" => nil,
      "PostedContent" => "ScholarlyArticle"
    }

    CR_TO_BIB_TRANSLATIONS = {
      "Proceedings" => "proceedings",
      "ReferenceBook" => "book",
      "JournalIssue" => nil,
      "ProceedingsArticle" => nil,
      "Other" => nil,
      "Dissertation" => "phdthesis",
      "Dataset" => nil,
      "EditedBook" => "book",
      "JournalArticle" => "article",
      "Journal" => nil,
      "Report" => nil,
      "BookSeries" => nil,
      "ReportSeries" => nil,
      "BookTrack" => nil,
      "Standard" => nil,
      "BookSection" => "inbook",
      "BookPart" => nil,
      "Book" => "book",
      "BookChapter" => "inbook",
      "StandardSeries" => nil,
      "Monograph" => "book",
      "Component" => nil,
      "ReferenceEntry" => nil,
      "JournalVolume" => nil,
      "BookSet" => nil,
      "PostedContent" => "article"
    }

    BIB_TO_CR_TRANSLATIONS = {
      "proceedings" => "Proceedings",
      "phdthesis" => "Dissertation",
      "article" => "JournalArticle",
      "book" => "Book",
      "inbook" => "BookChapter"
    }

    CR_TO_JATS_TRANSLATIONS = {
      "Proceedings" => "working-paper",
      "ReferenceBook" => "book",
      "JournalIssue" => "journal",
      "ProceedingsArticle" => "working-paper",
      "Other" => nil,
      "Dissertation" => nil,
      "Dataset" => "data",
      "EditedBook" => "book",
      "JournalArticle" => "journal",
      "Journal" => "journal",
      "Report" => "report",
      "BookSeries" => "book",
      "ReportSeries" => "report",
      "BookTrack" => "book",
      "Standard" => "standard",
      "BookSection" => "chapter",
      "BookPart" => "chapter",
      "Book" => "book",
      "BookChapter" => "chapter",
      "StandardSeries" => "standard",
      "Monograph" => "book",
      "Component" => nil,
      "ReferenceEntry" => nil,
      "JournalVolume" => "journal",
      "BookSet" => "book"
    }

    SO_TO_DC_TRANSLATIONS = {
      "Article" => "Text",
      "AudioObject" => "Sound",
      "Blog" => "Text",
      "BlogPosting" => "Text",
      "Chapter" => "Text",
      "Collection" => "Collection",
      "DataCatalog" => "Dataset",
      "Dataset" => "Dataset",
      "Event" => "Event",
      "ImageObject" => "Image",
      "Movie" => "Audiovisual",
      "PublicationIssue" => "Text",
      "ScholarlyArticle" => "Text",
      "Thesis" => "Text",
      "Service" => "Service",
      "SoftwareSourceCode" => "Software",
      "VideoObject" => "Audiovisual",
      "WebPage" => "Text",
      "WebSite" => "Text"
    }

    SO_TO_JATS_TRANSLATIONS = {
      "Article" => "journal",
      "AudioObject" => nil,
      "Blog" => nil,
      "BlogPosting" => nil,
      "Book" => "book",
      "Collection" => nil,
      "CreativeWork" => nil,
      "DataCatalog" => "data",
      "Dataset" => "data",
      "Event" => nil,
      "ImageObject" => nil,
      "Movie" => nil,
      "PublicationIssue" => "journal",
      "ScholarlyArticle" => "journal",
      "Service" => nil,
      "SoftwareSourceCode" => "software",
      "VideoObject" => nil,
      "WebPage" => nil,
      "WebSite" => "website"
    }

    SO_TO_CP_TRANSLATIONS = {
      "Article" => "",
      "AudioObject" => "song",
      "Blog" => "report",
      "BlogPosting" => "post-weblog",
      "Collection" => nil,
      "CreativeWork" => nil,
      "DataCatalog" => "dataset",
      "Dataset" => "dataset",
      "Event" => nil,
      "ImageObject" => "graphic",
      "Movie" => "motion_picture",
      "PublicationIssue" => nil,
      "ScholarlyArticle" => "article-journal",
      "Service" => nil,
      "Thesis" => "thesis",
      "VideoObject" => "broadcast",
      "WebPage" => "webpage",
      "WebSite" => "webpage"
    }

    SO_TO_RIS_TRANSLATIONS = {
      "Article" => nil,
      "AudioObject" => nil,
      "Blog" => nil,
      "BlogPosting" => "BLOG",
      "Collection" => nil,
      "CreativeWork" => "GEN",
      "DataCatalog" => "CTLG",
      "Dataset" => "DATA",
      "Event" => nil,
      "ImageObject" => "FIGURE",
      "Movie" => "MPCT",
      "PublicationIssue" => nil,
      "ScholarlyArticle" => "JOUR",
      "Service" => nil,
      "SoftwareSourceCode" => "COMP",
      "VideoObject" => "VIDEO",
      "WebPage" => "ELEC",
      "WebSite" => nil
    }

    CR_TO_RIS_TRANSLATIONS = {
      "Proceedings" => "CONF",
      "ReferenceBook" => "BOOK",
      "JournalIssue" => nil,
      "ProceedingsArticle" => "CPAPER",
      "Other" => "GEN",
      "Dissertation" => "THES",
      "Dataset" => "DATA",
      "EditedBook" => "BOOK",
      "JournalArticle" => "JOUR",
      "Journal" => nil,
      "Report" => nil,
      "BookSeries" => nil,
      "ReportSeries" => nil,
      "BookTrack" => nil,
      "Standard" => nil,
      "BookSection" => "CHAP",
      "BookPart" => "CHAP",
      "Book" => "BOOK",
      "BookChapter" => "CHAP",
      "StandardSeries" => nil,
      "Monograph" => "BOOK",
      "Component" => nil,
      "ReferenceEntry" => "DICT",
      "JournalVolume" => nil,
      "BookSet" => nil
    }

    DC_TO_RIS_TRANSLATIONS = {
      "Audiovisual" => "MPCT",
      "Collection" => nil,
      "Dataset" => "DATA",
      "Event" => nil,
      "Image" => "FIGURE",
      "InteractiveResource" => nil,
      "Model" => nil,
      "PhysicalObject" => nil,
      "Service" => nil,
      "Software" => "COMP",
      "Sound" => "SOUND",
      "Text" => "RPRT",
      "Workflow" => nil,
      "Other" => nil
    }

    SO_TO_BIB_TRANSLATIONS = {
      "Article" => "article",
      "AudioObject" => "misc",
      "Thesis" => "phdthesis",
      "Blog" => "misc",
      "BlogPosting" => "article",
      "Collection" => "misc",
      "CreativeWork" => "misc",
      "DataCatalog" => "misc",
      "Dataset" => "misc",
      "Event" => "misc",
      "ImageObject" => "misc",
      "Movie" => "misc",
      "PublicationIssue" => "misc",
      "ScholarlyArticle" => "article",
      "Service" => "misc",
      "SoftwareSourceCode" => "misc",
      "VideoObject" => "misc",
      "WebPage" => "misc",
      "WebSite" => "misc"
    }

    def find_from_format(id: nil, string: nil, ext: nil)
      if id.present?
        find_from_format_by_id(id)
      elsif ext.present?
        find_from_format_by_ext(string, ext: ext)
      elsif string.present?
        find_from_format_by_string(string)
      else
        "datacite"
      end
    end

    def find_from_format_by_id(id)
      id = normalize_id(id)

      if /\A(?:(http|https):\/(\/)?(dx\.)?(doi.org|handle.test.datacite.org)\/)?(doi:)?(10\.\d{4,5}\/.+)\z/.match(id)
        ra = get_doi_ra(id)
        %w(DataCite Crossref mEDRA KISTI JaLC OP).include?(ra) ? ra.downcase : nil
      elsif /\A(?:(http|https):\/(\/)?orcid\.org\/)?(\d{4}-\d{4}-\d{4}-\d{3}[0-9X]+)\z/.match(id)
        "orcid"
      elsif /\A(http|https):\/(\/)?github\.com\/(.+)\z/.match(id)
        "codemeta"
      else
        "schema_org"
      end
    end

    def find_from_format_by_ext(string, options={})
      if options[:ext] == ".bib"
        "bibtex"
      elsif options[:ext] == ".ris"
        "ris"
      elsif options[:ext] == ".xml" && Maremma.from_xml(string).to_h.dig("crossref_result", "query_result", "body", "query", "doi_record", "crossref")
        "crossref"
      elsif options[:ext] == ".xml" && Nokogiri::XML(string, nil, 'UTF-8', &:noblanks).collect_namespaces.find { |k, v| v.start_with?("http://datacite.org/schema/kernel") }      
        "datacite"
      elsif options[:ext] == ".json" && Maremma.from_json(string).to_h.dig("@context").to_s.start_with?("http://schema.org", "https://schema.org")
        "schema_org"
      elsif options[:ext] == ".json" && Maremma.from_json(string).to_h.dig("@context") == ("https://raw.githubusercontent.com/codemeta/codemeta/master/codemeta.jsonld")
        "codemeta"
      elsif options[:ext] == ".json" && Maremma.from_json(string).to_h.dig("schemaVersion").to_s.start_with?("http://datacite.org/schema/kernel")
        "datacite_json"
      elsif options[:ext] == ".json" && Maremma.from_json(string).to_h.dig("types")
        "crosscite"
      elsif options[:ext] == ".json" && Maremma.from_json(string).to_h.dig("issued", "date-parts").present?
        "citeproc"
      end
    end

    def find_from_format_by_string(string)
      if Maremma.from_xml(string).to_h.dig("crossref_result", "query_result", "body", "query", "doi_record", "crossref").present?
        "crossref"
      elsif Nokogiri::XML(string, nil, 'UTF-8', &:noblanks).collect_namespaces.find { |k, v| v.start_with?("http://datacite.org/schema/kernel") }  
        "datacite"
      elsif Maremma.from_json(string).to_h.dig("@context").to_s.start_with?("http://schema.org", "https://schema.org")
        "schema_org"
      elsif Maremma.from_json(string).to_h.dig("@context") == ("https://raw.githubusercontent.com/codemeta/codemeta/master/codemeta.jsonld")
        "codemeta"
      elsif Maremma.from_json(string).to_h.dig("schema-version").to_s.start_with?("http://datacite.org/schema/kernel")
        "datacite_json"
      elsif Maremma.from_json(string).to_h.dig("types").present?
        "crosscite"
      elsif Maremma.from_json(string).to_h.dig("issued", "date-parts").present?
        "citeproc"
      elsif string.start_with?("TY  - ")
        "ris"
      elsif BibTeX.parse(string).first
        "bibtex"
      end
    rescue BibTeX::ParseError => error
      nil
    end

    def orcid_from_url(url)
      Array(/\A:(http|https):\/\/orcid\.org\/(.+)/.match(url)).last
    end

    def orcid_as_url(orcid)
      "https://orcid.org/#{orcid}" if orcid.present?
    end

    def validate_orcid(orcid)
      orcid = Array(/\A(?:(http|https):\/\/(www\.)?orcid\.org\/)?(\d{4}[[:space:]-]\d{4}[[:space:]-]\d{4}[[:space:]-]\d{3}[0-9X]+)\z/.match(orcid)).last
      orcid.gsub(/[[:space:]]/, "-") if orcid.present?
    end

    def validate_orcid_scheme(orcid_scheme)
      Array(/\A(http|https):\/\/(www\.)?(orcid\.org)/.match(orcid_scheme)).last
    end

    def validate_url(str)
      if /\A(?:(http|https):\/\/(dx\.)?doi.org\/)?(doi:)?(10\.\d{4,5}\/.+)\z/.match(str)
        "DOI"
      elsif /\A(http|https):\/\//.match(str)
        "URL"
      elsif /\A(ISSN|eISSN) (\d{4}-\d{3}[0-9X]+)\z/.match(str)
        "ISSN"
      end
    end

    def parse_attributes(element, options={})
      content = options[:content] || "__content__"

      if element.is_a?(String) && options[:content].nil?
        CGI.unescapeHTML(element)
      elsif element.is_a?(Hash)
        element.fetch( CGI.unescapeHTML(content), nil)
      elsif element.is_a?(Array)
        a = element.map { |e| e.is_a?(Hash) ? e.fetch( CGI.unescapeHTML(content), nil) : e }.uniq
        a = options[:first] ? a.first : a.unwrap
      else
        nil
      end
    end

    def normalize_id(id, options={})
      return nil unless id.present?

      # check for valid DOI
      doi = normalize_doi(id, options)
      return doi if doi.present?

      # check for valid HTTP uri
      uri = Addressable::URI.parse(id)
      return nil unless uri && uri.host && %w(http https).include?(uri.scheme)

      # clean up URL
      PostRank::URI.clean(id)
    rescue Addressable::URI::InvalidURIError
      nil
    end

    def normalize_url(id)
      return nil unless id.present?

      # handle info URIs
      return id if id.to_s.start_with?("info")

      # check for valid HTTP uri
      uri = Addressable::URI.parse(id)

      return nil unless uri && uri.host && %w(http https ftp).include?(uri.scheme)

      # clean up URL
      PostRank::URI.clean(id)
    rescue Addressable::URI::InvalidURIError
      nil
    end

    def normalize_orcid(orcid)
      orcid = validate_orcid(orcid)
      return nil unless orcid.present?

      # turn ORCID ID into URL
      "https://orcid.org/" + Addressable::URI.encode(orcid)
    end

    def normalize_ids(ids: nil, relation_type: nil)
      Array.wrap(ids).select { |idx| idx["@id"].present? }.map do |idx|
        id = normalize_id(idx["@id"])
        related_identifier_type = doi_from_url(id).present? ? "DOI" : "URL"
        id = doi_from_url(id) || id

        { "relatedIdentifier" => id,
          "relationType" => relation_type,
          "relatedIdentifierType" => related_identifier_type,
          "resourceTypeGeneral" => Metadata::SO_TO_DC_TRANSLATIONS[idx["@type"]] }.compact
      end.unwrap
    end

    # pick electronic issn if there are multiple
    # format issn as xxxx-xxxx
    def normalize_issn(input, options={})
      content = options[:content] || "__content__"

      issn = if input.blank?
        nil
      elsif input.is_a?(String) && options[:content].nil?
        input
      elsif input.is_a?(Hash)
        input.fetch(content, nil)
      elsif input.is_a?(Array)
        a = input.find { |a| a["media_type"] == "electronic" } || input.first
        a.fetch(content, nil)
      end

      case issn.to_s.length
      when 9
        issn
      when 8
        issn[0..3] + "-" + issn[4..7]
      else
        nil
      end
    end

    # find Creative Commons or OSI license in licenses array, normalize url and name
    def normalize_licenses(licenses)
      standard_licenses = Array.wrap(licenses).map { |l| URI.parse(l["url"]) }.select { |li| li.host && li.host[/(creativecommons.org|opensource.org)$/] }
      return licenses unless standard_licenses.present?

      # use HTTPS
      uri.scheme = "https"

      # use host name without subdomain
      uri.host = Array(/(creativecommons.org|opensource.org)/.match uri.host).last

      # normalize URLs
      if uri.host == "creativecommons.org"
        uri.path = uri.path.split('/')[0..-2].join("/") if uri.path.split('/').last == "legalcode"
        uri.path << '/' unless uri.path.end_with?('/')
      else
        uri.path = uri.path.gsub(/(-license|\.php|\.html)/, '')
        uri.path = uri.path.sub(/(mit|afl|apl|osl|gpl|ecl)/) { |match| match.upcase }
        uri.path = uri.path.sub(/(artistic|apache)/) { |match| match.titleize }
        uri.path = uri.path.sub(/([^0-9\-]+)(-)?([1-9])?(\.)?([0-9])?$/) do
          m = Regexp.last_match
          text = m[1]

          if m[3].present?
            version = [m[3], m[5].presence || "0"].join(".")
            [text, version].join("-")
          else
            text
          end
        end
      end

      uri.to_s
    rescue URI::InvalidURIError
      nil
    end

    def to_datacite_json(element, options={})
      a = Array.wrap(element).map do |e|
        e.inject({}) {|h, (k,v)| h[k.dasherize] = v; h }
      end
      options[:first] ? a.unwrap : a.presence
    end

    def from_datacite_json(element)
      Array.wrap(element).map do |e|
        e.inject({}) {|h, (k,v)| h[k.underscore] = v; h }
      end
    end

    def to_schema_org(element)
      mapping = { "type" => "@type", "id" => "@id", "title" => "name" }

      map_hash_keys(element: element, mapping: mapping)
    end

    def to_schema_org_creators(element)
      element = Array.wrap(element).map do |c|
        c["affiliation"] = { "@type" => "Organization", "name" => Array.wrap(c["affiliation"]).first } if c["affiliation"].present?
        c["@type"] = c["nameType"].present? ? c["nameType"][0..-3] : nil
        c["@id"] = Array.wrap(c["nameIdentifiers"]).first.to_h.fetch("nameIdentifier", nil)
        c["name"] = c["familyName"].present? ? [c["givenName"], c["familyName"]].join(" ") : c["name"]
        c.except("nameIdentifiers", "nameType").compact
      end.unwrap
    end

    def to_schema_org_contributors(element)
      element = Array.wrap(element).map do |c|
        c["affiliation"] = { "@type" => "Organization", "name" => Array.wrap(c["affiliation"]).first } if c["affiliation"].present?
        c["@type"] = c["nameType"].present? ? c["nameType"][0..-3] : nil
        c["@id"] = Array.wrap(c["nameIdentifiers"]).first.to_h.fetch("nameIdentifier", nil)
        c["name"] = c["familyName"].present? ? [c["givenName"], c["familyName"]].join(" ") : c["name"]
        c.except("nameIdentifiers", "nameType").compact
      end.unwrap
    end

    def to_schema_org_container(element, options={})
      return nil unless (element.is_a?(Hash) || (element.nil? && options[:container_title].present?))

      { 
        "@id" => element["identifier"],
        "@type" => (options[:type] == "Dataset") ? "DataCatalog" : "Periodical",
        "name" => element["title"] || options[:container_title] }.compact
    end

    def to_schema_org_identifiers(element, options={})
      Array.wrap(element).map do |ai|
        { 
          "@type" => "PropertyValue",
          "propertyID" => ai["identifierType"],
          "value" => ai["identifier"] }
      end.unwrap
    end

    def to_schema_org_relation(related_identifiers: nil, relation_type: nil)
      return nil unless related_identifiers.present? && relation_type.present?

      relation_type = relation_type == "References" ? ["References", "Cites", "Documents"] : [relation_type] 

      Array.wrap(related_identifiers).select { |ri| relation_type.include?(ri["relationType"]) }.map do |r|
        if r["relatedIdentifierType"] == "ISSN" && r["relationType"] == "IsPartOf"
          {
            "@type" => "Periodical",
            "issn" => r["relatedIdentifier"] }.compact
        else
        {
          "@id" => normalize_id(r["relatedIdentifier"]),
          "@type" => DC_TO_SO_TRANSLATIONS[r["resourceTypeGeneral"]] || "CreativeWork" }.compact
        end
      end.unwrap
    end

    def to_schema_org_funder(funding_references)
      return nil unless funding_references.present?

      Array.wrap(funding_references).map do |fr|
        {
          "@id" => fr["funderIdentifier"],
          "@type" => "Organization",
          "name" => fr["funderName"] }.compact
      end.unwrap
    end

    def to_schema_org_spatial_coverage(geo_location)
      return nil unless geo_location.present?

      Array.wrap(geo_location).reduce([]) do |sum, gl|
        if gl.fetch("geoLocationPoint", nil)
          sum << { 
            "@type" => "Place",
            "geo" => {
              "@type" => "GeoCoordinates",
              "address" => gl["geoLocationPlace"],
              "latitude" => gl.dig("geoLocationPoint", "pointLatitude"),
              "longitude" => gl.dig("geoLocationPoint", "pointLongitude") }
          }.compact
        end

        if gl.fetch("geoLocationBox", nil)
          sum << { 
            "@type" => "Place",
            "geo" => {
              "@type" => "GeoShape",
              "address" => gl["geoLocationPlace"],
              "box" => [gl.dig("geoLocationBox", "southBoundLatitude"),
                        gl.dig("geoLocationBox", "westBoundLongitude"),
                        gl.dig("geoLocationBox", "northBoundLatitude"),
                        gl.dig("geoLocationBox", "eastBoundLongitude")].compact.join(" ").presence }.compact
          }.compact
        end

        if gl.fetch("geoLocationPolygon", nil)
          sum << { 
            "@type" => "Place",
            "geo" => {
              "@type" => "GeoShape",
              "address" => gl["geoLocationPlace"],
              "polygon" => Array.wrap(gl.dig("geoLocationPolygon")).map do |glp| 
                [glp.dig("polygonPoint", "pointLongitude"), glp.dig("polygonPoint", "pointLatitude")].compact
              end.compact }
          }
        end

        if gl.fetch("geoLocationPlace", nil) && !gl.fetch("geoLocationPoint", nil) && !gl.fetch("geoLocationBox", nil) && !gl.fetch("geoLocationPolygon", nil)
          sum << { 
            "@type" => "Place",
            "geo" => {
              "@type" => "GeoCoordinates",
              "address" => gl["geoLocationPlace"] }
          }.compact
        end

        sum
      end.unwrap
    end

    def from_schema_org(element)
      mapping = { "@type" => "type", "@id" => "id" }

      map_hash_keys(element: element, mapping: mapping)
    end

    def from_schema_org_creators(element)
      element = Array.wrap(element).map do |c|
        c["nameIdentifier"] = [{ "__content__" => c["@id"], "nameIdentifierScheme" => "ORCID", "schemeUri" => "https://orcid.org" }] if normalize_orcid(c["@id"])
        c["@type"] = c["@type"].find { |t| %w(Person Organization).include?(t) } if c["@type"].is_a?(Array)
        c["creatorName"] = { "nameType" => c["@type"].present? ? c["@type"].titleize + "al" : nil, "__content__" => c["name"] }.compact
        c.except("@id", "@type", "name") 
      end
    end

    def from_schema_org_contributors(element)
      element = Array.wrap(element).map do |c|
        c["nameIdentifier"] = [{ "__content__" => c["@id"], "nameIdentifierScheme" => "ORCID", "schemeUri" => "https://orcid.org" }] if normalize_orcid(c["@id"])
        c["contributorName"] = { "nameType" => c["@type"].present? ? c["@type"].titleize + "al" : nil, "__content__" => c["name"] }.compact
        c.except("@id", "@type", "name") 
      end
    end

    def map_hash_keys(element: nil, mapping: nil)
      Array.wrap(element).map do |a|
        a.map {|k, v| [mapping.fetch(k, k), v] }.reduce({}) do |hsh, (k, v)|
          if v.is_a?(Hash)
            hsh[k] = to_schema_org(v)
            hsh
          else
            hsh[k] = v
            hsh
          end
        end
      end.unwrap
    end

    def to_identifier(identifier)
      {
        "@type" => "PropertyValue",
        "propertyID" => identifier["relatedIdentifierType"],
        "value" => identifier["relatedIdentifier"] }
    end

    def from_citeproc(element)
      Array.wrap(element).map do |a|
        if a["literal"].present?
          a["@type"] = "Organization"
          a["name"] = a["literal"]
        else
          a["@type"] = "Person"
          a["name"] = [a["given"], a["family"]].compact.join(" ")
        end
        a["givenName"] = a["given"]
        a["familyName"] = a["family"]
        a.except("given", "family", "literal").compact
      end.unwrap
    end

    def to_citeproc(element)
      Array.wrap(element).map do |a|
        a["family"] = a["familyName"]
        a["given"] = a["givenName"]
        a["literal"] = a["name"] unless a["familyName"].present?
        a.except("nameType", "type", "@type", "id", "@id", "name", "familyName", "givenName", "affiliation", "nameIdentifiers", "contributorType").compact
      end.presence
    end

    def to_ris(element)
      Array.wrap(element).map do |a|
        if a["familyName"].present?
          [a["familyName"], a["givenName"]].join(", ")
        else
          a["name"]
        end
      end.unwrap
    end

    def sanitize(text, options={})
      options[:tags] ||= Set.new(%w(strong em b i code pre sub sup br))
      content = options[:content] || "__content__"
      custom_scrubber = Bolognese::WhitelistScrubber.new(options)

      if text.is_a?(String)
        # remove excessive internal whitespace with squish
        Loofah.scrub_fragment(text, custom_scrubber).to_s.squish
      elsif text.is_a?(Hash)
        sanitize(text.fetch(content, nil))
      elsif text.is_a?(Array)
        a = text.map { |e| e.is_a?(Hash) ? sanitize(e.fetch(content, nil)) : sanitize(e) }.uniq
        a = options[:first] ? a.first : a.unwrap
      else
        nil
      end
    end

    def github_from_url(url)
      return {} unless /\Ahttps:\/\/github\.com\/(.+)(?:\/)?(.+)?(?:\/tree\/)?(.*)\z/.match(url)
      words = URI.parse(url).path[1..-1].split('/')
      path = words.length > 3 ? words[4...words.length].join("/") : nil

      { owner: words[0],
        repo: words[1],
        release: words[3],
        path: path }.compact
    end

    def github_repo_from_url(url)
      github_from_url(url).fetch(:repo, nil)
    end

    def github_release_from_url(url)
      github_from_url(url).fetch(:release, nil)
    end

    def github_owner_from_url(url)
      github_from_url(url).fetch(:owner, nil)
    end

    def github_as_owner_url(url)
      github_hash = github_from_url(url)
      "https://github.com/#{github_hash[:owner]}" if github_hash[:owner].present?
    end

    def github_as_repo_url(url)
      github_hash = github_from_url(url)
      "https://github.com/#{github_hash[:owner]}/#{github_hash[:repo]}" if github_hash[:repo].present?
    end

    def github_as_release_url(url)
      github_hash = github_from_url(url)
      "https://github.com/#{github_hash[:owner]}/#{github_hash[:repo]}/tree/#{github_hash[:release]}" if github_hash[:release].present?
    end

    def github_as_codemeta_url(url)
      github_hash = github_from_url(url)

      if github_hash[:path].to_s.end_with?("codemeta.json")
        "https://raw.githubusercontent.com/#{github_hash[:owner]}/#{github_hash[:repo]}/#{github_hash[:release]}/#{github_hash[:path]}"
      elsif github_hash[:owner].present?
        "https://raw.githubusercontent.com/#{github_hash[:owner]}/#{github_hash[:repo]}/master/codemeta.json"
      end
    end

    def get_date_parts(iso8601_time)
      return { 'date-parts' => [[]] } if iso8601_time.nil?

      year = iso8601_time[0..3].to_i
      month = iso8601_time[5..6].to_i
      day = iso8601_time[8..9].to_i
      { 'date-parts' => [[year, month, day].reject { |part| part == 0 }] }
    end

    def get_date_from_date_parts(date_as_parts)
      date_parts = date_as_parts.fetch("date-parts", []).first
      year, month, day = date_parts[0], date_parts[1], date_parts[2]
      get_date_from_parts(year, month, day)
    end

    def get_date_from_parts(year, month = nil, day = nil)
      [year.to_s.rjust(4, '0'), month.to_s.rjust(2, '0'), day.to_s.rjust(2, '0')].reject { |part| part == "00" }.join("-")
    end

    def get_date_parts_from_parts(year, month = nil, day = nil)
      { 'date-parts' => [[year.to_i, month.to_i, day.to_i].reject { |part| part == 0 }] }
    end

    def get_iso8601_date(iso8601_time)
      return nil if iso8601_time.nil?
      
      iso8601_time[0..9]
    end

    def get_year_month(iso8601_time)
      return [] if iso8601_time.nil?

      year = iso8601_time[0..3]
      month = iso8601_time[5..6]

      [year.to_i, month.to_i].reject { |part| part == 0 }
    end

    def get_year_month_day(iso8601_time)
      return [] if iso8601_time.nil?

      year = iso8601_time[0..3]
      month = iso8601_time[5..6]
      day = iso8601_time[8..9]

      [year.to_i, month.to_i, day.to_i].reject { |part| part == 0 }
    end

    # parsing of incomplete iso8601 timestamps such as 2015-04 is broken
    # in standard library
    # return nil if invalid iso8601 timestamp
    def get_datetime_from_iso8601(iso8601_time)
      ISO8601::DateTime.new(iso8601_time).to_time.utc
    rescue
      nil
    end

    def get_date(dates, date_type)
      dd = Array.wrap(dates).find { |d| d["dateType"] == date_type } || {}
      dd.fetch("date", nil)
    end

    def get_contributor(contributor, contributor_type)
      contributor.select { |c| c["contributorType"] == contributor_type }
    end

    def get_identifier(identifiers, identifier_type)
      id = Array.wrap(identifiers).find { |i| i["identifierType"] == identifier_type } || {}
      id.fetch("identifier", nil)
    end

    def get_identifier_type(identifier_type)
      return nil unless identifier_type.present?

      identifierTypes = {
        "ark" => "ARK",
        "arxiv" => "arXiv",
        "bibcode" => "bibcode",
        "doi" => "DOI",
        "ean13" => "EAN13",
        "eissn" => "EISSN",
        "handle" => "Handle",
        "igsn" => "IGSN",
        "isbn" => "ISBN",
        "issn" => "ISSN",
        "istc" => "ISTC",
        "lissn" => "LISSN",
        "lsid" => "LSID",
        "pmid" => "PMID",
        "purl" => "PURL",
        "upc" => "UPC",
        "url" => "URL",
        "urn" => "URN",
        "md5" => "md5",
        "minid" => "minid",
        "dataguid" => "dataguid"
      }

      identifierTypes[identifier_type.downcase] || identifier_type
    end

    def get_series_information(str)
      return {} unless str.present?

      str = str.split(",").map(&:strip)

      title = str.first
      volume_issue = str.length > 2 ? str[1].rpartition(/\(([^)]+)\)/) : nil
      volume = volume_issue.present? ? volume_issue[0].presence || volume_issue[2].presence : nil
      issue = volume_issue.present? ? volume_issue[1][1...-1].presence : nil
      pages = str.length > 1 ? str.last : nil
      first_page = pages.present? ? pages.split("-").map(&:strip)[0] : nil
      last_page = pages.present? ? pages.split("-").map(&:strip)[1] : nil

      { 
        "title" => title,
        "volume" => volume,
        "issue" => issue,
        "firstPage" => first_page,
        "lastPage" => last_page }.compact
    end

    def jsonlint(json)
      return ["No JSON provided"] unless json.present?

      error_array = []
      linter = JsonLint::Linter.new
      linter.send(:check_data, json, error_array)
      error_array
    end

  end
end
