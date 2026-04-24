# frozen_string_literal: true

# Minimal patch for csl-ruby and citeproc-ruby compatibility
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

