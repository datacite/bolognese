module Bolognese
  module Writers
    module CiteprocWriter
      def citeproc
        return nil unless valid?

        abstract = if description.is_a?(Hash)
          description.fetch("text", nil)
        elsif description.is_a?(Array)
          description.first.fetch("text", nil)
        else
          description
        end

        hsh = {
          "type" => citeproc_type,
          "id" => id,
          "categories" => keywords.present? ? keywords.split(", ") : nil,
          "language" => language,
          "author" => to_citeproc(author),
          "editor" => to_citeproc(editor),
          "issued" => get_date_parts(date_published),
          "submitted" => get_date_parts(date_submitted),
          "abstract" => abstract,
          "container-title" => container_title,
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
    end
  end
end
