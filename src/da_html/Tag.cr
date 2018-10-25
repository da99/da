
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

    def tag_text
      String.build { |b|
        children.each { |c|
          case c
          when Text, Tag, Comment
            b << c.tag_text
          end
        }
      }
    end

    def text_only?
      children.size == 1 && children.first.is_a?(Text)
    end

    def comment_only?
      children.size == 1 && children.first.is_a?(Comment)
    end

    def inspect(io)
      io << "<#{tag_name}"
      if !attributes.empty?
        io << ' '
        if attributes.values.all? { |v| v.is_a?(String) && v.strip.empty? }
          io << attributes.keys.join(' ')
        else
          io << attributes.map { |k, v| "#{k}=#{v.to_s.inspect}" }.join(' ').strip
        end
      end
      io << '>'
      io
    end # def

  end # === struct Tag

end # === module DA_HTML
