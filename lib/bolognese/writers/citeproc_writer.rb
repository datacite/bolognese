module Bolognese
  module Writers
    module CiteprocWriter
      def citeproc
        hsh = {
          "type" => citeproc_type,
          "id" => identifier,
          "categories" => Array.wrap(keywords).map { |k| parse_attributes(k, content: "text", first: true) }.presence,
          "language" => language,
          "author" => to_citeproc(author),
          "editor" => to_citeproc(editor),
          "issued" => date_published ? get_date_parts(date_published) : nil,
          "submitted" => date_submitted ? get_date_parts(date_submitted) : nil,
          "abstract" => parse_attributes(description, content: "text", first: true),
          "container-title" => container_title,
          "DOI" => doi,
          "issue" => issue,
          "page" => [first_page, last_page].compact.join("-").presence,
          "publisher" => publisher,
          "title" => parse_attributes(title, content: "text", first: true),
          "URL" => b_url,
          "version" => b_version,
          "volume" => volume
        }.compact
        JSON.pretty_generate hsh.presence
      end
    end
  end
end
