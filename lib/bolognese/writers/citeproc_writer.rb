module Bolognese
  module Writers
    module CiteprocWriter
      def citeproc
        hsh = {
          "type" => citeproc_type,
          "id" => id,
          "categories" => parse_attributes(keywords, content: "text"),
          "language" => language,
          "author" => to_citeproc(author),
          "editor" => to_citeproc(editor),
          "issued" => get_date_parts(date_published),
          "submitted" => get_date_parts(date_submitted),
          "abstract" => parse_attributes(description, content: "text", first: true),
          "container-title" => container_title,
          "DOI" => doi,
          "issue" => issue,
          "page" => pagination,
          "publisher" => publisher,
          "title" => parse_attributes(title, content: "text", first: true),
          "URL" => url,
          "version" => version,
          "volume" => volume
        }.compact
        JSON.pretty_generate hsh.presence
      end
    end
  end
end
