
module DA_HTML

  module Printer

    getter file_dir : String
    getter io       : IO_HTML = IO_HTML.new
    getter doc      : Doc

    def initialize(raw : String, @file_dir)
      {% begin %}
        @doc = Doc.new({{@type}}::Parser.new(raw).parse)
      {% end %}
    end # === def initialize

    def initialize(arr : DOC | Array(Instruction), @file_dir)
      @doc = Doc.new(arr)
    end # === def initialize

    def capture(new_io : IO_HTML)
      old_io = @io
      @io = new_io
      yield @io
      @io = old_io
      new_io
    end # === def capture

    def to_html(i : Instruction)
      action = i.first
      case action
      when "doctype!"
        io.raw! i.last

      when "open-tag"
        if doc.current? && doc.current.attr?
          io.open_tag_attrs(i.last)
        else
          io.open_tag(i.last)
        end

      when "attr"
        io.write_attr(i[1], i.last)
        if doc.current? && !doc.current.attr?
          io.close_attrs
        end

      when "text"
        io.write_text(i.last)

      when "close-tag"
        io.close_tag(i.last)

      else
        raise Exception.new("Unknown instruction: #{action.inspect}")

      end # === case action
    end # === def print

    def to_html
      while doc.current?
        to_html(doc.grab_current)
      end
      io.to_s
    end # === def to_html

  end # === module Printer

end # === module DA_HTML
