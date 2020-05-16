# frozen_string_literal: true

module Bolognese
  module Writers
    module JatsWriter
      def jats
        @jats ||= Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
          xml.send("element-citation", publication_type) do
            insert_citation(xml)
          end
        end.to_xml
      end

      def insert_citation(xml)
        insert_authors(xml)
        insert_editors(xml)
        insert_citation_title(xml) if is_article? || is_data? || is_chapter?
        insert_source(xml)
        insert_publisher_name(xml) if publisher.present? && !is_data?
        insert_publication_date(xml)
        insert_volume(xml) if container.to_h["volume"].present?
        insert_issue(xml) if container.to_h["issue"].present?
        insert_fpage(xml) if container.to_h["firstPage"].present?
        insert_lpage(xml) if container.to_h["lastPage"].present?
        insert_version(xml) if version.present?
        insert_pub_id(xml)
      end

      def is_article?
        publication_type.fetch('publication-type', nil) == "journal"
      end

      def is_data?
        publication_type.fetch('publication-type', nil) == "data"
      end

      def is_chapter?
        publication_type.fetch('publication-type', nil) == "chapter"
      end

      def insert_authors(xml)
        if creators.present?
          xml.send("person-group", "person-group-type" => "author") do
            Array.wrap(creators).each do |au|
              xml.name do
                insert_contributor(xml, au)
              end
            end
          end
        end
      end

      def insert_editors(xml)
        if contributors.present?
          xml.send("person-group", "person-group-type" => "editor") do
            Array.wrap(contributors).each do |con|
              xml.name do
                insert_contributor(xml, con)
              end
            end
          end
        end
      end

      def insert_contributor(xml, person)
        xml.surname(person["familyName"]) if person["familyName"].present?
        xml.send("given-names", person["givenName"]) if person["givenName"].present?
      end

      def insert_citation_title(xml)
        case publication_type.fetch('publication-type', nil)
        when "data" then xml.send("data-title", parse_attributes(titles, content: "title", first: true))
        when "journal" then xml.send("article-title", parse_attributes(titles, content: "title", first: true))
        when "chapter" then xml.send("chapter-title", parse_attributes(titles, content: "title", first: true))
        end
      end

      def insert_source(xml)
        if is_article? || is_data? || is_chapter?
          xml.source(container && container["title"] || publisher)
        else
          xml.source(parse_attributes(titles, content: "title", first: true))
        end
      end

      def insert_publisher_name(xml)
        xml.send("publisher-name", publisher)
      end

      def insert_publication_date(xml)
        year, month, day = get_date_parts(get_date(dates, "Issued")).to_h.fetch("date-parts", []).first

        xml.year(year, "iso-8601-date" => get_date(dates, "Issued"))
        xml.month(month.to_s.rjust(2, '0')) if month.present?
        xml.day(day.to_s.rjust(2, '0')) if day.present?
      end

      def insert_volume(xml)
        xml.volume(container["volume"])
      end

      def insert_issue(xml)
        xml.issue(container["issue"])
      end

      def insert_fpage(xml)
        xml.fpage(container["firstPage"])
      end

      def insert_lpage(xml)
        xml.lpage(container["lastPage"])
      end

      def insert_version(xml)
        xml.version(version)
      end

      def insert_pub_id(xml)
        return nil unless doi.present?
        xml.send("pub-id", doi, "pub-id-type" => "doi")
      end

      def date
        get_date_parts(date_published)
      end

      def publication_type
        { 'publication-type' => Bolognese::Utils::CR_TO_JATS_TRANSLATIONS[types["resourceType"]] || Bolognese::Utils::SO_TO_JATS_TRANSLATIONS[types["schemaOrg"]] }.compact
      end
    end
  end
end
