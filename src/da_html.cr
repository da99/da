
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

  module INPUT_OUTPUT_BASE

    include DA_HTML::ID_CLASS

    @attrs_open : Bool

    def initialize
      @io__ = IO::Memory.new
      @attrs_open = false
    end # === def initialize

    def write_attr(name : String, val : String)
      raise Exception.new("Tag is not open for attribute: #{name.inspect}=#{val.inspect}") unless @attrs_open
      raw!( " ", name, "=", val.inspect)
      self
    end # === def write_attr

    def write_text(s : String)
      close_attrs
      raw! DA_HTML_ESCAPE.escape(s)
    end # === def write_text

    def write_content_result(s : String)
      write_text(s)
    end # === def write_text

    def write_content_result(x)
      # :ignore all others
    end # === def write_text

    def close_attrs
      if @attrs_open
        raw! ">"
        @attrs_open = false
      end
    end # === def close_attrs

    def write_content
      close_attrs
      write_content_result(yield)
    end # === def write_content

    def write_closed_tag(tag_name : String, *attrs)
      close_attrs

      raw! "<", tag_name
      @attrs_open = true

      attrs.each { |pair|
        write_attr(pair.first, pair.last)
      }

      close_attrs
    end # === def write_closed_tag

    def write_tag(tag_name : String, raw_content : String)
      close_attrs
      raw! "<", tag_name, ">"
      write_content_result(raw_content)
      raw! "</", tag_name, ">"
    end # === def render!

    def write_tag(tag_name : String)
      close_attrs

      raw! "<", tag_name
      @attrs_open = true

      write_content_result(yield)

      if @attrs_open
        close_attrs
      end

      raw! "</", tag_name, ">"
    end # === def render!

    def write_tag(klass, tag_name : String)
      close_attrs

      raw! "<", tag_name
      @attrs_open = true

      scope = klass.new(self)
      result = with scope yield
      write_content_result(result)

      if @attrs_open
        close_attrs
      end

      raw! "</", tag_name, ">"
    end # === def render!

    def raw!(*args)
      args.each { |x|
        @io__ << x
      }
    end # === def raw!

    def to_html
      @io__.to_s
    end # === def to_html

  end # === module INPUT_OUTPUT

  class INPUT_OUTPUT
    include INPUT_OUTPUT_BASE
  end # === class INPUT_OUTPUT

end # === module DA_HTML


