class String
  def my_titleize
    #self.gsub(/(\b[\w']+\b|_)(.)/) { "#{$1}#{$2.upcase}" }
    self.gsub(/\b(['’]?[a-z])/) { "#{$1.capitalize}" }
  end
end
