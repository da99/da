
module DA_HTML

  class Error < Exception
  end # === class Error

  macro exception(name)
    class {{name.id}} < Exception
      def message
        "#{self.class.name}: #{@message}"
      end
    end # === class
  end # === macro exception

  exception Invalid_Attr_Value

  class Invalid_Printing < Error
  end # === class Invalid_Printing

  class Invalid_Doctype < Error

    def initialize(node : XML::Node)
      @message = node.to_s
    end # === def initialize

    def initialize(@message : String)
    end # === def initialize

    def message
      "Invalid Doctype: #{@message}"
    end

  end # === class Invalid_Doctype

  class Invalid_Text < Error

    def initialize(@message)
    end # === def initialize

    def initialize(node : XML::Node)
      @message = node.content.inspect
    end # === def initialize

    def message
      "Invalid text: #{@message}"
    end
  end # === class Invalid_Tag

  class Invalid_Tag < Error

    def initialize(@message)
    end # === def initialize

    def initialize(node : XML::Node)
      @message = "#{node.type.inspect} (#{node.to_s.inspect})"
    end # === def initialize

    def message
      "Invalid tag: #{@message}"
    end
  end # === class Invalid_Tag

  class Invalid_Attr < Error
    def initialize(@message)
    end # === def initialize

    def initialize(attr : DA_HTML::Instruction)
      @message = "attr: #{attr.attr_name} value: #{attr.attr_content}"
    end # === def initialize

    def initialize(tag : XML::Node, attr : XML::Node)
      @message = "tag: #{tag.name}, attr: #{attr.name} value: #{attr.content.inspect}"
    end # === def initialize

    def message
      "Invalid attribute: #{@message}"
    end

  end # === class Invalid_Attr

end # === module DA_HTML

