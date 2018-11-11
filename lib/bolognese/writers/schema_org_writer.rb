# frozen_string_literal: true

module Bolognese
  module Writers
    module SchemaOrgWriter
      def schema_hsh
        { "@context" => identifier.present? ? "http://schema.org" : nil,
          "@type" => types["type"],
          "@id" => identifier,
          "identifier" => to_schema_org_identifier(identifier, alternate_identifiers: alternate_identifiers),
          "url" => url,
          "additionalType" => types["resource_type"],
          "name" => parse_attributes(title, content: "text", first: true),
          "author" => to_schema_org(creator),
          "editor" => to_schema_org(contributor),
          "description" => parse_attributes(description, content: "text", first: true),
          "license" => Array.wrap(rights).map { |l| l["id"] }.compact.unwrap,
          "version" => version,
          "keywords" => keywords.present? ? Array.wrap(keywords).map { |k| parse_attributes(k, content: "text", first: true) }.join(", ") : nil,
          "inLanguage" => language,
          "contentSize" => Array.wrap(size).unwrap,
          "encodingFormat" => Array.wrap(formats).unwrap,
          "dateCreated" => get_date(dates, "Created"),
          "datePublished" => get_date(dates, "Issued"),
          "dateModified" => get_date(dates, "Updated"),
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
          "contentUrl" => Array.wrap(content_url).unwrap,
          "schemaVersion" => schema_version,
          "periodical" => (types["type"] != "Dataset") && periodical ? to_schema_org(periodical) : nil,
          "includedInDataCatalog" => (types["type"] == "Dataset") && periodical ? to_schema_org(periodical) : nil,
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
