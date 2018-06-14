
module DA

  def inspect!(*args)
    if is_development?
      STDERR.puts args.map(&.inspect).join(", ")
      return true
    end

    false
  end # === def inspect!

end # === module DA
