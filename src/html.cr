
require "./html/element"
require "./html/attr.id"
require "./html/attr.class"
require "./html/attr.href"
require "./html/span"

class HTML

  module Class_Methods

    def to_html
      h = HTML.new
      with h yield
      h.io.to_s
    end # === def to_html

    def to_io
      h = HTML.new
      with h yield
      h.io
    end # === def to_html

  end # === module Class_Methods

  extend Class_Methods

  def initialize
    @content = IO::Memory.new
    @attrs_being_written = false
  end # === def initialize

  def open_attrs?
    @attrs_being_written
  end # === def open_attrs?

  def open_tag(name : Symbol)
    raise Exception.new("Opening tags during attrs being written.") if open_attrs?
    @content << "\n<" << name.to_s
    @attrs_being_written = true
    self
  end # === def open_tag

  def close_tag
    @attrs_being_written = false
    self
  end # === def close_tag

  def io
    @content
  end # === def io

  def <<(s : String)
    @content << s
  end # === def <<(s : String)

  def <<(io : IO::Memory)
    io.to_s @content
    self
  end # === def <<(s : String)

  def to_html
    @content.to_s
  end # === def to_html

  def push(s : IO::Memory)
    s.to_s(@content)
    self
  end

end # === class HTML


