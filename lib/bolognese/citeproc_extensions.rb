# frozen_string_literal: true

# Minimal patch for csl-ruby compatibility
module CiteProc
  class Variable
    # Fix for: undefined method 'take' for an instance of CiteProc::Variable
    # https://github.com/inukshuk/csl-ruby/blob/b2131c0ce832f332c3db3c49fd2baf7e41ac0aa6/lib/csl/style/names.rb#L98
    def take(n)
      val = @value
      array = case val
              when Array then val
              when nil then []
              else [val]
              end
      array.take(n)
    end
  end
end
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
    
    # CiteProc name type checking methods
    def personal?
      # Check if the value is a personal name (has family/given structure)
      val = @value
      return false if val.nil?
      return val.personal? if val.respond_to?(:personal?)
      # If it's a hash with family name, it's personal
      return true if val.is_a?(Hash) && val.key?('family')
      false
    end
    
    def literal?
      # Check if the value is a literal name (organization)
      val = @value
      return false if val.nil?
      return val.literal? if val.respond_to?(:literal?)
      # If it's a hash with literal key, it's literal
      return true if val.is_a?(Hash) && val.key?('literal')
      false
    end
  end
end
