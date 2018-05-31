
module DA
  def which!(name : String)
    system("which #{name}")
    status = $?
    if status.exit_status != 0
      DA.exit_with_error! status.exit_status, "!!! Not found: #{name}"
    end
  end
end # === module DA
