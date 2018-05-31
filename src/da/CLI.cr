
module DA

  def argv?(args : Array(String), *types)
    return false if args.size != types.size
    types.each_with_index { |v, i|
      case
      when args[i] == v
        next
      when args[i].class == v
        next
      else
        return false
      end
    }

    true
  end # === def argv?

end # === module DA
