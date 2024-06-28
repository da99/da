
module DA

  def until_done(x, max : Int32 = 100)
    old_val = x
    new_val = yield(x)
    counter = 0
    while old_val != new_val && counter < max
      old_val = new_val
      new_val = yield(new_val)
      counter += 1
    end
    if old_val != new_val
      raise Exception.new("until_done: Reached max of #{max}.")
    end
    new_val
  end # === def

end # === module DA
