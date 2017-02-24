module Bolognese
  module Utils

    def find_from_format(id: nil, string: nil, ext: nil, filename: nil)
      if id.present?
        find_from_format_by_id(id)
      elsif string.present?
        find_from_format_by_string(string, ext: ext, filename: filename)
      end
    end

    def find_from_format_by_id(id)
      id = normalize_id(id)

      if /\A(?:(http|https):\/\/(dx\.)?doi.org\/)?(doi:)?(10\.\d{4,5}\/.+)\z/.match(id)
        get_doi_ra(id).fetch("id", nil)
      elsif /\A(?:(http|https):\/\/orcid\.org\/)?(\d{4}-\d{4}-\d{4}-\d{3}[0-9X]+)\z/.match(id)
        "orcid"
      elsif /\A(http|https):\/\/github\.com\/(.+)\z/.match(id)
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
      elsif options[:ext] == ".xml" && Maremma.from_xml(string).dig("resource", "xmlns") == "http://datacite.org/schema/kernel-4"
        "datacite"
      elsif options[:filename] == "codemeta.json"
        "codemeta"
      end
    end

    def write(id: nil, string: nil, from: nil, to: nil, **options)
      if from.present?
        p = case from
            when "crossref" then Crossref.new(id: id, string: string)
            when "datacite" then Datacite.new(id: id, string: string, schema_version: options[:schema_version])
            when "codemeta" then Codemeta.new(id: id, string: string)
            when "bibtex" then Bibtex.new(string: string)
            else SchemaOrg.new(id: id)
            end

        puts p.send(to)
      else
        puts "not implemented"
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
      end
    end

    def parse_attributes(element, options={})
      content = options[:content] || "__content__"

      if element.is_a?(String)
        element
      elsif element.is_a?(Hash)
        element.fetch(content, nil)
      elsif element.is_a?(Array)
        a = element.map { |e| e.fetch(content, nil) }.uniq
        array_unwrap(a)
      else
        nil
      end
    end

    def array_unwrap(element)
      case element.length
      when 0 then nil
      when 1 then element.first
      else element
      end
    end

    def normalize_id(id)
      return nil unless id.present?

      normalize_doi(id) || Addressable::URI.parse(id).host && PostRank::URI.clean(id)
    end

    def normalize_orcid(orcid)
      orcid = validate_orcid(orcid)
      return nil unless orcid.present?

      # turn ORCID ID into URL
      "http://orcid.org/" + Addressable::URI.encode(orcid)
    end

    def normalize_ids(list)
      arr = Array.wrap(list).map { |url| url.merge("@id" => normalize_id(url["@id"])) }
      array_unwrap(arr)
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
  end
end
