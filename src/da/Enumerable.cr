
module DA
  extend self
  def each_after(e, target)
    found = false
    e.each { |x|
      if !found
        found = (x == target)
        next
      end
      yield x
    }
  end # def
end # === module
