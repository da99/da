
module DA_HTML

  class Error < Exception
  end # === class Error

  class Invalid_Attr_Value < Error
    def initialize(@message)
    end # === def initialize

    def initialize(tag_name, key, val)
      @message = "#{tag_name} #{key}=#{val.inspect}"
    end # === def initialize

    def initialize(tag_name, val)
      @message = "#{tag_name} #{val.inspect}"
    end # === def initialize
  end # === class Invalid_Attr_Value

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
  end # === class Invalid_Text

  class Invalid_Tag < Error
  end # === class Invalid_Tag

  class Invalid_Attr < Error
  end # === class Invalid_Attr

end # === module DA_HTML

