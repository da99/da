
module DA
  def default_path(str)
    this_dir = File.expand_path(
      File.join(File.dirname(__FILE__), "../..")
    )
    return File.join(this_dir, str)
  end # def
end # === module
