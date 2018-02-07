
module DA_Helpers

  macro ignore_nil(name, &blok)
    %x = {{name}}
    case %x
    when Nil
      nil
    else
      yield_value(%x) {{blok}}
    end
  end # === macro ignore_nil

  def yield_value(x)
    yield x
  end

end # === module DA_Helpers
