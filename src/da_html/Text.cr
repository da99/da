
module DA_HTML
  class Text

    getter tag_text : String
    getter index    = 0
    getter parent   : Tag? = nil
    @is_comment = false

    def initialize(n : Myhtml::Node, @parent, @index)
      @is_comment = n.tag_name == "_comment"
      @tag_text = n.tag_text
    end # === def

    def initialize(@tag_text, @parent, @index, @is_comment)
    end # === def

    def empty?
      @tag_text.strip.empty?
    end

    def to_html
      @tag_text
    end

    def text?
      true
    end

    def comment?
      @is_comment
    end

    def tag_text(s : String)
      @tag_text = s
    end

    def map_walk!(&blok : Node -> Node | Nil)
      blok.call self
    end # === def

  end # === struct Text
end # === module DA_HTML
