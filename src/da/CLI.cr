
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

  module CLI
    macro print_doc
      {% begin %}
        delim      = '{'
        delim_end  = '}'
        doc_string = {{ system("cat bin/__.cr").lines.select { |x| x =~ /^\ *# === / && !(x =~ /={3,}$/) } }}
        bin_name   = "#{delim}#{delim}#{DA.bin_name}#{delim_end}#{delim_end}"

        puts doc_string.map { |x|
          DA.bold(
            x.gsub("#{delim}#{delim}CMD#{delim_end}#{delim_end}", bin_name).gsub(/^\ *# === /, "  ")
          )
        }.join('\n')
      {% end %}
    end
  end # === module CLI

end # === module DA
