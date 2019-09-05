
module DA

  def test?
    (ENV["IS_TEST"]? || "").upcase == "YES"
  end

  def debug?
    (ENV["IS_DEBUG"]? || "").upcase == "YES"
  end

  def development?
    (ENV["IS_DEVELOPMENT"]? || "").upcase == "YES"
  end # === def

  def inspect!(*args)
    return false unless debug?

    STDERR.puts args.map(&.inspect).join(", ")
    true
  end # === def inspect!

  module Dev
    extend self

    CMD_ERRORS = [] of Int32 | String

    MTIMES    = {} of String => Int64
    PROCESSES = {} of String => Process
    SCRIPTS   = {} of String => ::DA::Script


    def time
      `date +"%r"`.strip
    end

    def da_dir
      bin_dir = File.dirname(Process.executable_path.not_nil!)
      File.dirname(bin_dir)
    end

    def pid_file
      bin_dir = File.dirname(Process.executable_path.not_nil!)
      da_dir  = File.dirname(bin_dir)
      File.join da_dir, "tmp/out/watch_pid.txt"
    end

    def run_cmd(args : Array(String)) : Bool
      da_cmd = args.shift
      full_cmd = args.join(' ').strip
      cmd = args.shift?

      case

      when da_cmd == "#"
        DA.orange! "=== {{Skipping}}: #{full_cmd}"

      when da_cmd == "proc"
        DA.orange! "=== {{Process}}: BOLD{{#{full_cmd}}}"
        # args = "echo a".split
        x = Process.new(args.shift, args, output: STDOUT, input: STDIN, error: STDERR)
        PROCESSES[x.pid] = x
        STDERR.puts "=== New process: #{x.pid}"
        x

      when da_cmd == "PING" && args.empty?
        DA.orange! "=== {{Running}}: #{da_cmd} ==="
        DA.green! "=== PONG ==="

      when da_cmd == "run" && !full_cmd.empty? && cmd
        DA.bold! "=== {{#{full_cmd}}} (#{time})"

        # Only show progress output on error:
        system(cmd, args)
        stat = $?
        if !DA.success?(stat)
          DA.red! "!!! {{EXIT}}: BOLD{{#{stat.exit_code}}} (#{full_cmd})"
          return false
        end

      else
        DA.red! "=== {{Unknown command}}: (#{da_cmd}) BOLD{{#{full_cmd}}} ==="
        return false

      end # case

      true
    end # === def run

    def run_process_status
      PROCESSES.each { |file, x|
        if defunct?(x.pid)
          STDERR.puts "=== Process defunct: #{x.pid}"
          PROCESSES.delete file
        end
        if x.terminated?
          STDERR.puts "=== Process terminated: #{x.pid}"
          PROCESSES.delete file
        end
      }
    end # === def run_process_status

    # Write a .sh scrip file to tmp/out of DA app dir.
    def watch_run(raw_path : String)
      app_dir = Dir.current
      file_path = File.expand_path(raw_path)
      Dir.cd da_dir
      new_file = "tmp/out/#{app_dir.gsub('/', "__")}.sh"
      if !File.exists?(file_path)
        File.write(new_file, "ERROR: File does not exist: #{file_path}")
        return false
      end

      run_contents = File.read(file_path)
      if run_contents.strip.empty?
        File.write(new_file, "echo empty contents: #{raw_path}; exit 1")
      else
        File.write(new_file, %<
          #{app_dir}
          #{file_path}
        >.strip)
      end
    end # === def watch_run

    def watch
      `mkdir -p /apps/da/tmp`
      Dir.cd("/apps/da/tmp") {
        `touch watch.pids`
        File.read("watch.pids").split.each { |pid|
          if Process.exists?(pid.to_i)
            STDERR.puts "Process already exists: #{pid}"
            Process.exit 2
          end
        }
        File.write("watch.pids", Process.pid)
      }

      Signal::TERM.trap do
        kill_scripts
        Signal::TERM.reset
        STDERR.puts "--- TERM ---"
        Process.kill(Signal::TERM, Process.pid)
      end

      Dir.cd da_dir
      pid_file = "tmp/out/watch_pid.txt"
      Dir.mkdir_p File.dirname(pid_file)

      this_pid = Process.pid

      if File.exists?(pid_file)
        old = File.read(pid_file).strip
        cmdline_file = "/proc/#{old}/cmdline"
        if File.exists?(cmdline_file) && old.to_i != Process.pid.to_i && File.read(cmdline_file)[/da\ +watch/]?
          DA.red! "!!! {{Already running}}: pid BOLD{{#{old}}}"
          exit 1
        end
      end # if

      File.write(pid_file, this_pid.to_s)

      system("reset")

      puts "=== #{Process.pid}"
      DA.orange!("-=-= BOLD{{Watching}}: #{File.basename Dir.current} {{@}} #{time} #{"-=" * 10}")

      pattern = "tmp/out/__*.sh"
      Dir.glob(pattern).each { |f|
        if File.file?(f)
          DA.orange! "=== Ignoring previous file: #{File.read(f).split('\n').first?} (#{f})"
          FileUtils.rm(f)
        end
      }

      spawn {
        loop {
          Dir.glob(pattern).each { |raw_file|
            file = File.expand_path(raw_file)
            next if !File.file?(file)
            DA.orange! "=== Running: {{#{file}}} in {{#{Dir.current}}} #{"-=" * 6}"

            raw = File.read(file).strip
            if raw[/Error: /i]?
              DA.red! raw
              FileUtils.rm(file)
              next
            end

            raw_lines = raw.split('\n').map(&.strip)
            dir, script_file = raw_lines
            key = dir

            Dir.cd(dir) {
              # Kill previous script:
              script = SCRIPTS[key]?
              if script && script.running?
                STDERR.puts "=== Killing: #{key}"
                script.kill(Signal::INT)
                sleep 0.5
              end

              # Setup new script:
              script = SCRIPTS[key] = Script.new(dir, script_file)
              DA.orange!("=== removing: {{#{file}}}") if script && script.debug?
              FileUtils.rm(file)

              begin
                script.run
              rescue e
                DA.inspect! e
              end
            } # Dir.cd
          } # files.each
          sleep 0.5
        } # loop
      } # spawn

      sleep
    end # === def watch

    def mtime(file)
      File.stat(file).mtime
    end # === def mtime

    def kill_scripts
      SCRIPTS.each { |x, script| script.kill }
    end

    def kill_procs
      PROCESSES.each { |file_name, x|
        if process_exists?(x.pid)
          STDERR.puts "=== kill -INT #{x.pid}"
          x.kill(Signal::INT)
          STDERR.puts "--- send INT signal #{x.pid}"
        else
          STDERR.puts "=== no exit #{x.pid}"
        end
      }
    end

    def process_exists?(pid : Int32)
      return false if !Process.exists?(pid) || defunct?(pid)
      Process.exists?(pid)
    end # === def process_exists?

    def defunct?(pid : Int32)
      data = IO::Memory.new
      Process.new("ps", "--no-headers --pid #{pid}".split, output: data, error: data)
      sleep 0.1
      data.rewind
      line = data.to_s
      line["<defunct>"]?
    end

    def process_still_running?
      return false if PROCESSES.empty?
      PROCESSES.any? { |file, x| process_exists?(x.pid) }
    end

    def bin_compile(args)
      case
      when File.exists?("bin/__.cr")
        DA::Crystal.bin_compile(args)
      else
        STDERR.puts "!!! No acceptable bin file found in ./bin directory."
        Process.exit 2
      end
    end # === def

  end # === module
end # === module DA
