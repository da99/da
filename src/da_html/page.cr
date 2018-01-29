
module DA_HTML

  struct Page

    @io = IO::Memory.new

    def to_html
      @io.to_s
    end

    def p(*args)
      open_and_close_tag('p', *args) {
        with self yield
      }
    end # === def p

    def text(raw : String)
      @io << raw
    end # === def text

    def strong(content : String)
      open_and_close_tag("strong") {
        text content
      }
    end # === def strong

    def open_and_close_tag(name : Char | String, *args)
      @io << '<' << name << '>'
      with self yield
      @io << '<' << '/' << name << '>'
    end # === def write_closed_tag

  end # === struct Page

end # === module DA_HTML
