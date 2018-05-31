
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

  def system!(cmd : String, args : Array(String))
    if STDOUT.tty?
      orange!("=== {{Running}}: BOLD{{#{cmd}}} #{args.join ' '}")
    end

    system(cmd, args)
    success! $?
  end

end # === module DA
