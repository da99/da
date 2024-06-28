
module DA
  struct Runit

    class Exception < ::DA::Exception
    end

    # =============================================================================
    # Struct:
    # =============================================================================

    def self.valid_name!(raw : String)
      if !raw[/^[a-zA-Z0-9\-\.\_]+$/]?
        raise Runit::Exception.new("Invalid service name: #{raw.inspect}")
      end
      raw
    end # === def self.valid_name!

    def self.resolved_path!(dir : String, name : String)
      if dir.index('/') != 0
        raise Runit::Exception.new("Real paths are required: #{dir}")
      end

      if File.basename(dir) != name
        dir = File.join(dir, name)
      end

      if !dir[/^\/[a-zA-Z\d\_\-\.\/]+$/]?
        raise Runit::Exception.new("Invalid name for directory: #{dir.inspect}")
      end

      dir
    end # === def self.real_path

    def self.directory!(dir : String)
      if !File.directory?(dir)
        raise Runit::Exception.new("Directory does not exist: #{dir}")
      end
      dir
    end # === def

    def self.find(dir : String) : Array(String)
      return [] of String if !File.exists?(dir)
      Dir.cd(dir) {
        raw = DA.output("find", ". -path */supervise* -prune -o -print".split)
        return raw.strip.split('\n').reject(&.empty?).sort
      }
    end

    # =============================================================================
    # Instance:
    # =============================================================================

    SCRIPTS = %w[
      run
      log/run
      check
      finish
    ]

    getter name        : String
    getter sv_dir      : String
    getter service_dir : String

    @pids : Array(Int32) = [] of Int32

    def initialize(raw_name : String, sv : String = "/etc/sv", service : String = "/var/service")
      @name        = self.class.valid_name!(raw_name)
      @sv_dir      = Runit.resolved_path!(sv, name)
      @service_dir = Runit.resolved_path!(service, name)
    end # === def initialize(name : String)

    def remove!
      if !File.exists?(service_dir)
        return
      end

      if pids.size > 1
        DA.orange! "=== {{Found multiple pids}}: #{pids.join ", "}"
      else
        DA.orange! "=== {{PIDS}}: #{pids.join ", "} ==="
      end

      cmd = "rm -r #{service_dir}"
      if !DA.success?(cmd)
        DA.success! "sudo #{cmd}"
      end

      wait_pids
    end

    # Creates a link from sv dir to service dir.
    def link!
      Runit.directory! sv_dir
      Runit.directory! File.dirname(service_dir)
      DA.symlink!(sv_dir, service_dir)
    end # def link!

    def install!
      Runit.directory! sv_dir
      Runit.directory! File.dirname(service_dir)

      # Trailing slash tip : http://qdosmsq.dunbar-it.co.uk/blog/2013/02/rsync-to-slash-or-not-to-slash/
      cmd = "rsync --checksum --verbose --recursive --executability --human-readable --chmod=o-wX #{sv_dir}/ #{service_dir}"
      if !DA.success?(cmd)
        DA.success! "sudo #{cmd}"
      end
    end # === def install!

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
        DA.red!("Service is not in \"down\" state: #{service_dir} -> #{status}")
        exit 1
      end

      DA::Process::Inherit.new("sudo sv up #{service_dir}").success!
      10.times do |i|
        if !run?
          sleep 1
          next
        end
        break
      end

      if !run?
        DA.red!("Service is not in \"up\" state: #{service_dir} -> #{status}")
        exit 1
      end
      Runit.new(name, sv_dir, service_dir).pids.each { |pid|
        puts pid
      }
    end

    def down!
      if !run?
        DA.red!("Not running: #{service_dir}")
        exit 1
      end

      DA.orange! "PIDs: #{pids.join ' '}"
      DA::Process::Inherit.new("sudo sv down #{service_dir}").success!
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
      rescue e : Exception
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
