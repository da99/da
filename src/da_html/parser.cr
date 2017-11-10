
require "xml"

{% `mkdir -p tmp` %}
{% `rm -f tmp/da_html.tmp.*` %}
{% `touch tmp/da_html.tmp.tags` %}
{% `touch tmp/da_html.tmp.attrs` %}

module DA_HTML
  alias INSTRUCTION = Tuple(String, String) | Tuple(String, String, String)
  alias DOC = Array(INSTRUCTION)
end

require "./parser/exception"
require "./parser/template"
require "./parser/class_methods"
require "./parser/doc"
require "./io_html"

module DA_HTML
  # === It's meant to be used within a Struct.
  module Parser

    extend Class_Methods

    macro included
      extend Class_Methods
    end # === macro included


    getter file_dir : String
    getter io       : IO_HTML = IO_HTML.new
    getter doc : Doc

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

    def render(i : Instruction)
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
    end # === def render

    def to_html
      while doc.current?
        render(doc.grab_current)
      end
      io.to_s
    end # === def to_html

  end # === module Parser

end # === module DA_HTML

