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
        insert_citation_title(xml)
        insert_source(xml)
        insert_publication_date(xml)
        insert_volume(xml) if volume.present?
        insert_issue(xml) if issue.present?
        insert_fpage(xml) if first_page.present?
        insert_lpage(xml) if last_page.present?
        insert_version(xml) if version.present?
        insert_pub_id(xml)
      end

      def insert_authors(xml)
        if author.present?
          xml.send("person-group", "person-group-type" => "author") do
            Array.wrap(author).each do |creator|
              xml.name do
                insert_contributor(xml, creator)
              end
            end
          end
        end
      end

      def insert_editors(xml)
        if editor.present?
          xml.send("person-group", "person-group-type" => "editor") do
            Array.wrap(editor).each do |creator|
              xml.name do
                insert_contributor(xml, creator)
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
        when "data" then xml.send("data-title", title)
        when "software" then xml.send("software-title", title)
        else
          xml.send("article-title", title)
        end
      end

      def insert_source(xml)
        xml.source(container_title || publisher)
      end

      def insert_publication_date(xml)
        year, month, day = get_date_parts(date_published).to_h.fetch("date-parts", []).first

        xml.year(year, "iso-8601-date" => date_published)
        xml.month(month.to_s.rjust(2, '0')) if month.present?
        xml.day(day.to_s.rjust(2, '0')) if day.present?
      end

      def insert_volume(xml)
        xml.volume(volume)
      end

      def insert_issue(xml)
        xml.issue(issue)
      end

      def insert_fpage(xml)
        xml.fpage(first_page)
      end

      def insert_lpage(xml)
        xml.lpage(last_page)
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
        { 'publication-type' => Bolognese::Utils::CR_TO_JATS_TRANSLATIONS[additional_type] || Bolognese::Utils::SO_TO_JATS_TRANSLATIONS[type] }.compact
      end
    end
  end
end
