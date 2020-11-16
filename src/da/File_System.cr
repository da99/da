
module DA

  module File_System
    extend self

    class Exception < ::DA::Exception
    end

    def usb_drives
      `lsblk -l`.strip.split('\n').select { |line|
        # NAME      MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
        #  0           1     2     3   4  5    6
        pieces = line.split
        name, type = pieces[0], pieces[5]
        type == "disk" && name[/^sd/]?
      }
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

    def symlink!(original, target)
      if !File.exists?(original)
        raise File_System::Exception.new "Symbolic link origin does not exist: #{original}"
      end

      if File.symlink?(target) && !File.exists?(target)
        DA.orange!("Link exists, but is broken: #{target}")
      end

      if File.exists?(target) && !File.symlink?(target)
        raise File_System::Exception.new("Symbolic link target already exists: #{target}")
      end

      if File.symlink?(target) && File.exists?(target) && File.real_path(original) == File.real_path(target)
        DA.orange! "=== Already linked: #{original} -> #{target}"
        return true
      end

      cmd = "ln -s -f --no-dereference #{original} #{target}"
      return true if DA::Process::Inherit.new(cmd).success?

      DA::Process::Inherit.new("sudo #{cmd}").success!
      true
    end # === def symlink!

  end # module
end # === module DA
