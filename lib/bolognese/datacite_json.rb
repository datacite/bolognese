module Bolognese
  class DataciteJson < Metadata

    def initialize(string: nil, regenerate: false)
      if string.present?
        @raw = string
      end
    end

    def metadata
      @metadata ||= raw.present? ? Maremma.from_json(raw) : {}
    end

    def valid?
      true
    end

    def datacite
      datacite_xml
    end

    def doi
      metadata.fetch("doi", nil)
    end

    def id
      metadata.fetch("id", nil)
    end

    def resource_type_general
      metadata.fetch("resource-type-general", nil)
    end

    def type
      DC_TO_SO_TRANSLATIONS[resource_type_general.to_s.dasherize] || "CreativeWork"
    end

    def additional_type
      metadata.fetch("resource-type", nil)
    end

    def bibtex_type
      Bolognese::Bibtex::SO_TO_BIB_TRANSLATIONS[type] || "misc"
    end

    def title
      metadata.fetch("title", nil)
    end

    def alternate_name
      metadata.fetch("alternate-identifier", nil)
    end

    def description
      metadata.fetch("description", nil)
    end

    def license
      metadata.fetch("license", nil)
    end

    def keywords
      metadata.fetch("subject", nil)
    end

    def author
      metadata.fetch("creator", nil)
    end

    def editor
      metadata.fetch("contributor", nil)
    end

    # def funder
    #   f = funder_contributor + funding_reference
    #   f.length > 1 ? f : f.first
    # end
    #
    # def funder_contributor
    #   Array.wrap(metadata.dig("contributors", "contributor")).reduce([]) do |sum, f|
    #     if f["contributorType"] == "Funder"
    #       sum << { "name" => f["contributorName"] }
    #     else
    #       sum
    #     end
    #   end
    # end
    #
    # def funding_reference
    #   Array.wrap(metadata.dig("fundingReferences", "fundingReference")).map do |f|
    #     funder_id = parse_attributes(f["funderIdentifier"])
    #     { "identifier" => normalize_id(funder_id),
    #       "name" => f["funderName"] }.compact
    #   end.uniq
    # end

    def version
      metadata.fetch("version", nil)
    end

    # def dates
    #   Array.wrap(metadata.dig("dates", "date"))
    # end
    #
    # #Accepted Available Copyrighted Collected Created Issued Submitted Updated Valid
    #
    # def date(date_type)
    #   dd = dates.find { |d| d["dateType"] == date_type } || {}
    #   dd.fetch("__content__", nil)
    # end

    def date_accepted
      metadata.fetch("date-accepted", nil)
    end

    def date_available
      metadata.fetch("date-available", nil)
    end

    def date_copyrighted
      metadata.fetch("date-copyrighted", nil)
    end

    def date_collected
      metadata.fetch("date-collected", nil)
    end

    def date_created
      metadata.fetch("date-created", nil)
    end

    # use datePublished for date issued
    def date_published
      metadata.fetch("date-published", nil)
    end

    def date_submitted
      metadata.fetch("date-submitted", nil)
    end

    # use dateModified for date updated
    def date_modified
      metadata.fetch("date-modified", nil)
    end

    def date_valid
      metadata.fetch("date-valid", nil)
    end

    def publication_year
      metadata.fetch("publication-year")
    end

    def language
      metadata.fetch("language", nil)
    end

    def spatial_coverage

    end

    def content_size
      metadata.fetch("size", nil)
    end

    def related_identifier
      metadata.fetch("related_identifier", nil)
    end

    def get_related_identifier(relation_type: nil)
      Array.wrap(related_identifier).select { |r| relation_type.split(" ").include?(r["relationType"]) }.unwrap
    end

    def is_identical_to
      get_related_identifier(relation_type: "IsIdenticalTo")
    end

    def is_part_of
      get_related_identifier(relation_type: "IsPartOf")
    end

    def has_part
      get_related_identifier(relation_type: "HasPart")
    end

    def is_previous_version_of
      get_related_identifier(relation_type: "IsPreviousVersionOf")
    end

    def is_new_version_of
      get_related_identifier(relation_type: "IsNewVersionOf")
    end

    def references
      get_related_identifier(relation_type: "Cites IsCitedBy Supplements IsSupplementTo References IsReferencedBy").presence
    end

    def publisher
      metadata.fetch("publisher")
    end

    alias_method :container_title, :publisher

    def provider
      "DataCite"
    end
  end
end
