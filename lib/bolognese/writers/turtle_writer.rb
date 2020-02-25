# frozen_string_literal: true

require "json/ld"

module Bolognese
  module Writers
    module TurtleWriter
      # preload schema_org context
      JSON::LD::Context.add_preloaded(
        'http://schema.org/',
        JSON::LD::Context.new.parse('resources/schema_org/jsonldcontext.json')
      )

      def turtle
        graph.dump(:ttl, prefixes: { schema: "http://schema.org/" })
      end
    end
  end
end
