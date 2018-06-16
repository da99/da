
module DA_Dev
  module OS
    extend self

    NOLOGIN_SHELL = "/bin/nologin"

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

  end # === module OS
end # === module DA_Dev
