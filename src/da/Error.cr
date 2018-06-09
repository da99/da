
module DA
  def exit!(x : Int32, *args : String)
    args.each { |s|
      STDERR.puts s
    }
    exit x
  end # === def exit!
end # === module DA
