# frozen_string_literal: true

module Bolognese
  module Writers
    module RisWriter
      def ris
        {
          "TY" => types["ris"],
          "T1" => parse_attributes(titles, content: "title", first: true),
          "T2" => container && container["title"],
          "AU" => to_ris(creators),
          "DO" => doi,
          "UR" => url,
          "AB" => parse_attributes(abstract_description, content: "description", first: true),
          "KW" => Array.wrap(subjects).map { |k| parse_attributes(k, content: "subject", first: true) }.presence,
          "PY" => publication_year,
          "PB" => publisher,
          "LA" => language,
          "VL" => container.to_h["volume"],
          "IS" => container.to_h["issue"],
          "SP" => container.to_h["firstPage"],
          "EP" => container.to_h["lastPage"],
          "SN" => Array.wrap(related_identifiers).find { |ri| ri["relationType"] == "IsPartOf" }.to_h.fetch("relatedIdentifier", nil),
          "ER" => ""
        }.compact.map { |k, v| v.is_a?(Array) ? v.map { |vi| "#{k}  - #{vi}" }.join("\r\n") : "#{k}  - #{v}" }.join("\r\n")
      end
    end
  end
end
