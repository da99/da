
module DA_Deploy

  # Run this on the remote server you want to setup.
  def init
    if ENV["IS_DEVELOPMENT"]?
      STDERR.puts "!!! Not a production machine."
      Process.exit 1
    end

    app_name = File.basename(Process.executable_path || self.to_s.downcase)
    required_services = "dhcpcd sshd ufw nanoklogd socklog-unix".split

    Dir.cd("/") {
      if Dir.exists?(DEPLOY_DIR) 
        DA.orange! "=== {{DONE}}: BOLD{{directory}} #{DEPLOY_DIR}"
      else
        DA.system!("sudo mkdir #{DEPLOY_DIR}")
        DA.system!("sudo chown #{ENV["USER"]} #{DEPLOY_DIR}")
      end
    }

    DA::VoidLinux.install("git", "git")
    DA::VoidLinux.install("rsync", "rsync")
    DA::VoidLinux.install("nvim", "neovim")
    DA::VoidLinux.install("fish", "fish-shell")
    DA::VoidLinux.install("htop", "htop")
    DA::VoidLinux.install("socklog", "socklog-void")
    DA::VoidLinux.install("ufw", "ufw")
    DA::VoidLinux.install("wget", "wget")
    DA::VoidLinux.install("curl", "curl")

    DA.system! "test -e #{SERVICE_DIR}/dhcpcd"
    DA.system! "test -e #{SERVICE_DIR}/sshd"
    DA.system! "test -e #{SERVICE_DIR}/ufw"
    DA.system! "test -e #{SERVICE_DIR}/nanoklogd"
    DA.system! "test -e #{SERVICE_DIR}/socklog-unix"

    "3 4 5 6".split.each { |x|
      service = "/var/service/agetty-tty#{x}"
      DA.system! "sudo rm #{service}" if File.exists?(service)
    }

    init_ssh

    DA.system! "mkdir -p /tmp/da_cache"
    DA.system! "sudo chmod o+rxw /tmp/da_cache"

    DA.green! "=== {{Done}}: BOLD{{init deploy}}"
  end # === def init_deploy

  def init_www
    "www-redirector www-deployer www-data".split.each { |user|
      useradd(user)
    }
    DA::VoidLinux.install("hiawatha", "hiawatha")
  end

  def init_ssh
    file = "/etc/ssh/sshd_config"
    File.read(file).split('\n').map { |l| l.split }.each { |pieces|
      count  = pieces.size
      first  = pieces[0]?
      second = pieces[1]?
      next if first && first.index('#') == 0
      next if !first
      case first.upcase
      when "PermitRootLogin".upcase, "PasswordAuthentication".upcase, "UsePAM".upcase
        next if second == "no"
      when "ChallengeResponseAuthentication".upcase
        next if second == "no"
      else
        next
      end

      DA.exit_with_error!("!!! Invalid value for sshd_config: #{pieces.join ' '}")
    }

    Dir.cd(ENV["HOME"]) {
      DA.system!("chmod 700 -R .ssh")
      Dir.cd(".ssh") {
        contents = (File.exists?("authorized_keys") ? File.read("authorized_keys") : "").strip
        if contents.empty?
          DA.exit_with_error!("!!! authorized_keys empty.")
        else
          DA.system!("sudo sv restart sshd")
        end
      }
    }
  end # === def init_ssh

end # === module DA_Deploy
