
require "file_utils"

module DA

  def self.test?
    (ENV["IS_TEST"]? || "").upcase == "YES"
  end

  def self.debug?
    (ENV["IS_DEBUG"]? || "").upcase == "YES"
  end

  def self.debug(*args)
    if debug?
      args.each { |x| puts x }
      return true
    end
    false
  end # def

  def self.development?
    (ENV["IS_DEVELOPMENT"]? || "").upcase == "YES"
  end # === def

  def self.inspect!(*args)
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
      bin_dir = File.dirname(::Process.executable_path.not_nil!)
      File.dirname(bin_dir)
    end

    def pid_file
      bin_dir = File.dirname(::Process.executable_path.not_nil!)
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
        _i = ::Process::Redirect::Inherit
        x = ::Process.new(args.shift, args, output: _i, input: _i, error: _i)
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

      File.write(new_file, %<
        #{app_dir}
        #{file_path}
      >.strip)
    end # === def watch_run

    def watch
      if `pgrep -a -f "da watch" | wc -l`.strip.to_i > 2
        DA.red! "{{Process already exists}}:"
        puts `pgrep -a -f "da watch"`.strip
        exit 2
      end

      `mkdir -p /apps/da/tmp`

      Dir.cd da_dir

      system("reset")

      puts "=== #{::Process.pid}"
      DA.orange!("-=-= BOLD{{Watching}}: #{File.basename Dir.current} {{@}} #{time} #{"-=" * 10}")

      pattern = "tmp/out/__*.sh"

      # Remove any previous scripts:
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

            raw = File.read(file).strip
            FileUtils.rm(file)
            if raw[/Error: /i]?
              DA.red! raw
              FileUtils.rm(file)
              next
            end

            begin
              dir, script_file = raw.split('\n').map(&.strip)
            rescue e : IndexError
              STDERR.puts "=== Error in reading file: #{raw.inspect}"
              next
            end

            key = dir
            DA.orange! "\n============ {{#{Dir.current}}} #{"-=" * 6}"

            Dir.cd(dir) {
              # Kill previous script:
              begin
                if File.read(script_file).strip.empty?
                  DA.orange! "=== {{File was empty}}: #{script_file} ==="
                  DA.green! "============ {{DONE}} ============"
                else
                  proc = DA::Process::Inherit.new(["zsh", "-e", "-u", "--pipefail", script_file])
                  if proc.success?
                    DA.green! "============ {{DONE}} ============"
                  else
                    DA.red! "=== {{FAILED}}: #{proc.status.exit_code} ==="
                  end
                end
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
      return false if !::Process.exists?(pid) || defunct?(pid)
      ::Process.exists?(pid)
    end # === def process_exists?

    def defunct?(pid : Int32)
      data = IO::Memory.new
      ::Process.new("ps", "--no-headers --pid #{pid}".split, output: data, error: data)
      sleep 0.1
      data.rewind
      line = data.to_s
      line["<defunct>"]?
    end

    def process_still_running?
      return false if PROCESSES.empty?
      PROCESSES.any? { |file, x| process_exists?(x.pid) }
    end

    def build
      langs = [] of String
      if File.exists?("bin/__.cr")
        DA::Process::Inherit.new("shards build -- --warnings all --release".split).success!
        langs << "crystal"
      end
      langs
    end # === def

  end # === module
end # === module DA
