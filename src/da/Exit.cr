
module DA

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

  def exit!(exit_code : Int32)
    if exit_code >= 0 && exit_code <= 255
      Process.exit exit_code
    end
    orange! "!!! Undefined exit code found: #{exit_code}"
    orange! "!!! Read more about it: https://unix.stackexchange.com/questions/394639/why-do-high-exit-codes-on-linux-shells-256-not-work-as-expected"
    Process.exit 1
  end # === def exit!(i : int32)

  def success!(s : Process::Status)
    return true if success?(s)
    exit! s
  end # === def process_success!

  def success?(stat : Process::Status)
    is_fail = !stat.success? || !stat.normal_exit? || stat.signal_exit?
    !is_fail
  end

  def exit!(s : Process::Status)
    exit! s.exit_code
  end # === def exit!

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

end # === module DA
