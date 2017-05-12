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
      "Audiovisual" => "VideoObject",
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
      "Other" => "CreativeWork"
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
      "proceedings" => nil,
      "reference-book" => nil,
      "journal-issue" => nil,
      "proceedings-article" => "paper-conference",
      "other" => nil,
      "dissertation" => "thesis",
      "dataset" => "dataset",
      "edited-book" => "book",
      "journal-article" => "article-journal",
      "journal" => nil,
      "report" => "report",
      "book-series" => nil,
      "report-series" => nil,
      "book-track" => nil,
      "standard" => nil,
      "book-section" => "chapter",
      "book-part" => nil,
      "book" => "book",
      "book-chapter" => "chapter",
      "standard-series" => nil,
      "monograph" => "book",
      "component" => nil,
      "reference-entry" => "entry-dictionary",
      "journal-volume" => nil,
      "book-set" => nil
    }

    SO_TO_DC_TRANSLATIONS = {
      "Article" => "Text",
      "AudioObject" => "Sound",
      "Blog" => "Text",
      "BlogPosting" => "Text",
      "Collection" => "Collection",
      "CreativeWork" => "Other",
      "DataCatalog" => "Dataset",
      "Dataset" => "Dataset",
      "Event" => "Event",
      "ImageObject" => "Image",
      "Movie" => "Audiovisual",
      "PublicationIssue" => "Text",
      "ScholarlyArticle" => "Text",
      "Service" => "Service",
      "SoftwareSourceCode" => "Software",
      "VideoObject" => "Audiovisual",
      "WebPage" => "Text",
      "WebSite" => "Text"
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
      "proceedings" => "CONF",
      "reference-book" => "BOOK",
      "journal-issue" => nil,
      "proceedings-article" => "CPAPER",
      "other" => "GEN",
      "dissertation" => "THES",
      "dataset" => "DATA",
      "edited-book" => "BOOK",
      "journal-article" => "JOUR",
      "journal" => nil,
      "report" => nil,
      "book-series" => nil,
      "report-series" => nil,
      "book-track" => nil,
      "standard" => nil,
      "book-section" => "CHAP",
      "book-part" => "CHAP",
      "book" => "BOOK",
      "book-chapter" => "CHAP",
      "standard-series" => nil,
      "monograph" => "BOOK",
      "component" => nil,
      "reference-entry" => "DICT",
      "journal-volume" => nil,
      "book-set" => nil
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
      end
    end

    def find_from_format_by_id(id)
      id = normalize_id(id)

      if /\A(?:(http|https):\/(\/)?(dx\.)?doi.org\/)?(doi:)?(10\.\d{4,5}\/.+)\z/.match(id)
        ra = get_doi_ra(id)
        ra.present? ? ra.downcase : nil
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
      elsif options[:ext] == ".xml" && Maremma.from_xml(string).to_h.dig("doi_records", "doi_record", "crossref")
        "crossref"
      elsif options[:ext] == ".xml" && Maremma.from_xml(string).to_h.dig("resource", "xmlns").to_s.start_with?("http://datacite.org/schema/kernel")
        "datacite"
      elsif options[:ext] == ".json" && Maremma.from_json(string).to_h.dig("ris_type")
        "crosscite"
      elsif options[:ext] == ".json" && Maremma.from_json(string).to_h.dig("schemaVersion").to_s.start_with?("http://datacite.org/schema/kernel")
        "datacite_json"
      elsif options[:ext] == ".json" && Maremma.from_json(string).to_h.dig("issued", "date-parts").present?
        "citeproc"
      elsif options[:ext] == ".json" && Maremma.from_json(string).to_h.dig("@context").to_s.start_with?("http://schema.org")
        "schema_org"
      elsif options[:ext] == ".json" && Maremma.from_json(string).to_h.dig("@context") == ("https://raw.githubusercontent.com/codemeta/codemeta/master/codemeta.jsonld")
        "codemeta"
      end
    end

    def find_from_format_by_string(string)
      if Maremma.from_xml(string).to_h.dig("doi_records", "doi_record", "crossref").present?
        "crossref"
      elsif Maremma.from_xml(string).to_h.dig("resource", "xmlns").to_s.start_with?("http://datacite.org/schema/kernel")
        "datacite"
      elsif Maremma.from_json(string).to_h.dig("ris_type").present?
        "crosscite"
      elsif Maremma.from_json(string).to_h.dig("schemaVersion").to_s.start_with?("http://datacite.org/schema/kernel")
        "datacite_json"
      elsif Maremma.from_json(string).to_h.dig("issued", "date-parts").present?
        "citeproc"
      elsif Maremma.from_json(string).to_h.dig("@context").to_s.start_with?("http://schema.org")
        "schema_org"
      elsif Maremma.from_json(string).to_h.dig("@context") == ("https://raw.githubusercontent.com/codemeta/codemeta/master/codemeta.jsonld")
        "codemeta"
      end
    end

    def orcid_from_url(url)
      Array(/\Ahttp:\/\/orcid\.org\/(.+)/.match(url)).last
    end

    def orcid_as_url(orcid)
      "http://orcid.org/#{orcid}" if orcid.present?
    end

    def validate_orcid(orcid)
      Array(/\A(?:http:\/\/orcid\.org\/)?(\d{4}-\d{4}-\d{4}-\d{3}[0-9X]+)\z/.match(orcid)).last
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

      if element.is_a?(String)
        element
      elsif element.is_a?(Hash)
        element.fetch(content, nil)
      elsif element.is_a?(Array)
        a = element.map { |e| e.fetch(content, nil) }.uniq.unwrap
      else
        nil
      end
    end

    def normalize_id(id)
      return nil unless id.present?

      # check for valid DOI
      doi = normalize_doi(id)
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

      # check for valid HTTP uri
      uri = Addressable::URI.parse(id)
      return nil unless uri && uri.host && %w(http https).include?(uri.scheme)

      # clean up URL
      PostRank::URI.clean(id)
    rescue Addressable::URI::InvalidURIError
      nil
    end

    def normalize_orcid(orcid)
      orcid = validate_orcid(orcid)
      return nil unless orcid.present?

      # turn ORCID ID into URL
      "http://orcid.org/" + Addressable::URI.encode(orcid)
    end

    def normalize_ids(ids: nil)
      Array.wrap(ids).map do |id|
        { "id" => normalize_id(id["@id"]),
          "type" => id["@type"] || Metadata::DC_TO_SO_TRANSLATIONS[id["resourceTypeGeneral"]] || "CreativeWork",
          "title" => id["title"] || id["name"] }.compact
      end.unwrap
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

    def to_schema_org(element)
      mapping = { "type" => "@type", "id" => "@id", "title" => "name" }

      map_hash_keys(element: element, mapping: mapping)
    end

    def from_schema_org(element)
      mapping = { "@type" => "type", "@id" => "id" }

      map_hash_keys(element: element, mapping: mapping)
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
        a.except("type", "@type", "id", "@id", "name", "familyName", "givenName").compact
      end
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
      custom_scrubber = Bolognese::WhitelistScrubber.new(options)

      Loofah.scrub_fragment(text, custom_scrubber).to_s.gsub(/\u00a0/, ' ').strip
    end

    def github_from_url(url)
      return {} unless /\Ahttps:\/\/github\.com\/(.+)(?:\/)?(.+)?(?:\/tree\/)?(.*)\z/.match(url)
      words = URI.parse(url).path[1..-1].split('/')

      { owner: words[0],
        repo: words[1],
        release: words[3] }.compact
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
      "https://raw.githubusercontent.com/#{github_hash[:owner]}/#{github_hash[:repo]}/master/codemeta.json" if github_hash[:owner].present?
    end

    def get_date_parts(iso8601_time)
      return nil if iso8601_time.nil?

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

    def jsonlint(json)
      return ["No JSON provided"] unless json.present?

      error_array = []
      linter = JsonLint::Linter.new
      linter.send(:check_data, json, error_array)
      error_array
    end

  end
end
