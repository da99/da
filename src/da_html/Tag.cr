
module DA_HTML

  class Tag

    # =============================================================================
    # Instance:
    # =============================================================================

    getter tag_name : String
    getter parent   : Tag? = nil
    getter index      = 0
    getter attributes = {} of String => Attribute_Value
    getter children   = [] of Tag | Text

    @end_tag : Bool

    def initialize(node : Myhtml::Node, @index = 0)
      @tag_name = node.tag_name
      @end_tag = case @tag_name
                 when "input"
                   false
                 else
                   true
                 end
      node.attributes.each { |k, v| @attributes[k] = v }
      node.children.each_with_index { |c, i| @children.push DA_HTML.to_tag(c, parent: self, index: i) }
    end # === def

    def initialize(
      @tag_name : String,
      @index,
      attributes,
      children : Array(Tag | Text) = [] of Tag | Text,
      @end_tag : Bool = true,
      text : String? = nil,
    )
      if attributes
        attributes.each { |k, v| @attributes[k] = v }
      end

      if children
        children.each { |c| @children.push c }
      end

      if text
        @children.push Text.new(text, parent: self, index: children.size)
      end
    end # === def

    def attributes(x)
      @attributes = {} of String => Attribute_Value
      x.each { |k, v|
        @attributes[k] = v
      }
      @attributes
    end # === def

    def tag_text
      if children.empty?
        nil
      else
        children.first.tag_text
      end
    end

    def tag_text(s : String)
      if children.size == 1
        children.pop
      end
      children.push Text.new(s, parent: self, index: children.size, is_comment: false)
      @children
    end # def

    def end_tag?
      @end_tag
    end

    def empty?
      children.empty?
    end

    def text?
      false
    end

    def comment?
      false
    end

    def map_walk!(&blok : Node -> Node | Nil)
      result = blok.call(self)
      case result
      when Tag
        new_children = [] of Node
        result.children.each { |c|
          r = c.map_walk!(&blok)
          case r
          when Tag, Text
            new_children.push r
          end
        }
        @tag_name = result.tag_name
        @attributes = result.attributes
        @children = new_children
        return self
      end
      result
    end # === def

  end # === struct Tag

end # === module DA_HTML
