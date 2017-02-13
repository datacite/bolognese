module Bolognese
  module Crossref
    def get_crossref_metadata(doi, options = {})
      return {} if doi.blank?

      url = "https://api.crossref.org/works/" + PostRank::URI.escape(doi)
      response = Maremma.get(url, options.merge(host: true))

      metadata = response.body.fetch("data", {}).fetch("message", {})
      return { error: 'Resource not found.', status: 404 } if metadata.blank?

      # don't use these metadata
      metadata = metadata.except("URL", "update-policy")

      date_parts = metadata.fetch("issued", {}).fetch("date-parts", []).first

      # Don't set issued if date-parts are missing.
      if !date_parts.nil?
        year, month, day = date_parts[0], date_parts[1], date_parts[2]

        # set date published if date issued is in the future
        if year.nil? || Date.new(*date_parts) > Time.now.to_date
          metadata["issued"] = metadata.fetch("indexed", {}).fetch("date-time", nil)
          metadata["published"] = get_date_from_parts(year, month, day)
        else
          metadata["issued"] = get_date_from_parts(year, month, day)
          metadata["published"] = metadata["issued"]
        end
      # handle missing date issued, e.g. for components
      else
        metadata["issued"] = metadata.fetch("created", {}).fetch("date-time", nil)
        metadata["published"] = metadata["issued"]
      end

      metadata["deposited"] = metadata.fetch("deposited", {}).fetch("date-time", nil)
      metadata["updated"] = metadata.fetch("indexed", {}).fetch("date-time", nil)

      metadata["title"] = case metadata["title"].length
            when 0 then nil
            when 1 then metadata["title"][0]
            else metadata["title"][0].presence || metadata["title"][1]
            end

      if metadata["title"].blank? && !TYPES_WITH_TITLE.include?(metadata["type"])
        metadata["title"] = metadata["container-title"][0].presence || "(:unas)"
      end

      metadata["registration_agency_id"] = "crossref"
      metadata["publisher_id"] = metadata.fetch("member", "")[30..-1]
      metadata["container-title"] = metadata.fetch("container-title", [])[0]

      metadata["resource_type_id"] = "Text"
      metadata["resource_type"] = metadata["type"] if metadata["type"]
      metadata["author"] = metadata["author"].map { |author| author.except("affiliation") } if metadata["author"]

      metadata
    end
  end
end
