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

    def find_from_format(id: nil, string: nil, ext: nil, filename: nil)
      if id.present?
        find_from_format_by_id(id)
      elsif string.present?
        find_from_format_by_string(string, ext: ext, filename: filename)
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

    def find_from_format_by_string(string, options={})
      if options[:ext] == ".bib"
        "bibtex"
      elsif options[:ext] == ".xml" && Maremma.from_xml(string).dig("doi_records", "doi_record", "crossref")
        "crossref"
      elsif options[:ext] == ".xml" && Maremma.from_xml(string).dig("resource", "xmlns").start_with?("http://datacite.org/schema/kernel")
        "datacite"
      elsif options[:ext] == ".json" && Maremma.from_json(string).dig("resource", "xmlns").to_s.start_with?("http://datacite.org/schema/kernel")
        "datacite_json"
      elsif options[:ext] == ".json" && Maremma.from_json(string).dig("resource", "xmlns").to_s.start_with?("http://datacite.org/schema/kernel")
        "citeproc"
      elsif options[:ext] == ".ris"
        "ris"
      elsif options[:filename] == "codemeta.json"
        "codemeta"
      end
    end

    def read(id: nil, string: nil, from: nil, **options)
      p = case from
          when nil
            puts "not implemented"
            return nil
          when "crossref" then Crossref.new(id: id, string: string)
          when "datacite" then Datacite.new(id: id, string: string, regenerate: options[:regenerate])
          when "codemeta" then Codemeta.new(id: id, string: string)
          when "datacite_json" then DataciteJson.new(string: string)
          when "citeproc" then Citeproc.new(id: id, string: string)
          when "bibtex" then Bibtex.new(string: string)
          when "ris" then Ris.new(string: string)
          else SchemaOrg.new(id: id)
          end

      unless p.valid?
        $stderr.puts p.errors.colorize(:red)
      end

      p
    end

    def write(id: nil, string: nil, from: nil, to: nil, **options)
      metadata = read(id: id, string: string, from: from, **options)
      return nil if metadata.nil?

      puts metadata.send(to)
    end

    def generate(id: nil, string: nil, from: nil, to: nil, **options)
      metadata = read(id: id, string: string, from: from, **options)
      return nil if metadata.nil?

      metadata.send(to)
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

    def normalize_orcid(orcid)
      orcid = validate_orcid(orcid)
      return nil unless orcid.present?

      # turn ORCID ID into URL
      "http://orcid.org/" + Addressable::URI.encode(orcid)
    end

    def normalize_ids(ids: nil, relation_type: "References")
      Array.wrap(ids).map do |id|
        { "id" => normalize_id(id["@id"]),
          "type" => id["@type"],
          "name" => id["name"],
          "relationType" => relation_type,
          "resourceTypeGeneral" => id["resourceTypeGeneral"] || Metadata::SO_TO_DC_TRANSLATIONS[id["@type"]] }.compact
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
      Array.wrap(element).map do |a|
        a["@type"] = a["type"]
        a["@id"] = a["id"]
        a.except("type", "id").compact
      end.unwrap
    end

    def from_schema_org(element)
      Array.wrap(element).map do |a|
        a["type"] = a["@type"]
        a["id"] = a["@id"]
        a.except("@type", "@id").compact
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
      end.unwrap
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
  end
end
