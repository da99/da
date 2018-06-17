
module DA

  def is_development?
    ENV["IS_DEVELOPMENT"]? || ENV["IS_DEV"]?
  end # === def is_development?

  def is_test?
    ENV["IS_TEST"]?
  end

  def text_file?(s : String)
    File.exists?(s) && `file --mime #{s}`["text/plain"]?
  end

  def public_dir_permissions(public_dir : String)
    temp = public_dir
    while temp != "/"
      DA.system!("chmod o+rX #{temp}")
      temp = File.dirname(temp)
    end
    DA.system!("chmod o+rX -R #{public_dir}")
  end # === def public_dir_permissions

  def symlink?(target : String)
    File.info(target, follow_symlinks: false).symlink?
  end

  def link_symbolic!(original, target)
    if !File.exists?(original)
      DA.exit_with_error! "Symbolic link origin does not exist: #{original}"
    end

    if File.exists?(target) && !DA.symlink?(target)
        DA.exit_with_error! "Symbolic link target already exists: #{target}"
    end

    return true if DA.success?(DA.run("ln -sf #{original} #{target}"))

    DA.system!("sudo ln -sf #{original} #{target}")
    true
  end # === def link_symbolic

end # === module DA
