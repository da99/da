
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

    def current!(app : App)
      latest = Release.latest(app)
      DA.symlink! app.current, latest
    end # === def current!

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
      Dir.cd(sv.app_dir) {
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
            DA.exit!("!!! Pids still up for #{sv.name}: #{sv.pids_up}")
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
      } # Dir.cd
    end # === def deploy_public

    # Run this on the remote server you want to setup.
    def init
      user = ENV["USER"]

      if DA.development?
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
        service.remove! if File.symlink?(service.service_dir)
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

        DA.exit!("!!! Invalid value for sshd_config: #{pieces.join ' '}")
      }

      Dir.cd(ENV["HOME"]) {
        DA.system!("chmod 700 -R .ssh")
        Dir.cd(".ssh") {
          contents = (File.exists?("authorized_keys") ? File.read("authorized_keys") : "").strip
          if contents.empty?
            DA.exit!("!!! authorized_keys empty.")
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
      Dir.cd(File.join app_dir, "config/deployer/") {
        DA.system!("rsync -v -e ssh --relative --recursive .config/fish #{server_name}:/home/deployer/")
      }
    end # === def upload_shell_config

    # Push the bin/da_deploy binary to /tmp on the remote server
    def upload_binary_to_remote(server_name : String)
      app_name = File.basename Dir.current
      file     = File.join "bin", app_name
      if !File.executable?(file)
        DA.orange! "!!! {{Not found}}: BOLD{{#{file}}}"
        exit 1
      end
      DA::Process::Inherit.new("rsync -v -e ssh --relative #{file} #{server_name}:/home/deployer/").success!
    end # === def init_server

    def upload_commit_to_remote(server_name : String)
      release_id = Release.generate_id
      app_name   = File.basename(Dir.current)
      remote_dir = "/deploy/#{app_name}/#{release_id}"

      if DA::Process::Inherit.new("ssh #{server_name} test -d #{remote_dir}").success?
        DA.red!("!!! Already exists on server: #{remote_dir}")
        exit 1
      end

      path = Dir.current
      tmp = "/tmp/commits"
      FileUtils.mkdir_p tmp
      Dir.cd(tmp) {
        clone_dir = "#{app_name}/#{release_id}"
        FileUtils.rm_rf(release_id)
        DA::Process::Inherit.new("git clone --depth 1 file://#{path} #{clone_dir}").success!
        DA::Process::Inherit.new("rm -rf #{clone_dir}/.git").success!
        DA::Process::Inherit.new("rsync -v -e ssh --relative --recursive #{clone_dir} #{server_name}:/deploy/").success!
      }
    end # === def upload_commit_to_remote

  end # === module Deploy
end # === module DA
