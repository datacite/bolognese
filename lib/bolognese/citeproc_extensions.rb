# frozen_string_literal: true

# Minimal patch for csl-ruby and citeproc-ruby compatibility
# Root cause: 'contributor' is not recognized as a names variable in citeproc gem
# https://github.com/inukshuk/citeproc/blob/121fa4a950b9bd71960e42d20db96bcea1165201/lib/citeproc/variable.rb#L20-L24

module CiteProc
  class Variable
    # Add 'contributor' to the list of name variables
    # Add 'accepted-date' to the list of date variables
    if @fields[:names]
      @fields[:names] << :contributor unless @fields[:names].include?(:contributor)
      @fields[:date] << :'accepted-date' unless @fields[:date].include?(:'accepted-date')
      
      # Rebuild the types mapping to include the new fields
      @types = Hash.new { |h,k| h.fetch(k.to_sym, nil) }.merge(
        Hash[*@fields.keys.map { |k| @fields[k].map { |n| [n,k] } }.flatten]
      ).freeze
    end
  end
end
