module Bolognese
  module Writers
    module TurtleWriter
      def turtle
        return nil unless valid?
        
        graph.dump(:ttl, prefixes: { schema: "http://schema.org/" })
      end
    end
  end
end
