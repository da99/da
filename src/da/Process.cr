
module DA

  def app_dir : String
    exec_path = Process.executable_path
    if exec_path
      dir = File.dirname(exec_path)
      if File.basename(dir) == "bin"
        File.dirname(dir)
      else
        dir
      end
    else
      Dir.current
    end
  end # def app_dir

  def app_dir(*args : String)
    File.join(*args)
  end # === def app_dir

  # =============================================================================

  def exit_with_error!(msg : String, exit_code : Int32)
    orange! msg
    exit_with_error!(exit_code, msg)
  end

  def exit_with_error!(exit_code : Int32, msg : String)
    orange! msg
    exit! exit_code
  end

  def exit_with_error!(msg : String)
    exit_with_error!(2, msg)
  end # === def self.error

  def exit_on_error(*args)
    output = IO::Memory.new
    error  = IO::Memory.new
    status = Process.run(*args, output: output, error: error, input: STDIN)
    output.rewind
    return output.rewind if process_success?(status)
    error.rewind
    STDOUT.puts output unless output.empty?
    STDERR.outs error.rewind unless error.empty?
    exit! status
  end # === def system(*args)

  # =============================================================================

  def exit!(exit_code : Int32)
    if exit_code >= 0 && exit_code <= 255
      exit exit_code
    end
    orange! "!!! Undefined exit code found: #{exit_code}"
    orange! "!!! Read more about it: https://unix.stackexchange.com/questions/394639/why-do-high-exit-codes-on-linux-shells-256-not-work-as-expected"
    exit 1
  end # === def exit!(i : int32)

  def exit!(stat : Process::Status)
    return false if success?(stat)
    red! "!!! {{Exit}}: BOLD{{#{stat.exit_code}}}"
    red! "!!! {{Exit Signal}}: BOLD{{#{stat.exit_signal}}}" if stat.signal_exit?
    exit stat.exit_code
    true
  end

  # =============================================================================

  def success?(stat : Process::Status)
    stat.success?
  end

  def success?(full_cmd : String)
    args = full_cmd.split
    bin  = args.shift
    if STDOUT.tty? && STDERR.tty?
      DA.orange! "=== {{Running}}: #{full_cmd}"
    end
    status = Process.run(bin, args)
    success? status
  end

  def success!(s : Process::Status)
    return true if success?(s)
    exit! s
  end # === def process_success!

  def success!(full_cmd : String)
    args = full_cmd.split
    cmd = args.shift
    success!(cmd, args)
  end # === def success!

  def success!(cmd : String, args : Array(String))
    output = IO::Memory.new
    error = IO::Memory.new
    status = Process.run(cmd, args, output: output, error: error)
    if !success?(status)
      output.rewind
      error.rewind
      DA.red! "=== {{Failed}}: BOLD{{#{cmd}}} #{args.join ' '}"
      STDOUT.puts(output) unless output.empty?
      STDERR.puts(error) unless error.empty?
      exit! status
    end
    status
  end # def success!

  def system!(cmd : String)
    args = cmd.split
    bin  = args.shift
    system!(bin, args)
  end

  def system!(cmd : String, args : Array(String))
    if STDOUT.tty?
      orange!("=== {{Running}}: BOLD{{#{cmd}}} #{args.join ' '}")
    end

    system(cmd, args)
    success! $?
  end

  # =============================================================================

  def run(full_cmd : String)
    args = full_cmd.split
    cmd = args.shift
    run(cmd, args)
  end # === def run

  def run(cmd : String, args : Array(String))
    DA.orange! "=== {{Running}}: BOLD{{#{cmd}}} #{args.flatten.join ' '}"
    Process.run(cmd, args)
  end # === def run

  # =============================================================================

  def output(*args)
    output = IO::Memory.new
    Process.run(*args, output: output, error: STDERR)
    output.rewind
    output.to_s.strip
  end # def output!

  def output!(full_cmd : String)
    args = full_cmd.split
    cmd = args.shift
    output!(cmd, args)
  end

  def output!(*args) : String
    output = IO::Memory.new

    status = Process.run(*args, output: output, error: STDERR)
    if !success?(status)
      DA.red! "!!! BOLD{{Failed}}: {{#{args.join ' '}}}"
      exit! status
    end

    output.rewind
    output.to_s.strip
  end # def output!

  # =============================================================================

  def process_new(*args)
    Child_Process.new(*args)
  end

  struct Child_Process

    getter output = IO::Memory.new
    getter error  = IO::Memory.new
    getter cmd    : String
    getter args   : Array(String)
    getter status : Process::Status

    def initialize(full_cmd : String)
      @args = full_cmd.split
      @cmd = @args.shift
      @status = Process.run(@cmd, @args, output: @output, error: @error)
      @output.rewind
      @error.rewind
    end # === def initialize

    def initialize(@cmd : String, @args : Array(String))
      @status = Process.run(@cmd, @args, output: @output, error: @error)
      @output.rewind
      @error.rewind
    end # === def initialize

    def success?
      DA.success? @status
    end # === def success?

  end # === struct Child_Process

end # === module DA
