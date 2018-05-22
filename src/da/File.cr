
module DA
  def text_file?(s : String)
    File.exists?(s) && `file --mime #{s}`["text/plain"]?
  end
end # === module DA
