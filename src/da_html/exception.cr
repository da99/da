
module DA_HTML

  macro exception(name)
    class {{name.id}} < Exception
      def message
        "#{self.class.name}: #{@message}"
      end
    end # === class
  end # === macro exception

  exception Invalid_Attr_Value

  class Invalid_Doctype < Exception

    def initialize(node : XML::Node)
      @message = node.to_s
    end # === def initialize

  end # === class Invalid_Doctype

  class Invalid_Text < Exception

    def initialize(@message)
    end # === def initialize

    def initialize(node : XML::Node)
      @message = node.content.inspect
    end # === def initialize

    def message
      "Invalid tag: #{@message}"
    end
  end # === class Invalid_Tag

  class Invalid_Tag < Exception

    def initialize(@message)
    end # === def initialize

    def initialize(node : XML::Node)
      @message = node.name
    end # === def initialize

    def message
      "Invalid tag: #{@message}"
    end
  end # === class Invalid_Tag

  class Invalid_Attr < Exception
    def initialize(@message)
    end # === def initialize

    def initialize(tag : XML::Node, attr : XML::Node)
      @message = "tag: #{tag.name}, attr: #{attr.name} value: #{attr.content.inspect}"
    end # === def initialize

    def message
      "Invalid attribute: #{@message}"
    end

  end # === class Invalid_Attr

end # === module DA_HTML

