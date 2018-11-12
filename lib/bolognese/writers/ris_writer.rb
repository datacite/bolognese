# frozen_string_literal: true

module Bolognese
  module Writers
    module RisWriter
      def ris
        {
          "TY" => types["ris"],
          "T1" => parse_attributes(titles, content: "title", first: true),
          "T2" => periodical && periodical["title"],
          "AU" => to_ris(creator),
          "DO" => doi,
          "UR" => url,
          "AB" => parse_attributes(descriptions, content: "description", first: true),
          "KW" => Array.wrap(subjects).map { |k| parse_attributes(k, content: "subject", first: true) }.presence,
          "PY" => publication_year,
          "PB" => publisher,
          "LA" => language,
          "VL" => volume,
          "IS" => issue,
          "SP" => first_page,
          "EP" => last_page,
          "SN" => Array.wrap(related_identifiers).find { |ri| ri["relation_type"] == "IsPartOf" }.to_h.fetch("related_identifier", nil),
          "ER" => ""
        }.compact.map { |k, v| v.is_a?(Array) ? v.map { |vi| "#{k}  - #{vi}" }.join("\r\n") : "#{k}  - #{v}" }.join("\r\n")
      end
    end
  end
end
