
module DA_HTML
  struct Tag

    # =============================================================================
    # Instance:
    # =============================================================================

    getter tag_name   : String
    getter attributes = {} of String => Attribute_Value
    getter children   = Deque(Node).new

    def initialize(node : Myhtml::Node)
      @tag_name = node.tag_name
      node.attributes.each { |k, v| @attributes[k] = v }
      node.children.each { |c| @children.push DA_HTML.to_tag(c) }
    end # === def

    def void?
      {"area", "base", "br", "col", "command", "embed",
       "hr", "img", "input", "keygen", "link", "meta",
       "param", "source", "track", "wbr"}.includes? tag_name
    end # === def

  end # === struct Tag

end # === module DA_HTML
