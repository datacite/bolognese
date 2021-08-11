# frozen_string_literal: true

class String
  ## capitalize a string
  def my_titleize
    self.split(/\s+/).map(&:capitalize).join(' ')
  end
end
