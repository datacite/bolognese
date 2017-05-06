module Bolognese
  module Writers
    module RisWriter
      def ris
        {
          "TY" => ris_type,
          "T1" => title,
          "T2" => container_title,
          "AU" => to_ris(author),
          "DO" => doi,
          "UR" => url,
          "AB" => description.present? ? description["text"] : nil,
          "KW" => keywords.to_s.split(", ").presence,
          "PY" => publication_year,
          "PB" => publisher,
          "AN" => alternate_name.present? ? alternate_name["name"] : nil,
          "LA" => language,
          "VL" => volume,
          "IS" => issue,
          "SP" => pagination,
          "ER" => ""
        }.compact.map { |k, v| v.is_a?(Array) ? v.map { |vi| "#{k} - #{vi}" }.join("\r\n") : "#{k} - #{v}" }.join("\r\n")
      end
    end
  end
end
