
module DA

  def exit_with_error!(msg : String, exit_code : Int32)
    orange! msg
    Process.exit exit_code
  end

  def exit_with_error!(exit_code : Int32, msg : String)
    orange! msg
    Process.exit exit_code
  end

  def exit_with_error!(msg : String)
    error(2, msg)
  end # === def self.error

end # === module DA
