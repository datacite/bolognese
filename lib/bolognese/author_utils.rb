require 'namae'

module Bolognese
  module AuthorUtils
    def get_one_author(author)
      type = author.fetch("type", nil) && author.fetch("type").titleize
      id = author.fetch("id", nil).presence || get_name_identifier(author)
      name = author.fetch("creatorName", nil) ||
             author.fetch("contributorName", nil) ||
             author.fetch("name", nil)

      if name.include?("; ")
        authors = name.split("; ").map do |name|
          { "type" => author.fetch("type", nil),
            "id" => author.fetch("id", nil),
            "name" => name }.compact
        end
        return get_authors(authors)
      end

      name = cleanup_author(name)
      given_name = author.fetch("givenName", nil)
      family_name = author.fetch("familyName", nil)

      author = { "type" => type || "Person",
                 "id" => id,
                 "name" => name,
                 "givenName" => given_name,
                 "familyName" => family_name }.compact

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
          "familyName" => family_name }.compact
      else
        { "type" => type, "name" => name }.compact
      end
    end

    def cleanup_author(author)
      # detect pattern "Smith J.", but not "Smith, John K."
      author = author.gsub(/[[:space:]]([A-Z]\.)?(-?[A-Z]\.)$/, ', \1\2') unless author.include?(",")

      # remove spaces around hyphens
      author = author.gsub(" - ", "-")

      # remove text in parentheses
      author = author.sub(/\s*\(.+\)$/, '')

      # titleize strings
      # remove non-standard space characters
      author.my_titleize
            .gsub(/[[:space:]]/, ' ')
    end

    def is_personal_name?(author)
      return false if author.fetch("type", "").downcase == "organization"
      return true if author.fetch("id", "").start_with?("http://orcid.org") ||
                     author.fetch("familyName", "").present? ||
                     (author.fetch("name", "").include?(",") &&
                     author.fetch("name", "").exclude?(";")) ||
                     name_detector.name_exists?(author.fetch("name", "").split(" ").first)
      false
    end

    # parse array of author strings into CSL format
    def get_authors(authors)
      Array.wrap(authors).map { |author| get_one_author(author) }.unwrap
    end

    # parse nameIdentifier from DataCite
    def get_name_identifier(author)
      name_identifier_scheme_uri = author.dig("nameIdentifier", "schemeURI") || "http://orcid.org/"
      name_identifier_scheme_uri << '/' unless name_identifier_scheme_uri.end_with?('/')

      name_identifier = author.dig("nameIdentifier", "__content__")
      name_identifier = validate_orcid(name_identifier) if name_identifier_scheme_uri == "http://orcid.org/"
      return nil if name_identifier.blank? || name_identifier_scheme_uri.blank?

      name_identifier_scheme_uri + name_identifier
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
