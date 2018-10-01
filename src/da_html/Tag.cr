
module DA_HTML
  struct Tag

    # =============================================================================
    # Instance:
    # =============================================================================

    getter tag_name   : String
    getter index      = 0
    getter attributes = {} of String => Attribute_Value
    getter children   = [] of Node

    def initialize(node : Myhtml::Node, @index = 0)
      @tag_name = node.tag_name
      node.attributes.each { |k, v| @attributes[k] = v }
      node.children.each_with_index { |c, i| @children.push DA_HTML.to_tag(c, index: i) }
    end # === def

    def initialize(
      @tag_name : String,
      @index,
      attributes,
      children : Array(Tag | Text) = [] of Tag | Text,
      text : String? = nil,
    )
      if attributes
        attributes.each { |k, v| @attributes[k] = v }
      end

      if children
        children.each { |c| @children.push c }
      end

      if text
        @children.push Text.new(text, index: children.size)
      end
    end # === def

    def tag_text
      if children.empty?
        nil
      else
        children.first.tag_text
      end
    end

    def empty?
      children.empty?
    end

  end # === struct Tag

end # === module DA_HTML
