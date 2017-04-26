module Bolognese
  module Writers
    module CiteprocWriter
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
    end
  end
end
