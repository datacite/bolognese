require 'namae'

module Bolognese
  module AuthorUtils
    # include BenchmarkMethods
    #
    # benchmark :get_authors

    IDENTIFIER_SCHEME_URIS = {
      "ORCID" => "http://orcid.org/"
    }

    def get_one_author(author)
      if author.fetch("creatorName", nil).is_a?(Array)
        # malformed XML
        return nil
      elsif author.fetch("type", nil).present?
        type = author.fetch("type").titleize
      elsif author.fetch("creatorName", nil).is_a?(Hash)
        type = author.dig("creatorName", "nameType") == "Organizational" ? "Organization" : "Person"
      else
        type = nil
      end

      name_identifiers = get_name_identifiers(author)
      id = author.fetch("id", nil).presence || name_identifiers.first
      identifier = name_identifiers.length > 1 ? name_identifiers.unwrap : nil
      name = parse_attributes(author.fetch("creatorName", nil)) ||
             parse_attributes(author.fetch("contributorName", nil)) ||
             author.fetch("name", nil)

      given_name = author.fetch("givenName", nil)
      family_name = author.fetch("familyName", nil)
      name = cleanup_author(name)
      name = [family_name, given_name].join(", ") if name.blank? && family_name.present?

      author = { "type" => type || "Person",
                 "id" => id,
                 "name" => name,
                 "givenName" => given_name,
                 "familyName" => family_name,
                 "identifier" => identifier }.compact

      return author if family_name.present?

      if is_personal_name?(author)
        names = Namae.parse(name)
        parsed_name = names.first

        if parsed_name.present?
          given_name = parsed_name.given
          family_name = parsed_name.family
          name = [given_name, family_name].join(" ")
        else
          given_name = nil
          family_name = nil
        end

        { "type" => "Person",
          "id" => id,
          "name" => name,
          "givenName" => given_name,
          "familyName" => family_name,
          "identifier" => identifier }.compact
      else
        { "type" => type, "name" => name }.compact
      end
    end

    def cleanup_author(author)
      return nil unless author.present?

      # detect pattern "Smith J.", but not "Smith, John K."
      author = author.gsub(/[[:space:]]([A-Z]\.)?(-?[A-Z]\.)$/, ', \1\2') unless author.include?(",")

      # remove spaces around hyphens
      author = author.gsub(" - ", "-")

      # titleize strings
      # remove non-standard space characters
      author.my_titleize.gsub(/[[:space:]]/, ' ')
    end

    def is_personal_name?(author)
      return false if author.fetch("type", "").downcase == "organization"
      return true if author.fetch("id", "").start_with?("https://orcid.org") ||
                     author.fetch("familyName", "").present? ||
                     (author.fetch("name", "").include?(",") &&
                     author.fetch("name", "").exclude?(";")) ||
                     name_exists?(author.fetch("name", "").split(" ").first)
      false
    end

    # recognize given name if we have loaded ::NameDetector data, e.g. in a Rails initializer
    def name_exists?(name)
      return false unless name_detector.present?

      name_detector.name_exists?(name)
    end

    # parse array of author strings into CSL format
    def get_authors(authors)
      Array.wrap(authors).map { |author| get_one_author(author) }.unwrap
    end

    # parse nameIdentifier from DataCite
    def get_name_identifiers(author)
      name_identifiers = Array.wrap(author.fetch("nameIdentifier", nil)).reduce([]) do |sum, n|
        n = { "__content__" => n } if n.is_a?(String)

        scheme = n.fetch("nameIdentifierScheme", nil)
        scheme_uri = n.fetch("schemeURI", nil) || IDENTIFIER_SCHEME_URIS.fetch(scheme, "https://orcid.org")
        scheme_uri = "https://orcid.org/" if validate_orcid_scheme(scheme_uri)
        scheme_uri << '/' unless scheme_uri.present? && scheme_uri.end_with?('/')

        identifier = n.fetch("__content__", nil)
        if scheme_uri == "https://orcid.org/"
          identifier = validate_orcid(identifier)
        else
          identifier = identifier.gsub(" ", "-")
        end

        if identifier.present? && scheme_uri.present?
          sum << scheme_uri + identifier
        else
          sum
        end
      end

      # return array of name identifiers, ORCID ID is first element if multiple
      name_identifiers.select { |n| n.start_with?("https://orcid.org") } +
      name_identifiers.reject { |n| n.start_with?("https://orcid.org") }
    end

    def authors_as_string(authors)
      Array.wrap(authors).map do |a|
        if a["familyName"].present?
          [a["familyName"], a["givenName"]].join(", ")
        elsif a["type"] == "Person"
          a["name"]
        elsif a["name"].present?
          "{" + a["name"] + "}"
        end
      end.join(" and ").presence
    end
  end
end
