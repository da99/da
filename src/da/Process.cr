
module DA

  @@IS_INTERACTIVE : Bool? = nil

  def process_dir : String
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

  def interactive_session
    if interactive_session?
      yield
    else
      false
    end
  end # === def interactive_session

  def interactive_session? : Bool
    if @@IS_INTERACTIVE == nil
      @@IS_INTERACTIVE = (`tty`.strip != "not a tty")
    end

    ans = @@IS_INTERACTIVE
    case ans
    when Bool
      ans
    else
      false
    end
  end

  def run_command!(cmd : String)
    args = cmd.split
    bin  = args.shift
    run_command!(bin, args)
  end

  def run_command!(cmd : String, args : Array(String))
    interactive_session {
      orange!("=== {{Running}}: BOLD{{#{cmd}}} #{args.join ' '}")
    }

    system(cmd, args)
    status = $?
    DA_Process.success!($?)
  end

end # === module DA
