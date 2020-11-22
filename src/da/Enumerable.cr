
module DA
  extend self

  def round_about(e, target)
    index = case target
            when Proc
              e.index { |x| target.call(x) }
            else
              e.index(target)
            end

    if index == nil
      e.each { |x| return x if yield(x) }
    else
      index = index.not_nil!
      e.each_with_index { |x, i|
        next if i <= index
        return x if yield x
      }

      e.each_with_index { |x, i|
        return nil if i >= index
        return x if yield x
      }
    end
  end # def

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
