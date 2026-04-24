# frozen_string_literal: true

# Ruby 4.0 compatibility patch for citeproc-ruby
module CiteProc
  class Variable
    # Add to_a method to convert Variable to array when needed
    def to_a
      val = @value
      case val
      when Array
        val
      when nil
        []
      else
        [val]
      end
    end
    
    # Delegate Enumerable methods that may not be properly forwarded in Ruby 4
    def take(n)
      to_a.take(n)
    end
    
    def first
      to_a.first
    end
    
    def last
      to_a.last
    end
    
    def empty?
      to_a.empty?
    end
    
    def size
      to_a.size
    end
    alias length size
    
    def each(&block)
      to_a.each(&block)
    end
    
    def map(&block)
      to_a.map(&block)
    end
    
    def select(&block)
      to_a.select(&block)
    end
  end
end
