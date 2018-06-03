
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
  end

  def success?(full_cmd : String)
    args = full_cmd.split
    bin = args.shift
    `#{full_cmd}`
    success? $?
  end

  def system!(cmd : String)
    args = cmd.split
    bin  = args.shift
    system!(bin, args)
  end

  def success!(full_cmd : String)
    args = full_cmd.split
    cmd = args.shift
    success!(cmd, args)
  end # === def success!

  def success!(cmd : String, args : Arrray(String))
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

  def system!(cmd : String, args : Array(String))
    if STDOUT.tty?
      orange!("=== {{Running}}: BOLD{{#{cmd}}} #{args.join ' '}")
    end

    system(cmd, args)
    success! $?
  end

end # === module DA
