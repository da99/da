
module DA_HTML

  module Parser

    macro exception(name)
      class {{name.id}} < Exception
        def message
          "#{self.class.name}: #{@message}"
        end
      end # === class
    end # === macro exception

    exception Invalid_Attr_Value

  end # === module Parser

end # === module DA_HTML
