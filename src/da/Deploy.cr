
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

    def deploy_check
      puts "http://domain.com/file -> https://domain.com/file"
      puts "http://domain.com/     -> https://domain.com/"
      puts "check directing listing is off for all sites."
    end # === def deploy_check

    def deploy(name : String)
      deploy_public(name)
      deploy_sv(name)
      deploy_pg(name)
    end # === def deploy

    def deploy_public(app_name : String)
      public = Public_Dir.new(app_name)
      if !public.latest?
        DA.orange!("=== No Public dir for: {{#{app_name}}}")
        return false
      end
      public.link!
    end # === def deploy_public

    def deploy_pg(app_name : String)
      pg = PG.new(app_name)
      if !pg.exists?
        DA.orange!("=== Skipping pg install: no pg/ directory found.")
        return false
      end

      useradd(pg.user)
      groupadd(pg.group_socket)
    end # === def deploy_pg

    def deploy_sv(app_name : String)
      sv = Runit.new(app_name)
      Dir.cd(sv.app_dir)

      if !sv.latest?
        DA.orange!("=== No service found for: {{#{sv.name}}}")
        return false
      end

      useradd("www-#{sv.name}")

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

  end # === module Deploy
end # === module DA
