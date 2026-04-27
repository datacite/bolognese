# frozen_string_literal: true

# Minimal patch for csl-ruby and citeproc-ruby compatibility
# Root cause: 'contributor' is not recognized as a names variable in citeproc gem
# https://github.com/inukshuk/citeproc/blob/121fa4a950b9bd71960e42d20db96bcea1165201/lib/citeproc/variable.rb#L20-L24

module CiteProc
  class Variable
    # Unfreeze, modify, and refreeze the fields to add 'contributor' and 'accepted-date'
    if @fields
      # Unfreeze the fields hash temporarily
      fields_dup = @fields.dup
      
      # Add contributor to names (make a new unfrozen array)
      fields_dup[:names] = (@fields[:names] + [:contributor]).uniq
      
      # Add accepted-date to dates (make a new unfrozen array)
      fields_dup[:date] = (@fields[:date] + [:'accepted-date']).uniq
      
      # Rebuild the types mapping - only use actual type keys, not aliases like :all, :any, etc.
      types_hash = Hash[*[:date, :names, :number, :text].map { |k| fields_dup[k].map { |n| [n, k] } }.flatten]
      
      # Update the class instance variables
      @fields = fields_dup
      @types = Hash.new { |h,k| h.fetch(k.to_sym, nil) }.merge(types_hash).freeze
      
      # Rebuild @factories from the new @types
      # This maps each field name to its Variable subclass (Names, Date, Text, Number)
      @factories = Hash.new { |h,k| h.fetch(k.to_s.intern, CiteProc::Variable) }.merge(
        Hash[*@types.map { |field_name, type|
          [field_name, CiteProc.const_get(type.to_s.capitalize)]
        }.flatten]
      ).freeze
      
      # Recreate the aliases
      @fields[:name] = @fields[:names]
      @fields[:dates] = @fields[:date]
      @fields[:numbers] = @fields[:number]
      
      # Recreate :all and :any
      @fields[:all] = @fields[:any] =
        [:date, :names, :text, :number].reduce([]) { |s,a| s.concat(@fields[a]) }.sort
      
      # Refreeze fields
      @fields.freeze
    end
  end
end
