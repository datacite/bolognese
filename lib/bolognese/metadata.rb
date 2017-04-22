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
      :publisher, :contributor, :same_as, :is_previous_version_of, :is_new_version_of,
      :should_passthru, :datacite_errors, :date_accepted, :date_available,
      :date_copyrighted, :date_collected, :date_submitted, :date_valid,
      :is_cited_by, :cites, :is_supplement_to, :is_supplemented_by,
      :is_continued_by, :continues, :has_metadata, :is_metadata_for,
      :is_referenced_by, :references, :is_documented_by, :documents,
      :is_compiled_by, :compiles, :is_variant_form_of, :is_original_form_of,
      :is_reviewed_by, :reviews, :is_derived_from, :is_source_of, :format,
      :related_identifier, :reverse, :citeproc_type, :ris_type, :volume, :issue

    def publication_year
      date_published && date_published[0..3]
    end

    def descriptions
      Array.wrap(description)
    end

    def pagination
      [page_start, page_end].compact.join("-").presence
    end

    def reverse
      { "citation" => Array.wrap(is_referenced_by).map { |r| { "@id" => r["id"] }}.unwrap,
        "isBasedOn" => Array.wrap(is_supplement_to).map { |r| { "@id" => r["id"] }}.unwrap }.compact
    end

    def schema_hsh
      {
        "@context" => id.present? ? "http://schema.org" : nil,
        "@type" => type,
        "@id" => id,
        "url" => url,
        "additionalType" => additional_type,
        "name" => title,
        "alternateName" => alternate_name,
        "author" => to_schema_org(author),
        "editor" => editor,
        "description" => Array.wrap(description).map { |d| d["text"] }.unwrap,
        "license" => license.present? ? license["id"] : nil,
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

    def graph
      RDF::Graph.new << JSON::LD::API.toRdf(schema_hsh)
    end

    def turtle
      graph.dump(:ttl, prefixes: { schema: "http://schema.org/" })
    end

    def rdf_xml
      graph.dump(:rdfxml, prefixes: { schema: "http://schema.org/" })
    end

    def datacite_json
      hsh = {
        "id" => id,
        "doi" => doi,
        "creator" => author,
        "title" => title,
        "publisher" => publisher,
        "publication-year" => publication_year,
        "resource-type-general" => resource_type_general,
        "resource-type" => additional_type,
        "subject" => keywords.present? ? keywords.split(", ") : nil,
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
        "related_identifier" => related_identifier,
        "size" => content_size,
        "format" => format,
        "version" => version,
        "rights" => license,
        "description" => description,
        "geo-location" => spatial_coverage,
        "funding-reference" => funder,
        "schemaVersion" => schema_version,
        "provider" => provider
      }.compact
      JSON.pretty_generate hsh.presence
    end

    def citeproc
      hsh = {
        "type" => citeproc_type,
        "id" => id,
        "categories" => keywords.present? ? keywords.split(", ") : nil,
        "language" => language,
        "author" => to_citeproc(author),
        "editor" => to_citeproc(editor),
        "issued" => get_date_parts(date_published),
        "submitted" => get_date_parts(date_submitted),
        "abstract" => description.is_a?(Hash) ? description.fetch("text", nil) : description,
        "container-title" => journal,
        "DOI" => doi,
        "issue" => issue,
        "page" => pagination,
        "publisher" => publisher,
        "title" => title,
        "URL" => url,
        "version" => version,
        "volume" => volume
      }.compact
      JSON.pretty_generate hsh.presence
    end

    def codemeta
      hsh = {
        "@context" => id.present? ? "https://raw.githubusercontent.com/codemeta/codemeta/master/codemeta.jsonld" : nil,
        "@type" => type,
        "@id" => id,
        "identifier" => id,
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

    def bibtex
      bib = {
        bibtex_type: bibtex_type.present? ? bibtex_type.to_sym : "misc",
        bibtex_key: id,
        doi: doi,
        url: url,
        author: authors_as_string(author),
        keywords: keywords,
        language: language,
        title: title,
        journal: journal,
        pages: pagination,
        publisher: publisher,
        year: publication_year
      }.compact
      BibTeX::Entry.new(bib).to_s
    end

    def ris
      {
        "TY" => ris_type,
        "T1" => title,
        "T2" => container_title,
        "AU" => to_ris(author),
        "DO" => doi,
        "UR" => url,
        "AB" => description.present? ? description["text"] : nil,
        "KW" => keywords.to_s.split(", ").presence,
        "PY" => publication_year,
        "PB" => publisher,
        "AN" => alternate_name.present? ? alternate_name["name"] : nil,
        "LA" => language,
        "VL" => volume,
        "IS" => issue,
        "SP" => pagination,
        "ER" => ""
      }.compact.map { |k, v| v.is_a?(Array) ? v.map { |vi| "#{k} - #{vi}" }.join("\r\n") : "#{k} - #{v}" }.join("\r\n")
    end
  end
end
