
module DA
  struct Runit

    # =============================================================================
    # Struct:
    # =============================================================================

    # =============================================================================
    # Instance:
    # =============================================================================

    getter name        : String
    getter sv_dir      : String
    getter service_dir : String

    @pids : Array(Int32) = [] of Int32

    def initialize(@name)
      @sv_dir = case
                when DA.is_test?
                  "/tmp/specs_deploy/etc/sv/#{@name}"
                else
                  "/etc/sv/#{@name}"
                end

      @service_dir = case
                     when DA.is_test?
                       File.join("/tmp/specs_deploy/var/service", @name)
                     else
                       File.join("/var/service", @name)
                     end
    end # === def initialize(name : String)

    def initialize(@name, @sv_dir, @service_dir)
    end # === def initialize(name : String)

    def remove!
      if service_dir?
        if pids.size > 1
          DA.orange! "=== {{Found multiple pids}}: #{pids.join ", "}"
        else
          DA.orange! "=== {{PIDS}}: #{pids.join ", "} ==="
        end
        DA.system! "sudo rm -f #{service_dir}"
        wait_pids
      end
    end

    def linked?
      service_dir? && File.exists?(sv_dir) && `realpath #{sv_dir}` == `realpath #{service_dir}`
    end

    def link!
      if sv_dir != service_dir && !linked?
        DA.system!("sudo ln -sf #{sv_dir} #{service_dir}")
      end
    end # === def install!

    # Checkes if service_dir exists
    def service_dir?
      File.exists?(service_dir)
    end

    {% for x in "run down exit".split %}
      def {{x.id}}?
        status == {{x}}
      end
    {% end %}

    def status : String
      read_supervise("stat") || "exit"
    end # === def status

    def up!
      if !down?
        DA.exit!("Service is not in \"down\" state: #{service_dir} -> #{status}")
      end

      DA.system!("sudo sv up #{service_dir}")
      10.times do |i|
        if !run?
          sleep 1
          next
        end
        break
      end

      if !run?
        DA.exit!("Service is not in \"up\" state: #{service_dir} -> #{status}")
      end
      Runit.new(name, sv_dir, service_dir).pids.each { |pid|
        puts pid
      }
    end

    def down!
      if !run?
        DA.exit!("Not running: #{service_dir}")
      end

      DA.orange! "PIDs: #{pids.join ' '}"
      DA.system!("sudo sv down #{service_dir}")
      wait_pids
      if any_pids_up?
        DA.orange! "=== PIDs up: #{pids_up.join ", "}"
        exit 1
      end
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

    def pid : Int32?
      val = read_supervise("pid")
      return val.to_i32 if val
      val
    end

    def read_supervise(name)
      super_dir = File.join(service_dir, "supervise")
      return nil unless File.directory?(super_dir)

      file = File.join(super_dir, name)
      begin
        File.read(file).strip
      rescue e : Errno
        `sudo cat #{file}`.strip
      end
    end

    def update_pids
      return @pids unless run?
      pid_ = pid
      return @pids unless pid_
      @pids.push pid_
      @pids.concat `pgrep -P #{pid_}`.split.map(&.to_i32)
      @pids.uniq!
    end

    def pids
      update_pids if @pids.empty?
      @pids
    end

    # Don't use Process.exists, because that uses `kill -0`,
    #  causing an error if user does not have permission
    #  to send signal to process. Instead, we use `ps`.
    def pids_up
      update_pids if @pids.empty?
      pids.select { |x| `ps -p #{x} -o pid=`.strip == x.to_s }
    end

    def any_pids_up?
      update_pids if @pids.empty?
      !pids_up.empty?
    end # === def any_pids_up?

  end # === struct Runit

end # === module DA
