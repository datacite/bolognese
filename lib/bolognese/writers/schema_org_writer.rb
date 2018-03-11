module Bolognese
  module Writers
    module SchemaOrgWriter
      def schema_hsh
        { "@context" => identifier.present? ? "http://schema.org" : nil,
          "@type" => type,
          "@id" => identifier,
          "identifier" => identifier,
          "url" => url,
          "additionalType" => additional_type,
          "name" => parse_attributes(title, content: "text", first: true),
          "alternateName" => parse_attributes(alternate_name, content: "name", first: true),
          "author" => to_schema_org(author),
          "editor" => to_schema_org(editor),
          "description" => parse_attributes(description, content: "text", first: true),
          "license" => Array.wrap(license).map { |l| l["id"] }.compact.unwrap,
          "version" => version,
          "keywords" => Array.wrap(keywords).join(", ").presence,
          "inLanguage" => language,
          "contentSize" => content_size,
          "dateCreated" => date_created,
          "datePublished" => date_published,
          "dateModified" => date_modified,
          "pageStart" => first_page,
          "pageEnd" => last_page,
          "spatialCoverage" => spatial_coverage,
          "sameAs" => to_schema_org(is_identical_to),
          "isPartOf" => to_schema_org(is_part_of),
          "hasPart" => to_schema_org(has_part),
          "predecessor_of" => to_schema_org(is_previous_version_of),
          "successor_of" => to_schema_org(is_new_version_of),
          "citation" => to_schema_org(references),
          "@reverse" => reverse.presence,
          "schemaVersion" => schema_version,
          "publisher" => publisher.present? ? { "@type" => "Organization", "name" => publisher } : nil,
          "funding" => to_schema_org(funding),
          "provider" => provider.present? ? { "@type" => "Organization", "name" => provider } : nil
        }.compact.presence
      end

      def schema_org
        JSON.pretty_generate schema_hsh
      end
    end
  end
end
