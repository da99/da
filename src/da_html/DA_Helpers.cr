
module DA_Helpers

  extend self

  macro if_not_nil(name, &blok)
    %x = {{name}}
    case %x
    when Nil
      nil
    else
      DA_Helpers.yield_value(%x) {{blok}}
    end
  end # === macro if_not_nil

  macro if_string(*args, &blok)
    %x = begin
           {{*args}}
         end
    case %x
    when String
      DA_Helpers.yield_value(%x) {{blok}}
    end
  end # === macro if_string

  def yield_value(x)
    yield x
  end

end # === module DA_Helpers
