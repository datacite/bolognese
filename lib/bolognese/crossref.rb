module Bolognese
  module Crossref
    def initialize(id:, service:, **options)
      @id = doi_as_url(id)
      @service = service

      response = Maremma.get(id, options.merge(accept: "application/vnd.crossref.unixref+xml", host: true))
    end


    # def get_crossref_metadata(doi, options = {})
    #   return { "error" => "No DOI provided." } if doi.blank?

    #   id = doi_as_url(doi)
    #   response = Maremma.get(id, options.merge(accept: "application/vnd.crossref.unixref+xml", host: true))
    #   response.body.fetch("errors", nil) if response.body.fetch("errors", nil).present?

    #   metadata = response.body.fetch("data", {}).fetch("doi_records", {}).fetch("doi_record", nil)
    #   return { "error" => "Resource not found." } if metadata.blank?

    #   if metadata.dig("crossref", "journal").present?
    #     type_key = metadata.dig("crossref", "journal").keys.last
    #   else
    #     puts metadata.dig("crossref")
    #     type_key = metadata.dig("crossref").keys.last
    #   end

    #   journal_meta = metadata.dig("crossref", "journal", "journal_metadata")
    #   if journal_meta.present?
    #     is_part_of = {
    #       "@type" => "Periodical",
    #       "name" => journal_meta["full_title"],
    #       "issn" => journal_meta["issn"] }
    #   else
    #     is_part_of = nil
    #   end

    #   pub_date = metadata.dig("crossref", "journal", type_key, "publication_date")
    #   if pub_date.present?
    #     date_published = get_date_from_parts(pub_date["year"], pub_date["month"], pub_date["day"])
    #   else
    #     date_published = nil
    #   end

    #   title = metadata.dig("crossref", "journal", type_key, "titles", "title")
    #   if title.is_a?(String)
    #     name = title
    #   elsif title.is_a?(Array)
    #     name = title.first
    #   else
    #     name = nil
    #   end

    #   author = metadata.dig("crossref", "journal", type_key, "contributors", "person_name")
    #   author = Array(author).select { |a| a["contributor_role"] == "author" }.map do |a|
    #     { "@type" => "Person",
    #       "@id" => a["ORCID"],
    #       "givenName" => a["given_name"],
    #       "familyName" => a["surname"] }.compact
    #   end

    #   date_modified = Time.parse(metadata.fetch("timestamp", "")).utc.iso8601

    #   provider = {
    #     "@type" => "Organization",
    #     "name" => "Crossref" }

    #   type = Bolognese::Metadata::CROSSREF_TYPE_TRANSLATIONS[type_key.dasherize] || "CreativeWork"


    def schema_org
      { "@context" => "http://schema.org",
        "@type" => type,
        "@id" => id,
        "name" => name,
        "author" => author,
        "datePublished" => date_published,
        "dateModified" => date_modified,
        "isPartOf" => is_part_of,
        "provider" => provider
      }.compact
    end
  end
end
