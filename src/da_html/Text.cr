
module DA_HTML
  class Text

    getter tag_text : String
    getter index    = 0

    def initialize(n : Myhtml::Node, @index)
      @tag_text = n.tag_text
    end # === def

    def empty?
      @tag_text.strip.empty?
    end

    def tag_name
      "-text"
    end

    def to_html
      to_html(IO::Memory.new).to_s
    end # === def

    def to_html(io)
      io << DA_HTML_ESCAPE.escape(tag_text)
      io
    end # === def

  end # === struct Text
end # === module DA_HTML
