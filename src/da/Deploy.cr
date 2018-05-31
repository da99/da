
require "ecr"

module DA

  def deploy_watch
    counter = 0
    interval = 5
    STDERR.puts "=== Started watching at: #{Time.now.to_s}"
    loop {
      sleep interval
      counter += interval

      if (counter % 5) == 0
        Dir.glob("/deploy/*/").each { |dir|
          next unless Dir.exists?(File.join dir, "releases")
          app_name = File.basename(dir)
          # init_sv(app_name) if !Dir.exists?("/deploy/sv/#{app_name}")
        }
      end
    }
  end # === def deploy_watch

  # Push the bin/da binary to /tmp on the remote server
  def init_remote(server_name : String)
    system!("rsync", "-v -e ssh #{Process.executable_path} #{server_name}:/tmp/".split)
    orange! "=== {{Run command on remote}}: BOLD{{/tmp/da init deploy}}"
    system!("ssh #{server_name}")
  end # === def init_server

  # Run this on the remote server you want to setup.
  def init_deploy
    Dir.cd("/") {
      if Dir.exists?("/deploy") 
        orange! "=== {{DONE}}: BOLD{{directory}} /deploy"
      else
        system!("sudo mkdir /deploy")
        system!("sudo chown #{ENV["USER"]} /deploy")
      end
    }

    system! "test -e /var/service/dhcpcd"
    system! "test -e /var/service/sshd"
    system! "test -e /var/service/ufw"
    system! "test -e /var/service/nanoklogd"
    system! "test -e /var/service/socklog-unix"

    system! "mkdir -p /deploy/apps/da/bin"
    system! "mv -f #{Process.executable_path} /deploy/apps/da/bin/"

    Dir.cd("/deploy/apps/da") {
      dir = "sv/deploy_watch"
      if Dir.exists?(dir)
        system! "sudo chown #{ENV["USER"]} #{dir}/run"
        system! "sudo chown #{ENV["USER"]} #{dir}/log/run"
      else
        system! "mkdir -p #{dir}/log"
      end

      File.write("#{dir}/run", {{system("cat templates/sv_da_deploy_watch.sh").stringify}})
      File.write("#{dir}/log/run", {{system("cat templates/sv_da_deploy_watch.log.sh").stringify}})

      system! "chmod +x #{dir}/run"
      system! "chmod +x #{dir}/log/run"
      system! "sudo chown --recursive root:root #{dir}"

      service = "/var/service/da_deploy_watch"
      if File.exists?(service)
        system! "sudo sv restart #{service}"
      else
        system! "sudo ln -s /deploy/apps/#{dir} #{service}"
      end
    }

    green! "=== {{Done}}: BOLD{{init deploy}}"
  end # === def init_deploy

end # === module DA
