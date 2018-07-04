# frozen_string_literal: true

# turn array into hash or nil, depending on array size.
# Reverses Array.wrap, but uses self to allow chaining with Array.wrap
class Array
  def unwrap
    case self.length
    when 0 then nil
    when 1 then self.first
    else self
    end
  end
end
