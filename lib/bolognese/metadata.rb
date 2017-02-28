require_relative 'doi_utils'
require_relative 'author_utils'
require_relative 'date_utils'
require_relative 'datacite_utils'
require_relative 'utils'

module Bolognese
  class Metadata
    include Bolognese::DoiUtils
    include Bolognese::AuthorUtils
    include Bolognese::DateUtils
    include Bolognese::DataciteUtils
    include Bolognese::Utils

    attr_reader :id, :raw, :provider, :schema_version, :license, :citation,
      :additional_type, :alternate_name, :url, :version, :keywords, :editor,
      :page_start, :page_end, :date_modified, :language, :spatial_coverage,
      :content_size, :funder, :journal, :bibtex_type, :date_created, :has_part,
      :publisher, :contributor, :same_as, :predecessor_of, :successor_of,
      :should_passthru, :datacite_errors, :date_accepted, :date_available,
      :date_copyrighted, :date_collected, :date_submitted, :date_valid,
      :is_cited_by, :cites, :is_supplement_to, :is_supplemented_by,
      :is_continued_by, :continues, :has_metadata, :is_metadata_for,
      :is_referenced_by, :references, :is_documented_by, :documents,
      :is_compiled_by, :compiles, :is_variant_form_of, :is_original_form_of,
      :is_reviewed_by, :reviews, :is_derived_from, :is_source_of, :format

    def publication_year
      date_published && date_published[0..3]
    end

    def descriptions
      Array.wrap(description)
    end

    def pagination
      [page_start, page_end].compact.join("-").presence
    end

    def schema_org
      { "@context" => id.present? ? "http://schema.org" : nil,
        "@type" => type,
        "@id" => id,
        "url" => url,
        "additionalType" => additional_type,
        "name" => name,
        "alternateName" => alternate_name,
        "author" => author_to_schema_org(author),
        "editor" => editor,
        "description" => description,
        "license" => license,
        "version" => version,
        "keywords" => keywords,
        "language" => language,
        "contentSize" => content_size,
        "dateCreated" => date_created,
        "datePublished" => date_published,
        "dateModified" => date_modified,
        "pageStart" => page_start,
        "pageEnd" => page_end,
        "spatialCoverage" => spatial_coverage,
        "sameAs" => same_as,
        "isPartOf" => is_part_of,
        "hasPart" => has_part,
        "predecessor_of" => predecessor_of,
        "successor_of" => successor_of,
        "citation" => citation,
        "schemaVersion" => schema_version,
        "publisher" => { "@type" => "Organization", "name" => publisher },
        "funder" => funder,
        "provider" => { "@type" => "Organization", "name" => provider }
      }.compact.to_json
    end

    def datacite_json
      { "id" => id,
        "doi" => doi,
        "creator" => author,
        "title" => name,
        "publisher" => publisher,
        "publication-year" => publication_year,
        "resource-type-general" => resource_type_general,
        "resource-type" => additional_type,
        "subject" => keywords.split(", ").presence,
        "contributor" => contributor,
        "date-accepted" => date_accepted,
        "date-available" => date_available,
        "date-copyrighted" => date_copyrighted,
        "date-collected" => date_collected,
        "date-created" => date_created,
        "date-published" => date_published,
        "date-modified" => date_modified,
        "date-submitted" => date_submitted,
        "date-valid" => date_valid,
        "language" => language,
        "alternate-identifier" => alternate_name,
        "is-cited-by" => is_cited_by,
        "cites" => cites,
        "is-supplement-to" => is_supplement_to,
        "is-supplemented-by" => is_supplemented_by,
        "is-continued-by" => is_continued_by,
        "continues" => continues,
        "has-metadata" => has_metadata,
        "is-metadata-for" => is_metadata_for,
        "is-new-version-of" => successor_of,
        "is-previous-version-of" => predecessor_of,
        "is-part-of" => is_part_of,
        "has-part" => has_part,
        "is-referenced-by" => is_referenced_by,
        "references" => references,
        "is-documented-by" => is_documented_by,
        "documents" => documents,
        "is-compiled-by" => is_compiled_by,
        "compiles" => compiles,
        "is-variant-form-of" => is_variant_form_of,
        "is-original-form-of" => is_original_form_of,
        "is-identical-to" => same_as,
        "is-reviewed-by" => is_reviewed_by,
        "reviews" => reviews,
        "is-derived-from" => is_derived_from,
        "is-source-of" => is_source_of,
        "size" => content_size,
        "format" => format,
        "version" => version,
        "rights" => license,
        "description" => description,
        "geo-location" => spatial_coverage,
        "funding-reference" => funder,
        "schemaVersion" => schema_version,
        "provider" => provider
      }.compact.to_json
    end

    def codemeta
      { "@context" => id.present? ? "https://raw.githubusercontent.com/codemeta/codemeta/master/codemeta.jsonld" : nil,
        "@type" => type,
        "@id" => id,
        "identifier" => id,
        "codeRepository" => url,
        "title" => name,
        "agents" => author,
        "description" => description,
        "version" => version,
        "tags" => keywords.to_s.split(", ").presence,
        "dateCreated" => date_created,
        "datePublished" => date_published,
        "dateModified" => date_modified,
        "publisher" => publisher
      }.compact.to_json
    end

    def bibtex
      bib = {
        bibtex_type: bibtex_type.to_sym,
        bibtex_key: id,
        doi: doi,
        url: url,
        author: authors_as_string(author),
        keywords: keywords,
        language: language,
        title: name,
        journal: journal,
        pages: pagination,
        publisher: publisher,
        year: publication_year
      }.compact
      BibTeX::Entry.new(bib).to_s
    end
  end
end
