
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

    def to_html
      to_html(IO::Memory.new).to_s
    end # === def

    def to_html(io)
      io
    end # === def

  end # === class Comment
end # === module DA_HTML
