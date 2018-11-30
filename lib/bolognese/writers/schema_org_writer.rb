# frozen_string_literal: true

module Bolognese
  module Writers
    module SchemaOrgWriter
      def schema_hsh
        { "@context" => identifier.present? ? "http://schema.org" : nil,
          "@type" => types["schemaOrg"],
          "@id" => identifier,
          "identifier" => to_schema_org_identifier(identifier, alternate_identifiers: alternate_identifiers),
          "url" => url,
          "additionalType" => types["resourceType"],
          "name" => parse_attributes(titles, content: "title", first: true),
          "author" => to_schema_org(creators),
          "editor" => to_schema_org(contributors),
          "description" => parse_attributes(descriptions, content: "description", first: true),
          "license" => Array.wrap(rights_list).map { |l| l["rightsUri"] }.compact.unwrap,
          "version" => version_info,
          "keywords" => subjects.present? ? Array.wrap(subjects).map { |k| parse_attributes(k, content: "subject", first: true) }.join(", ") : nil,
          "inLanguage" => language,
          "contentSize" => Array.wrap(sizes).unwrap,
          "encodingFormat" => Array.wrap(formats).unwrap,
          "dateCreated" => get_date(dates, "Created"),
          "datePublished" => get_date(dates, "Issued"),
          "dateModified" => get_date(dates, "Updated"),
          "pageStart" => first_page,
          "pageEnd" => last_page,
          "spatialCoverage" => to_schema_org_spatial_coverage(geo_locations),
          "sameAs" => to_schema_org_relation(related_identifiers: related_identifiers, relation_type: "IsIdenticalTo"),
          "isPartOf" => to_schema_org_relation(related_identifiers: related_identifiers, relation_type: "IsPartOf"),
          "hasPart" => to_schema_org_relation(related_identifiers: related_identifiers, relation_type: "HasPart"),
          "predecessor_of" => to_schema_org_relation(related_identifiers: related_identifiers, relation_type: "IsPreviousVersionOf"),
          "successor_of" => to_schema_org_relation(related_identifiers: related_identifiers, relation_type: "IsNewVersionOf"),
          "citation" => to_schema_org_relation(related_identifiers: related_identifiers, relation_type: "References"),
          "@reverse" => reverse.presence,
          "contentUrl" => Array.wrap(content_url).unwrap,
          "schemaVersion" => schema_version,
          "periodical" => (types["schemaOrg"] != "Dataset") && periodical ? to_schema_org(periodical) : nil,
          "includedInDataCatalog" => (types["schemaOrg"] == "Dataset") && periodical ? to_schema_org(periodical) : nil,
          "publisher" => publisher.present? ? { "@type" => "Organization", "name" => publisher } : nil,
          "funder" => to_schema_org_funder(funding_references),
          "provider" => agency.present? ? { "@type" => "Organization", "name" => agency } : nil
        }.compact.presence
      end

      def schema_org
        JSON.pretty_generate schema_hsh
      end
    end
  end
end
