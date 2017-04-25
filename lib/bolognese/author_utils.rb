require 'namae'

module Bolognese
  module AuthorUtils
    # only assume personal name when using sort-order: "Turing, Alan"
    def get_one_author(author)
      type = author.fetch("type", nil) && author.fetch("type").titleize
      id = author.fetch("id", nil).presence || get_name_identifier(author)
      name = author.fetch("creatorName", nil) ||
             author.fetch("contributorName", nil) ||
             author.fetch("name", nil)

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

        { "type" => "Person",
          "id" => id,
          "name" => [parsed_name.given, parsed_name.family].join(" "),
          "givenName" => parsed_name.given,
          "familyName" => parsed_name.family }.compact
      else
        { "type" => type, "name" => name }.compact
      end
    end

    def cleanup_author(author)
      # detect pattern "Smith J.", but not "Smith, John K."
      author = author.gsub(/[[:space:]]([A-Z]\.)?(-?[A-Z]\.)$/, ', \1\2') unless author.include?(",")

      # remove spaces around hyphens
      author = author.gsub(" - ", "-")

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
      name_identifier = author.dig("nameIdentifier", "__content__")
      name_identifier = validate_orcid(name_identifier)
      name_identifier_scheme = author.dig("nameIdentifier", "nameIdentifierScheme") || "ORCID"

      return nil if name_identifier.blank? || name_identifier_scheme.upcase != "ORCID"

      "http://orcid.org/" + name_identifier
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
