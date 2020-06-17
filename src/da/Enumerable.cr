
module DA
  extend self
  def each_after(e, target)
    index = case target
            when Proc
              e.index { |x| target.call(x) }
            else
              e.index(target)
            end
    if index == nil
      e.each { |x| yield x }
    else
      index = index || -1
      e.each_with_index { |x, i|
        next if i <= index
        yield x
      }
    end
  end # def

  def each_until(e, target)
    index = case target
            when Proc
              e.index { |x| target.call(x) }
            else
              e.index(target)
            end
    if index == nil
      e.each { |x| yield x }
    else
      index = index || -1
      e.each_with_index { |x, i|
        next if i >= index
        yield x
      }
    end
  end # def
end # === module
