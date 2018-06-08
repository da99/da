
module DA
  def public_dir_permissions(public_dir : String)
    temp = public_dir
    while temp != "/"
      DA.system!("chmod o+rX #{temp}")
      temp = File.dirname(temp)
    end
  end # === def public_dir_permissions
end # === module DA
