
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

  end # === module VoidLinux
end # === module DA
