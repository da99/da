

require "./File_System"
require "./VoidLinux"
require "./Ubuntu"
require "./CLI"

module DA
  module OS
    @@lsb_release = ""
    extend self

    NOLOGIN_SHELL = "/bin/nologin"

    def free_space_check
      ["/var 100", "/boot/efi 100", "/ 400" ].each { |x|
        dir, min = x.split
        empty = (File_System.free_space(dir) / 1024).to_i
        if empty < min.to_i
          raise "!!! Not enough space in #{dir.inspect}: #{empty} MB"
        end
        if CLI.interactive?
          DA.orange! "  #{dir} : #{empty} MB free"
        end
      }
      true
    end # def

    def create_system_user(name)
      if !user?(name)
        raise Error.new("Create user: useradd --shell #{NOLOGIN_SHELL} --no-create-home --system #{name};")
      end

      shell = default_shell(name)
      if shell != NOLOGIN_SHELL
        raise Error.new("User exists but has improper shell: #{shell}. Run: usermod -s #{NOLOGIN_SHELL} #{name}")
      end

      DA_Dev.green! "=== {{User exists}}: BOLD{{#{name}}} (shell: #{default_shell(name)})"
    end

    def create_user(name : String)
      if !user?(name)
        raise Error.new("Create user: useradd --shell /bin/specify-shell-in-bin #{name};")
      else
        DA_Dev.green! "=== {{User exists}}: BOLD{{#{name}}} (shell: #{default_shell(name)})"
      end
    end # === def create_user

    def user?(name : String)
      proc = DA_Process.new("id", ["-u", name])
      proc.success?
    end

    def default_shell(name)
      proc = DA_Process.new("getent", ["passwd", name])
      if proc.success?
        proc.output.to_s.strip.split(':').last
      else
        nil
      end
    end

    def ubuntu?
      name == "Ubuntu"
    end # def

    def void_linux?
      name == "Void Linux"
    end # def

    def name
      if @@lsb_release.empty?
        @@lsb_release = `lsb_release -a 2>/dev/null`.strip
      end

      case
      when @@lsb_release["Ubuntu"]?
        "Ubuntu"
      when @@lsb_release["Void"]?
        "Void Linux"
      else
        STDERR.puts "!!! Unknown OS: #{@@lsb_release.inspect}"
        exit 2
      end
    end # def

    def upgrade
      case
      when ubuntu?
        Ubuntu.upgrade
      when void_linux?
        VoidLinux.upgrade
      else
        raise "!!! Unknown os: #{name}"
      end
    end # def

  end # === module OS
end # === module DA_Dev
