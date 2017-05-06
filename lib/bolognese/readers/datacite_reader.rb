module Bolognese
  module Readers
    module DataciteReader
      def get_datacite(id: nil)
        return nil unless id.present?

        doi = doi_from_url(id)
        url = "https://search.datacite.org/api?q=doi:#{doi}&fl=doi,xml,media,minted,updated&wt=json"
        response = Maremma.get url
        attributes = response.body.dig("data", "response", "docs").first
        string = attributes.fetch('xml', "PGhzaD48L2hzaD4=\n")
        string = Base64.decode64(string)
        if string.present?
          doc = Nokogiri::XML(string, nil, 'UTF-8', &:noblanks)
          doc.to_s
        end
      end

      def read_datacite(string: nil)
        meta = string.present? ? Maremma.from_xml(string).fetch("resource", {}) : {}

        id = normalize_doi(meta.dig("identifier", "__content__"))
        doi = doi_from_url(id)
        resource_type_general = meta.dig("resourceType", "resourceTypeGeneral")
        type = Bolognese::Utils::DC_TO_SO_TRANSLATIONS[resource_type_general.to_s.dasherize] || "CreativeWork"
        title = Array.wrap(meta.dig("titles", "title")).map do |r|
          if r.is_a?(String)
            sanitize(r)
          else
            { "title_type" => r["titleType"], "lang" => r["xml:lang"], "text" => sanitize(r["__content__"]) }.compact
          end
        end.unwrap
        alternate_name = Array.wrap(meta.dig("alternateIdentifiers", "alternateIdentifier")).map do |r|
          { "type" => r["alternateIdentifierType"], "name" => r["__content__"] }.compact
        end.unwrap
        description = Array.wrap(meta.dig("descriptions", "description")).map do |r|
          { "type" => r["descriptionType"], "text" => sanitize(r["__content__"]) }.compact
        end.unwrap
        license = Array.wrap(meta.dig("rightsList", "rights")).map do |r|
          { "url" => r["rightsURI"], "name" => r["__content__"] }.compact
        end.unwrap
        keywords = Array.wrap(meta.dig("subjects", "subject")).map do |k|
          if k.is_a?(String)
            sanitize(k)
          else
            k.fetch("__content__", nil)
          end
        end.compact.join(", ").presence
        dates = Array.wrap(meta.dig("dates", "date"))
        funder = begin
          f = datacite_funder_contributor(meta) + datacite_funding_reference(meta)
          f.length > 1 ? f : f.first
        end

        { "id" => id,
          "type" => type,
          "additional_type" => meta.fetch("resourceType", {}).fetch("__content__", nil) ||
            meta.fetch("resourceType", {}).fetch("resourceTypeGeneral", nil),
          "citeproc_type" => Bolognese::Utils::DC_TO_CP_TRANSLATIONS[resource_type_general.to_s.dasherize] || "other",
          "bibtex_type" => Bolognese::Utils::SO_TO_BIB_TRANSLATIONS[type] || "misc",
          "ris_type" => Bolognese::Utils::DC_TO_RIS_TRANSLATIONS[resource_type_general.to_s.dasherize] || "GEN",
          "resource_type_general" => resource_type_general,
          "doi" => doi,
          "url" => nil,
          "title" => title,
          "alternate_name" => alternate_name,
          "author" => get_authors(meta.dig("creators", "creator")),
          "editor" => get_authors(Array.wrap(meta.dig("contributors", "contributor")).select { |r| r["contributorType"] == "Editor" }),
          "funder" => funder,
          "container_title" => meta.fetch("publisher", nil),
          "publisher" => meta.fetch("publisher", nil),
          "provider" => "DataCite",
          "is_identical_to" => datacite_is_identical_to(meta),
          "is_part_of" => datacite_is_part_of(meta),
          "has_part" => datacite_has_part(meta),
          "references" => datacite_references(meta),
          "is_referenced_by" => datacite_is_referenced_by(meta),
          "is_supplement_to" => datacite_is_supplement_to(meta),
          "is_supplemented_by" => datacite_is_supplemented_by(meta),
          "date_created" => datacite_date(dates, "Created"),
          "date_accepted" => datacite_date(dates, "Accepted"),
          "date_available" => datacite_date(dates, "Available"),
          "date_copyrighted" => datacite_date(dates, "Copyrightes"),
          "date_collected" => datacite_date(dates, "Collected"),
          "date_submitted" => datacite_date(dates, "Submitted"),
          "date_valid" => datacite_date(dates, "Valid"),
          "date_published" => datacite_date(dates, "Issued") || meta.fetch("publicationYear", nil),
          "date_modified" => datacite_date(dates, "Updated"),
          "description" => description,
          "license" => license,
          "version" => meta.fetch("version", nil),
          "keywords" => keywords,
          "language" => meta.fetch("language", nil),
          "content_size" => meta.fetch("size", nil),
          "schema_version" => meta.fetch("xmlns", nil)
        }
      end

      def datacite_date(dates, date_type)
        dd = dates.find { |d| d["dateType"] == date_type } || {}
        dd.fetch("__content__", nil)
      end

      def datacite_funding_reference(meta)
        Array.wrap(meta.dig("fundingReferences", "fundingReference")).map do |f|
          funder_id = parse_attributes(f["funderIdentifier"])
          { "identifier" => normalize_id(funder_id),
            "name" => f["funderName"] }.compact
        end.uniq
      end

      def datacite_related_identifier(meta, relation_type: nil)
        arr = Array.wrap(meta.dig("relatedIdentifiers", "relatedIdentifier")).select { |r| %w(DOI URL).include?(r["relatedIdentifierType"]) }
        arr = arr.select { |r| relation_type.split(" ").include?(r["relationType"]) } if relation_type.present?

        arr.map { |work| { "id" => normalize_id(work["__content__"]), "relationType" => work["relationType"] } }.unwrap
      end

      def datacite_is_identical_to(meta)
        datacite_related_identifier(meta, relation_type: "IsIdenticalTo")
      end

      def datacite_is_part_of(meta)
        datacite_related_identifier(meta, relation_type: "IsPartOf")
      end

      def datacite_has_part(meta)
        datacite_related_identifier(meta, relation_type: "HasPart")
      end

      def datacite_is_previous_version_of(meta)
        datacite_related_identifier(meta, relation_type: "IsPreviousVersionOf")
      end

      def datacite_is_new_version_of(meta)
        datacite_related_identifier(meta, relation_type: "IsNewVersionOf")
      end

      def datacite_is_variant_form_of(meta)
        datacite_related_identifier(meta, relation_type: "IsVariantFormOf")
      end

      def datacite_is_original_form_of(meta)
        datacite_related_identifier(meta, relation_type: "IsOriginalFormOf")
      end

      def datacite_references(meta)
        datacite_related_identifier(meta, relation_type: "References Cites").presence
      end

      def datacite_is_referenced_by(meta)
        datacite_related_identifier(meta, relation_type: "IsCitedBy IsReferencedBy").presence
      end

      def datacite_is_supplement_to(meta)
        datacite_related_identifier(meta, relation_type: "IsSupplementTo")
      end

      def datacite_is_supplemented_by(meta)
        datacite_related_identifier(meta, relation_type: "isSupplementedBy")
      end

      def datacite_reviews(meta)
        datacite_related_identifier(meta, relation_type: "Reviews").presence
      end

      def datacite_is_reviewed_by(meta)
        datacite_related_identifier(meta, relation_type: "IsReviewedBy").presence
      end

      def datacite_funder_contributor(meta)
        Array.wrap(meta.dig("contributors", "contributor")).reduce([]) do |sum, f|
          if f["contributorType"] == "Funder"
            sum << { "name" => f["contributorName"] }
          else
            sum
          end
        end
      end
    end
  end
end
