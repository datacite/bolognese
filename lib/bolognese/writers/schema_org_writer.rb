# frozen_string_literal: true

module Bolognese
  module Writers
    module SchemaOrgWriter
      def schema_hsh
        { "@context" => identifier.present? ? "http://schema.org" : nil,
          "@type" => type,
          "@id" => identifier,
          "identifier" => to_schema_org_identifier(identifier, alternate_identifier: alternate_identifier),
          "url" => b_url,
          "additionalType" => additional_type,
          "name" => parse_attributes(title, content: "text", first: true),
          "author" => to_schema_org(author),
          "editor" => to_schema_org(editor),
          "description" => parse_attributes(description, content: "text", first: true),
          "license" => Array.wrap(license).map { |l| l["id"] }.compact.unwrap,
          "version" => b_version,
          "keywords" => keywords.present? ? Array.wrap(keywords).map { |k| parse_attributes(k, content: "text", first: true) }.join(", ") : nil,
          "inLanguage" => language,
          "contentSize" => content_size,
          "encodingFormat" => content_format,
          "dateCreated" => date_created,
          "datePublished" => date_published,
          "dateModified" => date_modified,
          "pageStart" => first_page,
          "pageEnd" => last_page,
          "spatialCoverage" => spatial_coverage,
          "sameAs" => to_schema_org(is_identical_to),
          "isPartOf" => (type == "Dataset") ? nil : to_schema_org_container(is_part_of, container_title: container_title, type: type),
          "hasPart" => to_schema_org(has_part),
          "predecessor_of" => to_schema_org(is_previous_version_of),
          "successor_of" => to_schema_org(is_new_version_of),
          "citation" => to_schema_org(references),
          "@reverse" => reverse.presence,
          "contentUrl" => content_url,
          "schemaVersion" => schema_version,
          "includedInDataCatalog" => (type == "Dataset") ? to_schema_org_container(is_part_of, container_title: container_title, type: type) : nil,
          "publisher" => publisher.present? ? { "@type" => "Organization", "name" => publisher } : nil,
          "funding" => to_schema_org(funding),
          "provider" => service_provider.present? ? { "@type" => "Organization", "name" => service_provider } : nil
        }.compact.presence
      end

      def schema_org
        JSON.pretty_generate schema_hsh
      end
    end
  end
end
