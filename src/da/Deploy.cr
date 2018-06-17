
module DA
  module Deploy
    DEPLOY_DIR  = "/deploy"
    SERVICE_DIR = "/var/service"

    extend self

    def wait(max : Int32)
      counter = 0
      result = false
      while counter < max
        result = yield
        break if result
        counter += 1
        sleep 1
      end
      result
    end # === def wait

    def check
      puts "http://domain.com/file -> https://domain.com/file"
      puts "http://domain.com/     -> https://domain.com/"
      puts "check directing listing is off for all sites."
    end # === def deploy_check

    def public(app_name : String)
      public = Public_Dir.new(app_name)
      if !public.latest?
        DA.orange!("=== No Public dir for: {{#{app_name}}}")
        return false
      end
      public.link!
    end # === def deploy_public

    def pg(app_name : String)
      pg = PG.new(app_name)
      if !pg.exists?
        DA.orange!("=== Skipping pg install: no pg/ directory found.")
        return false
      end

      Linux.useradd_system(pg.user)
      Linux.groupadd(pg.group_socket)
    end # === def pg

    def sv(app_name : String)
      sv = Runit.new(app_name)
      Dir.cd(sv.app_dir)

      if !sv.latest?
        DA.orange!("=== No service found for: {{#{sv.name}}}")
        return false
      end

      useradd_system("www-#{sv.name}")

      if sv.latest_linked?
        DA.orange! "=== Already installed: #{sv.service_link} -> #{`realpath #{sv.service_link}`}"
        return false
      end

      if sv.linked?
        sv.down! if sv.run?
        sv.wait_pids
        if sv.any_pids_up?
          DA.exit_with_error!("!!! Pids still up for #{sv.name}: #{sv.pids_up}")
        end
        DA.system!("sudo rm -f #{sv.service_link}")
      end

      sv.link!

      new_service = Runit.new(sv.name)
      sleep 5
      wait(5) { new_service.run?  }
      puts Runit.status(new_service.service_link)
      if !new_service.run?
        Process.exit 1
      end
    end # === def deploy_public

    # Run this on the remote server you want to setup.
    def init
      user = ENV["USER"]

      if DA.is_development?
        STDERR.puts "!!! Not a production machine."
        Process.exit 1
      end

      Dir.cd("/") {
        DA.system! "sudo mkdir -p #{DEPLOY_DIR}"
        DA.system! "sudo chown #{user}:#{user} #{DEPLOY_DIR}"
        DA.system! "sudo chmod o+rX #{DEPLOY_DIR}"
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

      "dhcpcd sshd ufw nanoklogd socklog-unix".split.each { |name|
        Runit.new(name).link!
      }

      "3 4 5 6".split.each { |x|
        service = Runit.new("agetty-tty#{x}")
        service.remove! if service.service_dir?
      }

      init_ssh

      Linux.useradd_system("da_cache")
      DA.system! "mkdir -p /deploy/da_cache"
      DA.system! "sudo chown da_cache:da_cache /deploy/da_cache"
      DA.system! "sudo chmod g+rXw /deploy/da_cache"
      DA.system! "sudo chmod o-rXw /deploy/da_cache"

      DA.green! "=== {{Done}}: BOLD{{init deploy}}"
    end # === def init_deploy

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

    def upload_shell_config_to(server_name : String)
      bin_path = Process.executable_path.not_nil!
      app_dir = File.join(
        File.dirname(File.dirname(bin_path))
      )
      Dir.cd(app_dir)
      Dir.cd("config/deployer/")
      DA.system!("rsync -v -e ssh --relative --recursive .config/fish #{server_name}:/home/deployer/")
    end # === def upload_shell_config

    # Push the bin/da_deploy binary to /tmp on the remote server
    def upload_binary_to_remote(server_name : String)
      DA.system!("rsync", "-v -e ssh --relative --recursive bin #{server_name}:/home/deployer/".split)
    end # === def init_server

    def upload_commit_to_remote(server_name : String)
      release_id = Release.generate_id
      app_name   = File.basename(Dir.current)
      remote_dir = "/deploy/#{app_name}/#{release_id}"

      if DA.success?("ssh #{server_name} test -d #{remote_dir}")
        DA.exit_with_error!("!!! Already exists on server: #{remote_dir}")
      end

      path = Dir.current
      tmp = "/tmp/commits"
      FileUtils.mkdir_p tmp
      Dir.cd(tmp) {
        clone_dir = "#{app_name}/#{release_id}"
        FileUtils.rm_rf(release_id)
        DA.system!("git clone --depth 1 file://#{path} #{clone_dir}")
        DA.system!("rm -rf #{clone_dir}/.git")
        DA.system!("rsync -v -e ssh --relative --recursive #{clone_dir} #{server_name}:/deploy/")
      }
    end # === def upload_commit_to_remote

  end # === module Deploy
end # === module DA
