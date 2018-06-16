
module DA
  module Dev
    extend self

    CMD_ERRORS = [] of Int32 | String

    MTIMES    = {} of String => Int64
    PROCESSES = {} of Int32 => Process

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
      full_cmd = if args.empty?
                   da_cmd
                 else
                   args.join(' ')
                 end
      cmd = args.shift? || da_cmd

      case

      when da_cmd == "#"
        DA.orange! "=== {{Skipping}}: #{full_cmd}"

      # when cmd == "reload" && args.empty?
      #   kill_procs
      #   run_process_status
      #   File.delete(pid_file) if File.exists?(pid_file)
      #   Process.exec(bin_path, ARGV)

      when da_cmd == "proc"
        DA.orange! "=== {{Process}}: BOLD{{#{full_cmd}}}"
        # args = "echo a".split
        x = Process.new(args.shift, args, output: STDOUT, input: STDIN, error: STDERR)
        PROCESSES[x.pid] = x
        STDERR.puts "=== New process: #{x.pid}"
        x

      when da_cmd == "PING" && args.empty?
        DA.orange! "=== {{Running}}: #{cmd} ==="
        DA.green! "=== PONG ==="

      when da_cmd == "run" && !args.empty?
        DA.bold! "=== {{#{full_cmd}}} (#{time})"

        # Only show progress output on error:
        system(cmd, args)
        stat = $?
        if !DA.success?(stat)
          DA.red! "!!! {{EXIT}}: BOLD{{#{stat.exit_code}}} (#{full_cmd})"
          return false
        end

      else
        DA.red! "=== {{Unknown command}}: BOLD{{#{full_cmd}}} ==="
        return false

      end # case

      true
    end # === def run

    def run_process_status
      PROCESSES.each { |pid, x|
        if defunct?(pid)
          STDERR.puts "=== Process defunct: #{pid}"
          PROCESSES.delete pid
        end
        if x.terminated?
          STDERR.puts "=== Process terminated: #{pid}"
          PROCESSES.delete pid
        end
      }
    end # === def run_process_status

    def watch_run(raw_file : String)
      app_dir = Dir.current
      run_file = File.expand_path(raw_file)
      Dir.cd da_dir
      new_file = "tmp/out/run-#{Time.now.epoch}.txt"
      if File.exists?(run_file)
        run_contents = [app_dir,File.read(run_file)].join('\n')
        if run_contents.empty?
          File.write(new_file, "run echo empty contents: #{raw_file}")
        else
          File.write(new_file, run_contents)
        end
      else
        File.write(new_file, "run echo File does not exist: #{raw_file}")
      end
    end # === def watch_run

    def watch_setup
      files = {} of String => Time?
      3.times { |i|
        x = i + 1
        f = "tmp/out/run.#{x}.txt"
        files[f] = File.exists?(f) ? mtime(f) : nil
      }
      Dir.mkdir_p("tmp/out")
    end # def

    def watch
      Dir.cd da_dir
      pid_file = "tmp/out/watch_pid.txt"
      Dir.mkdir_p File.dirname(pid_file)

      this_pid = Process.pid

      if File.exists?(pid_file)
        old = File.read(pid_file).strip
        if !old.empty? && old.to_i != this_pid && Process.exists?(old.to_i)
          DA.red! "!!! {{Already running}}: pid BOLD{{#{old}}}"
          exit 1
        end
      end # if

      File.write(pid_file, this_pid.to_s)

      system("reset")

      DA.orange!("-=-= BOLD{{Watching}}: #{File.basename Dir.current} {{@}} #{time} #{"-=" * 15}")

      spawn {
        loop {
          run_process_status
          sleep 1
        }
      }

      spawn {
        loop {
          Dir.glob("tmp/out/run-*.txt").each { |file|
            next if !File.file?(file)
            kill_procs
            lines = File.read(file).split('\n')
            dir = lines.shift
            Dir.cd(dir) {
              DA.orange! "=== in {{#{dir}}} #{"-=" * 20}"
              result = lines.each_with_index { |cmd, i|
                next if cmd.strip.empty?
                if !CMD_ERRORS.empty?
                  STDERR.puts "=== Skipping #{cmd} because of previous errors."
                  next
                end
                break if run_cmd(cmd.split) != true
                true
              }
              DA.orange!("-=" * 28)
            } # Dir.cd
            CMD_ERRORS.clear

            FileUtils.rm(file)
            puts ""
          } # files.each
          sleep 0.5
        } # loop
      } # spawn

      sleep
    end # === def watch

    def mtime(file)
      File.stat(file).mtime
    end # === def mtime

    def kill_procs
      PROCESSES.each { |pid, x|
        if process_exists?(pid)
          STDERR.puts "=== Killing: #{pid}"
          x.kill
        else
          STDERR.puts "=== Killed: #{pid}"
        end
      }

      3.times { |x|
        break if !process_still_running?
        sleep 1
      }

      PROCESSES.each { |pid, x|
        if defunct?(pid)
          STDERR.puts "!!! DEFUNCT: #{pid}"
        end
        if process_exists?(pid)
          STDERR.puts "!!! Still running: #{pid}"
        end
        if !Process.exists?(pid)
          STDERR.puts "=== Terminated: #{pid}"
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
      PROCESSES.any? { |pid, x| process_exists?(pid) }
    end

  end # === module Watch
end # === module DA
