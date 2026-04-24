# frozen_string_literal: true

# Ruby 4.0 compatibility patch for citeproc-ruby
module CiteProc
  class Variable
    # Delegate Enumerable methods that may not be properly forwarded in Ruby 4
    def take(n)
      to_a.take(n)
    end
    
    def method_missing(method, *args, &block)
      if to_a.respond_to?(method)
        to_a.send(method, *args, &block)
      else
        super
      end
    end
    
    def respond_to_missing?(method, include_private = false)
      to_a.respond_to?(method, include_private) || super
    end
  end
end