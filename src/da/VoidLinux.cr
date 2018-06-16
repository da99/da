
module DA
  module VoidLinux
    extend self

    def install(bin_and_package : String)
      DA.system!("sudo xbps-install -S #{bin_and_package}")
    end # === def install

    def install(bin_name : String, package : String)
      `which #{bin_name}`
      if !DA.success?($?)
        install package
      end
    end # === def install

    def install(pkgs : Array(String))
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
