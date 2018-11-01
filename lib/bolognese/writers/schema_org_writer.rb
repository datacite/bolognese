# frozen_string_literal: true

module Bolognese
  module Writers
    module SchemaOrgWriter
      def schema_hsh
        { "@context" => identifier.present? ? "http://schema.org" : nil,
          "@type" => type,
          "@id" => identifier,
          "identifier" => to_schema_org_identifier(identifier, alternate_identifiers: alternate_identifiers),
          "url" => b_url,
          "additionalType" => additional_type,
          "name" => parse_attributes(title, content: "text", first: true),
          "author" => to_schema_org(creator),
          "editor" => to_schema_org(editor),
          "description" => parse_attributes(description, content: "text", first: true),
          "license" => Array.wrap(rights).map { |l| l["id"] }.compact.unwrap,
          "version" => b_version,
          "keywords" => keywords.present? ? Array.wrap(keywords).map { |k| parse_attributes(k, content: "text", first: true) }.join(", ") : nil,
          "inLanguage" => language,
          "contentSize" => size,
          "encodingFormat" => b_format,
          "dateCreated" => Array.wrap(dates).find { |d| d["type"] == "Created" }.to_h.fetch("__content__", nil),
          "datePublished" => date_published,
          "dateModified" => date_modified,
          "pageStart" => first_page,
          "pageEnd" => last_page,
          "spatialCoverage" => to_schema_org_spatial_coverage(geo_location),
          "sameAs" => to_schema_org_relation(related_identifiers: related_identifiers, relation_type: "IsIdenticalTo"),
          "isPartOf" => to_schema_org_relation(related_identifiers: related_identifiers, relation_type: "IsPartOf"),
          "hasPart" => to_schema_org_relation(related_identifiers: related_identifiers, relation_type: "HasPart"),
          "predecessor_of" => to_schema_org_relation(related_identifiers: related_identifiers, relation_type: "IsPreviousVersionOf"),
          "successor_of" => to_schema_org_relation(related_identifiers: related_identifiers, relation_type: "IsNewVersionOf"),
          "citation" => to_schema_org_relation(related_identifiers: related_identifiers, relation_type: "References"),
          "@reverse" => reverse.presence,
          "contentUrl" => content_url,
          "schemaVersion" => schema_version,
          "periodical" => (type != "Dataset") && periodical ? to_schema_org(periodical) : nil,
          "includedInDataCatalog" => (type == "Dataset") && periodical ? to_schema_org(periodical) : nil,
          "publisher" => publisher.present? ? { "@type" => "Organization", "name" => publisher } : nil,
          "funder" => to_schema_org_funder(funding_references),
          "provider" => service_provider.present? ? { "@type" => "Organization", "name" => service_provider } : nil
        }.compact.presence
      end

      def schema_org
        JSON.pretty_generate schema_hsh
      end
    end
  end
end
