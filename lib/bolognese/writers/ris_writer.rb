module Bolognese
  module Writers
    module RisWriter
      def ris
        {
          "TY" => ris_type,
          "T1" => parse_attributes(title, content: "text", first: true),
          "T2" => container_title,
          "AU" => to_ris(author),
          "DO" => doi,
          "UR" => b_url,
          "AB" => parse_attributes(description, content: "text", first: true),
          "KW" => parse_attributes(keywords, content: "text").presence,
          "PY" => publication_year,
          "PB" => publisher,
          "AN" => parse_attributes(alternate_name, content: "name").presence,
          "LA" => language,
          "VL" => volume,
          "IS" => issue,
          "SP" => first_page,
          "EP" => last_page,
          "ER" => ""
        }.compact.map { |k, v| v.is_a?(Array) ? v.map { |vi| "#{k} - #{vi}" }.join("\r\n") : "#{k} - #{v}" }.join("\r\n")
      end
    end
  end
end
