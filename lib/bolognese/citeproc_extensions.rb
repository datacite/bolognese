# frozen_string_literal: true

# Minimal patch for csl-ruby and citeproc-ruby compatibility  
module CiteProc
  class Variable
    # Fix for: undefined method 'take' for an instance of CiteProc::Variable
    # https://github.com/inukshuk/csl-ruby/blob/b2131c0ce832f332c3db3c49fd2baf7e41ac0aa6/lib/csl/style/names.rb#L98
    def take(n)
      # If @value is Enumerable (like CiteProc::Names), use it directly
      return @value.take(n) if @value.is_a?(Enumerable)
      
      # Otherwise, @value should be a String; delegate to it via to_s
      to_s.chars.take(n).join
    end

    # Fix for: undefined method '[]' for an instance of CiteProc::Variable
    # Used in citeproc-ruby when accessing names[-1] or names[0...-1]
    # https://github.com/inukshuk/citeproc-ruby/blob/2d6313cbb58d884dbfbccfb6f4a169d8d7c1b6fa/lib/citeproc/ruby/renderer/names.rb#L198
    def [](index)
      # If @value responds to [] (like CiteProc::Names or Array), use it
      return @value[index] if @value.respond_to?(:[])
      
      # Otherwise treat as string
      to_s[index]
    end

    # Fix for: undefined method 'length' for an instance of CiteProc::Variable
    # Used to check array size in citeproc-ruby
    def length
      # If @value responds to length (like CiteProc::Names or Array), use it
      return @value.length if @value.respond_to?(:length)
      
      # Otherwise return string length
      to_s.length
    end
    
    # Fix for: undefined method 'map' for an instance of CiteProc::Variable
    # Used in citeproc-ruby when iterating over names
    def map(&block)
      # If @value is Enumerable (like CiteProc::Names), use it
      return @value.map(&block) if @value.is_a?(Enumerable)
      
      # Otherwise treat as string and map over characters
      to_s.chars.map(&block)
    end
  end
end

# Fix for: undefined method 'personal?' for an instance of String
# https://github.com/inukshuk/citeproc-ruby/blob/2d6313cbb58d884dbfbccfb6f4a169d8d7c1b6fa/lib/citeproc/ruby/renderer/names.rb#L231
class String
  def personal?
    false
  end
  
  def literal?
    true
  end
  
  # Fix for: private method 'format' called for an instance of String
  # When a String is used as a name, it needs to return itself as formatted output
  def format
    self
  end
end

