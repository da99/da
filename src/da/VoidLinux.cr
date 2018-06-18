
module DA
  module VoidLinux
    extend self

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

  end # === module VoidLinux
end # === module DA
