# frozen_string_literal: true

module Bolognese
  module Writers
    module RdfXmlWriter
      # preload schema_org context
      JSON::LD::Context.add_preloaded(
        'http://schema.org/',
        JSON::LD::Context.new.parse('resources/schema_org/jsonldcontext.json')
      )

      def rdf_xml
        graph.dump(:rdfxml, prefixes: { schema: "http://schema.org/" })
      end
    end
  end
end
