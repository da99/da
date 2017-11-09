
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


module DA_HTML
  # === It's meant to be used within a Struct.
  module Parser

    extend Class_Methods

    macro included
      extend Class_Methods
    end # === macro included

    SEGMENT_ATTR_ID    = /([a-z0-9\_\-]{1,15})/
    SEGMENT_ATTR_CLASS = /[a-z0-9\ \_\-]{1,50}/
    SEGMENT_ATTR_HREF  = /[a-z0-9\ \_\-\/\.]{1,50}/

    getter file_dir : String
    getter io       : IO::Memory = IO::Memory.new
    @doc : DOC

    def initialize(@doc, @file_dir)
    end # === def initialize

    def run
      doc = Doc.new(@doc)
      while doc.current?
        old_pos = doc.pos
        render(doc)
        if old_pos == doc.pos
          raise Exception.new("Unknown instruction: #{doc.current.inspect}")
        end
      end
      self
    end # === def to_html

    def capture(new_io : IO::Memory)
      old_io = @io
      @io = new_io
      yield @io
      @io = old_io
      new_io
    end # === def capture

    def render(i : Instruction, doc : Doc)
      action = i.first
      case action
      when "doctype!"
        io << i.last
      when "open-tag"
        io << "<" << i.last
        if doc.next? && doc.next.first != "attr"
          io << ">"
        end
      when "attr"
        io << " " << i[1] << "=" << (DA_HTML_ESCAPE.escape(i.last) || "").inspect
        if doc.next? && doc.next.first != "attr"
          io << ">"
        end
      when "text"
        io << (DA_HTML_ESCAPE.escape(i.last) || "")
      when "close-tag"
        io << "</" << i.last << ">"
      else
        raise Exception.new("Unknown instruction: #{action.inspect}")
      end
      true
    end # === def render

    def render(doc : Doc)
      render(doc.current, doc)
      doc.move
    end # === def render

    def to_html
      run
      io.to_s
    end # === def to_html

  end # === module Parser

end # === module DA_HTML

