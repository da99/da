
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
    @has_open_tag = false
  end # === def initialize

  def open_tag?
    @has_open_tag
  end # === def open_tag?

  def open_tag
    raise Exception.new("Tag has not been closed.") if open_tag?
    @has_open_tag = true
    self
  end # === def open_tag

  def close_tag
    raise Exception.new("Tag is already closed.") if !open_tag?
    @has_open_tag = false
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


