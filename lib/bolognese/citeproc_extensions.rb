# frozen_string_literal: true

# Minimal patch for csl-ruby and citeproc-ruby compatibility
module CiteProc
  class Variable
    # Fix for: undefined method 'take' for an instance of CiteProc::Variable
    # https://github.com/inukshuk/csl-ruby/blob/b2131c0ce832f332c3db3c49fd2baf7e41ac0aa6/lib/csl/style/names.rb#L98
    # This ensures truncate returns an array of Name objects, not strings
    def take(n)
      val = @value
      array = case val
              when Array then val
              when nil then []
              else [val]
              end
      
      result = array.take(n)
      
      # Ensure all items are Name objects to fix: undefined method 'personal?' for String
      # https://github.com/inukshuk/citeproc-ruby/blob/2d6313cbb58d884dbfbccfb6f4a169d8d7c1b6fa/lib/citeproc/ruby/renderer/names.rb#L231
      result.map do |item|
        if item.respond_to?(:personal?) && item.respond_to?(:literal?)
          item
        elsif item.is_a?(String)
          CiteProc::Name.new(literal: item)
        else
          item
        end
      end
    end
  end
end

