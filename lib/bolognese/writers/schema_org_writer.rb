module Bolognese
  module Writers
    module SchemaOrgWriter
      def schema_hsh
        {
          "@context" => id.present? ? "http://schema.org" : nil,
          "@type" => type,
          "@id" => id,
          "url" => url,
          "additionalType" => additional_type,
          "name" => name,
          "alternateName" => alternate_name,
          "author" => to_schema_org(author),
          "editor" => editor,
          "description" => Array.wrap(description).map { |d| d["text"] }.unwrap,
          "license" => license.present? ? license["id"] : nil,
          "version" => version,
          "keywords" => keywords,
          "inLanguage" => language,
          "contentSize" => content_size,
          "dateCreated" => date_created,
          "datePublished" => date_published,
          "dateModified" => date_modified,
          "pagination" => pagination,
          "spatialCoverage" => spatial_coverage,
          "sameAs" => same_as,
          "isPartOf" => is_part_of,
          "hasPart" => has_part,
          "predecessor_of" => is_previous_version_of,
          "successor_of" => is_new_version_of,
          "citation" => Array.wrap(references).map { |r| r.except("relationType").merge("@type" => "CreativeWork") }.unwrap,
          "@reverse" => reverse.presence,
          "schemaVersion" => schema_version,
          "publisher" => publisher.present? ? { "@type" => "Organization", "name" => publisher } : nil,
          "funder" => funder,
          "provider" => provider.present? ? { "@type" => "Organization", "name" => provider } : nil
        }.compact.presence
      end

      def schema_org
        JSON.pretty_generate schema_hsh
      end
    end
  end
end
