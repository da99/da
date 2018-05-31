
module DA
  def which!(name : String)
    system("which #{name}")
    status = $?
    if status.exit_status != 0
      # whichs may exit with code 256, undefined exit code
      # Change it to 1 to make out lives simpler
      DA.exit_with_error! 1, "!!! Not found: #{name}"
    end
  end
end # === module DA
