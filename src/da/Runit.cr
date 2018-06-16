
module DA_Deploy
  struct Runit

    # =============================================================================
    # Class:
    # =============================================================================

    def self.status(service_link)
      `sudo sv status #{service_link}`.strip
    end # === def self.state

    # =============================================================================
    # Instance:
    # =============================================================================

    getter pids         : Array(Int32) = [] of Int32
    getter name         : String
    getter service_link : String
    getter app_dir      : String

    def initialize(@name)
      @service_link = File.join(SERVICE_DIR, name)
      @name         = File.basename(@service_link)
      @app_dir      = File.join(DEPLOY_DIR, "apps", name)

      status = self.class.status(@service_link)
      is_running = status.split(':').first == "run"

      if is_running && status["(pid "]?
        match = status.match(/\(pid (\d+)\)/)
        if match
          pid = match[1].to_i32
          @pids.concat `pstree -A -p #{pid}`.scan(/\((\d+)\)/).map(&.[1].to_i32)
        end
      end

    end # === def initialize(name : String)

    def sv_dir
      dir = latest.not_nil!
      File.join(dir, "sv")
    end # === def sv_dir

    def latest?
      !!latest
    end

    def latest
      releases.last?
    end

    def releases
      Dir.glob( File.join("#{app_dir}/*/sv/") ).sort.map { |x|
        File.dirname(File.dirname(x))
      }
    end

    def linked?
      File.exists?(@service_link)
    end

    def latest_linked?
      dir = latest
      if dir
        `realpath #{sv_dir}` == `realpath #{service_link}`
      else
        false
      end
    end

    def link!
      DA.system!("sudo ln -s #{sv_dir} #{service_link}")
    end # === def install!

    {% for x in "run down exit".split %}
      def {{x.id}}?
        status == {{x}}
      end
    {% end %}

    def status
      self.class.status(service_link).split(':').first
    end # === def status

    def up!
      if !down?
        DA.exit_with_error!("Service is not in \"down\" state: #{service_link} -> #{status}")
      end

      DA.system!("sudo sv up #{service_link}")
      10.times do |i|
        if !run?
          sleep 1
          next
        end
        break
      end

      if !run?
        DA.exit_with_error!("Service is not in \"up\" state: #{service_link} -> #{status}")
      end
      Runit.new(service_link).pids.each { |pid|
        puts pid
      }
    end

    def down!
      if !run?
        DA.exit_with_error!("Not running: #{service_link}")
      end
      procs = pids

      STDERR.puts "PIDs: #{procs.join ' '}"

      DA.system!("sudo sv down #{service_link}")
    end

    def wait_pids
      max = 10
      counter = 0
      while counter < 10
        break unless any_pids_up?
        counter += 1
        sleep 1
      end
      max < 10
    end # === def wait_pids

    def pids_up
      pids.select { |x| `ps -p #{x} -o pid=`.strip == x.to_s }
    end

    def any_pids_up?
      !pids_up.empty?
    end # === def any_pids_up?

  end # === struct Runit

end # === module DA_Deploy
