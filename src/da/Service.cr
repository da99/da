
module DA_Deploy

  def service_name?(name : String, dir : String)
    dir_name = File.dirname(dir)
    dir_name =~ /^#{name}\.\d{10}-[\da-zA-Z]{7}$/
  end # === def service_name?

end # === module DA_Deploy
