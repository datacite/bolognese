# frozen_string_literal: true

module Bolognese
  module Writers
    module CodemetaWriter
      def codemeta
        return nil unless valid?

        hsh = {
          "@context" => id.present? ? "https://raw.githubusercontent.com/codemeta/codemeta/master/codemeta.jsonld" : nil,
          "@type" => types["type"],
          "@id" => identifier,
          "identifier" => identifier,
          "codeRepository" => url,
          "title" => parse_attributes(title, content: "text", first: true),
          "agents" => creator,
          "description" => parse_attributes(description, content: "text", first: true),
          "version" => version,
          "tags" => keywords.to_s.split(", ").presence,
          "datePublished" => get_date(dates, "Issued"),
          "dateModified" => get_date(dates, "Updated"),
          "publisher" => publisher
        }.compact
        JSON.pretty_generate hsh.presence
      end
    end
  end
end
