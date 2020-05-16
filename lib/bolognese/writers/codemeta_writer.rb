# frozen_string_literal: true

module Bolognese
  module Writers
    module CodemetaWriter
      def codemeta
        return nil unless valid? || show_errors
        
        hsh = {
          "@context" => id.present? ? "https://raw.githubusercontent.com/codemeta/codemeta/master/codemeta.jsonld" : nil,
          "@type" => types.present? ? types["schemaOrg"] : nil,
          "@id" => normalize_doi(doi),
          "identifier" => to_schema_org_identifiers(identifiers),
          "codeRepository" => url,
          "name" => parse_attributes(titles, content: "title", first: true),
          "authors" => creators,
          "description" => parse_attributes(descriptions, content: "description", first: true),
          "version" => version,
          "tags" => subjects.present? ? Array.wrap(subjects).map { |k| parse_attributes(k, content: "subject", first: true) } : nil,
          "datePublished" => get_date(dates, "Issued"),
          "dateModified" => get_date(dates, "Updated"),
          "publisher" => publisher
        }.compact
        JSON.pretty_generate hsh.presence
      end
    end
  end
end
