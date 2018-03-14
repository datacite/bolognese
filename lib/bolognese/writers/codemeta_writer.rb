module Bolognese
  module Writers
    module CodemetaWriter
      def codemeta
        return nil unless valid?

        hsh = {
          "@context" => id.present? ? "https://raw.githubusercontent.com/codemeta/codemeta/master/codemeta.jsonld" : nil,
          "@type" => type,
          "@id" => identifier,
          "identifier" => identifier,
          "codeRepository" => url,
          "title" => title,
          "agents" => author,
          "description" => description.present? ? description["text"] : nil,
          "version" => version,
          "tags" => keywords.to_s.split(", ").presence,
          "dateCreated" => date_created,
          "datePublished" => date_published,
          "dateModified" => date_modified,
          "publisher" => publisher
        }.compact
        JSON.pretty_generate hsh.presence
      end
    end
  end
end
