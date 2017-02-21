require 'namae'

module Bolognese
  module AuthorUtils
    # only assume personal name when using sort-order: "Turing, Alan"
    def get_one_author(author)
      orcid = get_name_identifier(author)
      author = author.fetch("creatorName", nil)

      return { "Name" => "" } if author.to_s.strip.blank?

      author = cleanup_author(author)
      names = Namae.parse(author)

      if names.blank? || !is_personal_name?(author)
        { "@type" => "Agent",
          "@id" => orcid,
          "Name" => author }.compact
      else
        name = names.first

        { "@type" => "Person",
          "@id" => orcid,
          "givenName" => name.given,
          "familyName" => name.family }.compact
      end
    end

    def cleanup_author(author)
      # detect pattern "Smith J.", but not "Smith, John K."
      author = author.gsub(/[[:space:]]([A-Z]\.)?(-?[A-Z]\.)$/, ', \1\2') unless author.include?(",")

      # titleize strings
      # remove non-standard space characters
      author.my_titleize
            .gsub(/[[:space:]]/, ' ')
    end

    def is_personal_name?(author)
      return true if author.include?(",")

      # lookup given name
      #::NameDetector.name_exists?(author.split.first)
    end

    # parse array of author strings into CSL format
    def get_authors(authors)
      Array(authors).map { |author| get_one_author(author) }
    end

    # parse nameIdentifier from DataCite
    def get_name_identifier(author)
      name_identifier = author.dig("nameIdentifier", "__content__")
      name_identifier = validate_orcid(name_identifier)
      name_identifier_scheme = author.dig("nameIdentifier", "nameIdentifierScheme") || "ORCID"

      return nil if name_identifier.blank? || name_identifier_scheme.upcase != "ORCID"

      "http://orcid.org/" + name_identifier
    end
  end
end
