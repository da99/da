
module DA
  module VoidLinux
    extend self

    def update_time
      current_time = `sudo date +"%c"`.strip
      new_time     = `my_os time get`.strip
      if new_time.empty?
        raise "Unable to get new time."
      end
    # From:
    # https://askubuntu.com/questions/81293/what-is-the-command-to-update-time-and-date-from-internet
      DA::Process::Inherit.new(["sudo", "date", "-s", "#{new_time}Z"]).success!
    end # def

    def install(pkg_name : String)
      install [pkg_name]
    end # === def install

    def install(bin_name : String, pkg_name : String)
      `which #{bin_name}`
      if !DA.success?($?)
        install [pkg_name]
      end
    end # === def install

    def install(pkgs : Array(String))
      DA.orange! "{{sudo}} xbps-install -S BOLD{{#{pkgs.join ' '}}}"
      system "sudo xbps-install -S #{pkgs.join ' '}"
      status = $?
      if [6, 17].includes?(status.exit_code)
        DA.orange! "=== xbps-install exited: {{#{status.exit_code}}}"
      else
        DA.success! status
      end
    end # === def install

    def service!(raw_dir, raw_service)
      sv = if File.directory?(raw_dir)
             raw_dir
           else
             File.join "/etc/sv", raw_dir
           end
      service = if File.directory?(raw_service)
                  raw_service
                else
                  File.join "/var/service", raw_service
                end

      real_sv = `realpath #{sv}`.strip
      if !File.directory?(real_sv)
        DA.exit! "!!! Directory not found: #{raw_dir}"
      end

      if File.exists?(service)
        real_service = `realpath #{service}`.strip
        if real_sv == real_service
          DA.orange! "=== Already installed: #{sv} -> #{service}"
          return
        else
          DA.exit! "!!! Service linked to another directory: #{real_sv} #{service}"
        end
      end

      DA.system! "sudo ln -s #{sv} #{service}"
    end # === def service

    def upgrade
      DA::Process::Inherit.new("sudo xbps-install -Su").success!
      DA::Process::Inherit.new("sudo xbps-remove --yes --clean-cache --remove-orphans --verbose").success!
      DA::Process::Inherit.new("vkpurge list".split).success!
      DA::Process::Inherit.new("my_browser google-chrome --install".split).success!
      x = (DA::File_System.free_space("/tmp") / 1024).to_i
      if x < 1000
        raise "!!! Not enough free space in /tmp: #{x} MB"
      end
      DA::OS.free_space_check
    end # === def upgrade

  end # === module VoidLinux
end # === module DA
