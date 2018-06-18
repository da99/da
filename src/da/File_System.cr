
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

  def public_dir?(raw : String)
    public_dir = temp = File.expand_path(raw)
    return false if !File.directory?(public_dir)
    while temp.size > 1
      perms = File.info(temp).permissions
      if !(perms.other_read? && perms.other_execute?)
        return false
      end
      temp = File.dirname(temp)
    end
    true
  end # === def public_dir_permissions

  def symlink?(target : String)
    File.info(target, follow_symlinks: false).symlink?
  end

  def link_symbolic!(original, target)
    if !File.exists?(original)
      DA.exit! "Symbolic link origin does not exist: #{original}"
    end

    if File.exists?(target) && !DA.symlink?(target)
        DA.exit! "Symbolic link target already exists: #{target}"
    end

    if File.exists?(original) && File.exists?(target) && `realpath #{original}` == `realpath #{target}`
      DA.orange! "=== Already linked: #{original} -> #{target}"
      return true
    end

    cmd = "ln -s -f --no-dereference"
    return true if DA.success?(DA.run("#{cmd} #{original} #{target}"))

    DA.system!("sudo #{cmd} #{original} #{target}")
    true
  end # === def link_symbolic

end # === module DA
