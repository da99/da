
require "da_html_escape"
require "./da_html/attrs/id_class"

module DA_HTML

  def self.prettify(str : String)
    indent = 0
    str.gsub( /\>\<([a-z\/])/ ) { |s, x|
      case x[1]
      when "/"
        indent -= 1
        ">\n#{" " * (indent)}</"
      else
        indent += 1
        ">\n#{" " * indent}<#{x[1]}"
      end
    }
  end # === def pretty_html

  struct Raw
    def initialize(@val : Symbol | String)
    end # === def initialize

    def value
      @val
    end # === def value
  end

  class Io

    include DA_HTML::ID_CLASS

    @attrs_open : Bool

    def initialize
      @io = IO::Memory.new
      @attrs_open = false
    end # === def initialize

    def <<(*args)
      @io.<<(*args)
      self
    end # === def <<

    def render_attr!(name : String, val : String)
      raise Exception.new("Tag is not open for attribute: #{name.inspect}=#{val.inspect}") unless @attrs_open
      @io << " " << name << "=" << val.inspect
      self
    end # === def render_attr

    def render_text!(s : String)
      close_attrs
      @io << DA_HTML_ESCAPE.escape(s)
    end # === def render_text!

    def close_attrs
      if @attrs_open
        @io << ">"
        @attrs_open = false
      end
    end # === def close_attrs

    def render_closed_tag!(tag_name : String, *attrs)
      close_attrs

      @io << "<" << tag_name
      @attrs_open = true

      attrs.each { |pair|
        render_attr!(pair.first, pair.last)
      }

      close_attrs
    end # === def render_closed_tag!

    def render_tag!(tag_name : String, raw_content : String)
      close_attrs
      @io << "<" << tag_name << ">"
      render_text!(raw_content)
      @io << "</" << tag_name << ">"
    end # === def render!

    def render_tag!(tag_name : String)
      close_attrs

      @io << "<" << tag_name
      @attrs_open = true

      result = yield
      case result
      when String
        render_text!(result)
      end

      if @attrs_open
        close_attrs
      end

      @io << "</" << tag_name << ">"
    end # === def render!

    def render_tag!(klass, tag_name : String)
      close_attrs

      @io << "<" << tag_name
      @attrs_open = true

      scope = klass.new(self)
      result = with scope yield
      case result
      when String
        render_text!(result)
      end

      if @attrs_open
        close_attrs
      end

      @io << "</" << tag_name << ">"
    end # === def render!

    def raw!(v : String)
      @io << v
    end # === def raw!

    def raw!(v : DA_HTML::Raw)
      @io << v.value
    end

    def to_html
      @io.to_s
    end # === def to_html

  end # === struct Page

end # === module DA_HTML


