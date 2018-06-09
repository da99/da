
module DA

  def is_development?
    ENV["IS_DEVELOPMENT"]? || ENV["IS_DEV"]?
  end # === def is_development?

  def public_dir_permissions(public_dir : String)
    temp = public_dir
    while temp != "/"
      DA.system!("chmod o+rX #{temp}")
      temp = File.dirname(temp)
    end
    DA.system!("chmod o+rX -R #{public_dir}")
  end # === def public_dir_permissions

end # === module DA
