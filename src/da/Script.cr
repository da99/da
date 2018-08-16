
module DA
  class Script

    @dir     : String
    @file    : String
    @debug   : Bool = false
    @running : Bool = false
    @done    : Bool = false

    getter owner : String
    getter procs : Deque(Process) = Deque(Process).new

    def initialize(raw_dir : String, raw_file : String)
      @dir  = File.expand_path(raw_dir)
      @file = File.expand_path(raw_file)
      @owner = `whoami`.strip
    end # === def

    def initialize(raw_file : String)
      @dir  = Dir.current
      @file = File.expand_path(raw_file)
      @owner = `whoami`.strip
    end # === def

    def done?
      @done && procs.all? { |x| !Process.exists?(x.pid) }
    end

    def running?
      @running
    end

    def debug?
      @debug
    end

    def kill(sig = Signal::TERM)
      script_owner = owner
      @procs.each { |proc|
        proc_owner = `ps -o user= -p #{proc.pid}`.strip
        proc_still_running = !proc_owner.empty?
        if proc_still_running
          sleep 1
          if proc_owner == script_owner
            STDERR.puts "::: Killing #{proc.pid}" if debug?
            proc.kill(sig)
          else
            STDERR.puts "::: Killing as root: #{proc.pid}" if debug?
            DA.success! "sudo", "kill -#{sig} #{proc.pid}".split
          end
        end
      }
      @running = false
    end # === def

    def compile_args(args : Array(String))
      args.map { |x|
        case x
        when "$PWD"
          Dir.current
        else
          x
        end
      }
    end

    def run
      @running = true
      File.read(@file).each_line { |raw_line|
        line = raw_line.strip
        next if line.empty?
        tokens = line.split
        cmd = tokens.shift
        tokens = compile_args(tokens)

        case
        when cmd == "echo"
          if debug?
            STDERR.puts "::: echo"
          end
          compile_args(tokens).each_with_index { |x, i|
            STDOUT << ' ' if i != 0
            STDOUT << x
          }
          STDOUT << '\n'
          STDOUT.flush

        when cmd == "debug"
          setting = tokens.first?
          if tokens.size != 1
            raise Exception.new("Invalid values for debug: #{tokens.inspect}")
          end

          case setting
          when "on"
            @debug = true
          when "off"
            @debug = false
          else
            raise Exception.new("Invalid values for debug: #{setting}")
          end

        when cmd == "process"
          raise Exception.new("No arguments for process.") if tokens.size < 1
          bin = tokens.shift
          args = tokens
          process = Process.new(
            bin,
            args,
            input:  Process::Redirect::Inherit,
            output: Process::Redirect::Inherit,
            error:  Process::Redirect::Inherit
          )
          if debug?
            DA.orange! "=== PROCESS BOLD{{#{process.pid}}}: {{#{bin}}} BOLD{{#{args.join ' '}}}"
          end
          @procs.push(process)

        when cmd == "cd"
          if tokens.size != 1
            raise Exception.new("Invalid arguments for cd: #{tokens.inspect}")
          end
          dir = tokens.shift
          Dir.cd(dir)
          STDERR.puts "::: cd: #{dir}" if debug?

        when cmd == "sleep"
          if tokens.size != 1
            raise Exception.new("Invalid argument for sleep: #{tokens.inspect}")
          end
          setting = tokens.first
          if !setting[/^\d{1,5}$/]?
            raise Exception.new("Invalid argument for sleep: #{setting}")
          end

          STDERR.puts "::: sleep #{setting}" if debug?
          sleep setting.to_i

        when cmd[0]? == '#' # Comment
          next

        else
          STDERR.puts "::: custom command: #{raw_line}" if debug?
          stat = Process.run(
            cmd,
            tokens,
            input:  Process::Redirect::Inherit,
            output: Process::Redirect::Inherit,
            error:  Process::Redirect::Inherit
          )
          if !DA.success?(stat)
            raise Exception.new("Command failed: #{stat.exit_code}")
          end

        end # case
      } # .each_line

      @done = true
    end # === def

  end # === module Script
end # === module DA