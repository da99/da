
module DA

  def exit_with_error!(msg : String, exit_code : Int32)
    orange! msg
    exit_with_error!(exit_code, msg)
  end

  def exit_with_error!(exit_code : Int32, msg : String)
    orange! msg
    if exit_code >= 0 && exit_code <= 255
      Process.exit exit_code
    end

    orange! "!!! Undefined exit code found: #{exit_code}"
    orange! "!!! Read more about it: https://unix.stackexchange.com/questions/394639/why-do-high-exit-codes-on-linux-shells-256-not-work-as-expected"
    Process.exit 1
  end

  def exit_with_error!(msg : String)
    exit_with_error!(2, msg)
  end # === def self.error

end # === module DA
