module Bolognese
  class Datacite < Metadata

    SCHEMA = File.expand_path("../../../resources/kernel-4.0/metadata.xsd", __FILE__)

    def initialize(id: nil, string: nil, regenerate: false)
      id = normalize_doi(id) if id.present?

      if string.present?
        @raw = string
      elsif id.present?
        response = Maremma.get(id, accept: "application/vnd.datacite.datacite+xml", raw: true)
        @raw = response.body.fetch("data", nil)
        @raw = Nokogiri::XML(@raw, &:noblanks).to_s if @raw.present?
      end

      @should_passthru = !regenerate
    end

    # generate new DataCite XML version 4.0 if regenerate (!should_passthru) option is provided
    def datacite
      should_passthru ? raw : datacite_xml
    end

    def metadata
      @metadata ||= raw.present? ? Maremma.from_xml(raw).fetch("resource", {}) : {}
    end

    def exists?
      metadata.present?
    end

    def valid?
      datacite.present? && errors.blank?
    end

    def errors
      schema.validate(Nokogiri::XML(raw)).map { |error| error.to_s }.unwrap
    rescue Nokogiri::XML::SyntaxError => e
      e.message
    end

    def schema_version
      metadata.fetch("xmlns", nil)
    end

    def schema
      kernel = schema_version.split("/").last
      filepath = File.expand_path("../../../resources/#{kernel}/metadata.xsd", __FILE__)
      Nokogiri::XML::Schema(open(filepath))
    end

    def doi
      metadata.fetch("identifier", {}).fetch("__content__", nil)
    end

    def id
      normalize_doi(doi)
    end

    def resource_type_general
      metadata.dig("resourceType", "resourceTypeGeneral")
    end

    def type
      DC_TO_SO_TRANSLATIONS[resource_type_general.to_s.dasherize] || "CreativeWork"
    end

    def additional_type
      metadata.fetch("resourceType", {}).fetch("__content__", nil) ||
      metadata.fetch("resourceType", {}).fetch("resourceTypeGeneral", nil)
    end

    def bibtex_type
      Bolognese::Bibtex::SO_TO_BIB_TRANSLATIONS[type] || "misc"
    end

    def title
      metadata.dig("titles", "title")
    end

    def alternate_name
      Array.wrap(metadata.dig("alternateIdentifiers", "alternateIdentifier")).map do |r|
        { "type" => r["alternateIdentifierType"], "name" => r["__content__"] }.compact
      end.unwrap
    end

    def description
      Array.wrap(metadata.dig("descriptions", "description")).map do |r|
        { "type" => r["descriptionType"], "text" => sanitize(r["__content__"]) }.compact
      end.unwrap
    end

    def license
      Array.wrap(metadata.dig("rightsList", "rights")).map do |r|
        { "url" => r["rightsURI"], "name" => r["__content__"] }.compact
      end.unwrap
    end

    def keywords
      Array.wrap(metadata.dig("subjects", "subject")).join(", ").presence
    end

    def author
      get_authors(metadata.dig("creators", "creator"))
    end

    def editor
      get_authors(Array.wrap(metadata.dig("contributors", "contributor"))
                          .select { |r| r["contributorType"] == "Editor" })
    end

    def funder
      f = funder_contributor + funding_reference
      f.length > 1 ? f : f.first
    end

    def funder_contributor
      Array.wrap(metadata.dig("contributors", "contributor")).reduce([]) do |sum, f|
        if f["contributorType"] == "Funder"
          sum << { "name" => f["contributorName"] }
        else
          sum
        end
      end
    end

    def funding_reference
      Array.wrap(metadata.dig("fundingReferences", "fundingReference")).map do |f|
        funder_id = parse_attributes(f["funderIdentifier"])
        { "identifier" => normalize_id(funder_id),
          "name" => f["funderName"] }.compact
      end.uniq
    end

    def version
      metadata.fetch("version", nil)
    end

    def dates
      Array.wrap(metadata.dig("dates", "date"))
    end

    #Accepted Available Copyrighted Collected Created Issued Submitted Updated Valid

    def date(date_type)
      dd = dates.find { |d| d["dateType"] == date_type } || {}
      dd.fetch("__content__", nil)
    end

    def date_accepted
      date("Accepted")
    end

    def date_available
      date("Available")
    end

    def date_copyrighted
      date("Copyrighted")
    end

    def date_collected
      date("Collected")
    end

    def date_created
      date("Created")
    end

    # use datePublished for date issued
    def date_published
      date("Issued") || publication_year
    end

    def date_submitted
      date("Submitted")
    end

    # use dateModified for date updated
    def date_modified
      date("Updated")
    end

    def date_valid
      date("Valid")
    end

    def publication_year
      metadata.fetch("publicationYear")
    end

    def language
      metadata.fetch("language", nil)
    end

    def spatial_coverage

    end

    def content_size
      metadata.fetch("size", nil)
    end

    def related_identifier(relation_type: nil)
      arr = Array.wrap(metadata.dig("relatedIdentifiers", "relatedIdentifier")).select { |r| %w(DOI URL).include?(r["relatedIdentifierType"]) }
      arr = arr.select { |r| relation_type.split(" ").include?(r["relationType"]) } if relation_type.present?

      arr.map { |work| { "id" => normalize_id(work["__content__"]), "relationType" => work["relationType"] } }.unwrap
    end

    def is_identical_to
      related_identifier(relation_type: "IsIdenticalTo")
    end

    def is_part_of
      related_identifier(relation_type: "IsPartOf")
    end

    def has_part
      related_identifier(relation_type: "HasPart")
    end

    def is_previous_version_of
      related_identifier(relation_type: "IsPreviousVersionOf")
    end

    def is_new_version_of
      related_identifier(relation_type: "IsNewVersionOf")
    end

    def is_variant_form_of
      related_identifier(relation_type: "IsVariantFormOf")
    end

    def is_original_form_of
      related_identifier(relation_type: "IsOriginalFormOf")
    end

    def references
      related_identifier(relation_type: "References Cites").presence
    end

    def is_referenced_by
      related_identifier(relation_type: "IsCitedBy IsReferencedBy").presence
    end

    def is_supplement_to
      related_identifier(relation_type: "IsSupplementTo")
    end

    def is_supplemented_by
      get_related_identifier(relation_type: "isSupplementedBy")
    end

    def reviews
      related_identifier(relation_type: "Reviews").presence
    end

    def is_reviewed_by
      related_identifier(relation_type: "IsReviewedBy").presence
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
