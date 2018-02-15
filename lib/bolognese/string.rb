class String
  def my_titleize
    self.gsub(/\b(['’]?[a-z])/) { "#{$1.capitalize}" }
  end
end
