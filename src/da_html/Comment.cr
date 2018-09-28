
module DA_HTML
  struct Comment

    getter tag_text : String
    getter index = 0

    def initialize(n : Myhtml::Node, @index)
      @tag_text = n.tag_text
    end # def

    def empty?
      @tag_text.strip.empty?
    end

    def tag_name
      "_comment"
    end # === def

  end # === class Comment
end # === module DA_HTML
