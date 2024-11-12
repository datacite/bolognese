# frozen_string_literal: true

module Bolognese
  module Writers
    module SchemaOrgWriter
      def schema_hsh
        { "@context" => "http://schema.org",
          "@type" => types.present? ? types["schemaOrg"] : nil,
          "@id" => normalize_doi(doi),
          "identifier" => to_schema_org_identifiers(identifiers),
          "url" => url,
          "additionalType" => types.present? ? types["resourceType"] : nil,
          "name" => parse_attributes(titles, content: "title", first: true),
          "author" => to_schema_org_creators(creators),
          "editor" => to_schema_org_contributors(contributors),
          "translator" => contributors ? to_schema_org_contributors(contributors.select { |c| c["contributorType"] == "Translator" }) : nil,
          "description" => parse_attributes(abstract_description, content: "description", first: true),
          "license" => Array.wrap(rights_list).map { |l| l["rightsUri"] }.compact.unwrap,
          "version" => version_info,
          "keywords" => subjects.present? ? Array.wrap(subjects).map { |k| parse_attributes(k, content: "subject", first: true) }.join(", ") : nil,
          "inLanguage" => language,
          "contentSize" => Array.wrap(sizes).unwrap,
          "encodingFormat" => Array.wrap(formats).unwrap,
          "dateCreated" => get_date(dates, "Created"),
          "datePublished" => get_date(dates, "Issued") || publication_year,
          "dateModified" => get_date(dates, "Updated"),
          "temporalCoverage" => get_date(dates, "Coverage"),
          "pageStart" => container.to_h["firstPage"],
          "pageEnd" => container.to_h["lastPage"],
          "spatialCoverage" => to_schema_org_spatial_coverage(geo_locations),
          "sameAs" => to_schema_org_relation(related_identifiers: related_identifiers, relation_type: "IsIdenticalTo"),
          "isPartOf" => to_schema_org_relation(related_identifiers: related_identifiers, relation_type: "IsPartOf"),
          "hasPart" => to_schema_org_relation(related_identifiers: related_identifiers, relation_type: "HasPart"),
          "predecessor_of" => to_schema_org_relation(related_identifiers: related_identifiers, relation_type: "IsPreviousVersionOf"),
          "successor_of" => to_schema_org_relation(related_identifiers: related_identifiers, relation_type: "IsNewVersionOf"),
          "citation" => to_schema_org_relation(related_identifiers: related_identifiers, relation_type: "References"),
          "workTranslation" => to_schema_org_relation(related_identifiers: related_identifiers, relation_type: "HasTranslation"),
          "translationOfWork" => to_schema_org_relation(related_identifiers: related_identifiers, relation_type: "IsTranslationOf"),
          "@reverse" => reverse.presence,
          "contentUrl" => Array.wrap(content_url).unwrap,
          "schemaVersion" => schema_version,
          "periodical" => types.present? ? ((types["schemaOrg"] != "Dataset") && container.present? ? to_schema_org(container) : nil) : nil,
          "includedInDataCatalog" => types.present? ? ((types["schemaOrg"] == "Dataset") && container.present? ? to_schema_org_container(container, type: "Dataset") : nil) : nil,
          "publisher" => publisher.present? ? { "@type" => "Organization", "@id" => publisher["publisherIdentifier"], "name" => publisher["name"] }.compact : nil,
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
