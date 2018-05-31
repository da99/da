
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
    run_command!("rsync", "-v -e ssh #{Process.executable_path} #{server_name}:/tmp/".split)
    orange! "=== {{Run command on remote}}: BOLD{{/tmp/da init deploy}}"
    run_command!("ssh #{server_name}")
  end # === def init_server

  # Run this on the remote server you want to setup.
  def init_deploy
    Dir.cd("/") {
      if Dir.exists?("/deploy") 
        orange! "=== {{DONE}}: BOLD{{directory}} /deploy"
      else
        run_command!("sudo mkdir /deploy")
        run_command!("sudo chown #{ENV["USER"]} /deploy")
      end
    }

    run_command! "test -e /var/service/dhcpcd"
    run_command! "test -e /var/service/sshd"
    run_command! "test -e /var/service/ufw"
    run_command! "test -e /var/service/nanoklogd"
    run_command! "test -e /var/service/socklog-unix"

    run_command! "mkdir -p /deploy/apps/da/bin"
    run_command! "mv -f #{Process.executable_path} /deploy/apps/da/bin/"

    Dir.cd("/deploy/apps/da") {
      dir = "sv/deploy_watch"
      if Dir.exists?(dir)
        run_command! "sudo chown #{ENV["USER"]} #{dir}/run"
        run_command! "sudo chown #{ENV["USER"]} #{dir}/log/run"
      else
        run_command! "mkdir -p #{dir}/log"
      end

      File.write("#{dir}/run", {{system("cat templates/sv_da_deploy_watch.sh").stringify}})
      File.write("#{dir}/log/run", {{system("cat templates/sv_da_deploy_watch.log.sh").stringify}})

      run_command! "chmod +x #{dir}/run"
      run_command! "chmod +x #{dir}/log/run"
      run_command! "sudo chown --recursive root:root #{dir}"

      service = "/var/service/da_deploy_watch"
      if File.exists?(service)
        run_command! "sudo sv restart #{service}"
      else
        run_command! "sudo ln -s /deploy/apps/#{dir} #{service}"
      end
    }

    green! "=== {{Done}}: BOLD{{init deploy}}"
  end # === def init_deploy

end # === module DA
