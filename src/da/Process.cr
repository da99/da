
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

  def exit!(stat : Process::Status)
    return false if DA_Process.success?(stat)
    red! "!!! {{Exit}}: BOLD{{#{stat.exit_code}}}"
    red! "!!! {{Exit Signal}}: BOLD{{#{stat.exit_signal}}}" if stat.signal_exit?
    Process.exit stat.exit_code
    true
  end

  def success?(full_cmd : String)
    args = full_cmd.split
    bin = args.shift
    `#{full_cmd}`
    success? $?
  end

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

  def output!(full_cmd : String)
    args = full_cmd.split
    cmd = args.shift
    output!(cmd, args)
  end

  def output!(*args)
    output = IO::Memory.new
    status = Process.run(*args, output: output, error: STDERR)
    if !success?(status)
      DA.red! "!!! BOLD{{Failed}}: {{#{args.join ' '}}}"
    end
    success! status
    output.rewind
    output
  end # def output!

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
