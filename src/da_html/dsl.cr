
require "./dsl/attrs/*"

module DA_HTML

  module DSL

    macro included

      {% for name in system("find #{__DIR__}/dsl/tags -maxdepth 1 -type f").split %}
         include DA_HTML::DSL::{{name.split("/").last.upcase.gsub(/.CR$/, "").id}}
      {% end %}

      getter io : DA_HTML::DSL::INPUT_OUTPUT | DA_HTML::DSL::TEMPLATE::INPUT_OUTPUT = DA_HTML::DSL::INPUT_OUTPUT.new

      def self.to_html
        h = new
        with h yield
        h.io.to_html
      end

      def to_html
        io.to_html
      end # === def to_html

    end # === macro included

    module INPUT_OUTPUT_BASE

      include DA_HTML::DSL::ID_CLASS

      @io__ = IO::Memory.new

      def write_attr(val : String)
        raw!( " ", val)
        self
      end # === def write_attr

      def write_attr(name : String, val : String)
        raw!( " ", name, "=", escape(val).inspect)
        self
      end # === def write_attr

      def escape(s)
        DA_HTML_ESCAPE.escape(s)
      end # === def escape

      def write_text(s : String)
        raw! escape(s)
      end # === def write_text

      def write_text(x)
        raise Exception.new("Invalid value for write_text: #{x.inspect}")
      end # === def write_text

      def write_content_result(s : String)
        write_text(s)
      end # === def write_text

      def write_content_result(x)
        # :ignore all others
      end # === def write_text

      def write_content
        raw! ">"
        write_content_result(yield)
        nil
      end # === def write_content

      def write_closed_tag(tag_name : String, *attrs)
        raw! "<", tag_name

        attrs.each { |a|
          len = a.size
          case len
          when 1
            write_attr(a.first)
          when 2
            write_attr(a.first, a.last)
          else
            raise Exception.new("Invalid attribute: #{a.inspect}")
          end
        }

        raw! ">"
      end # === def write_closed_tag

      def write_tag(tag_name : String, raw_content : String)
        raw! "<", tag_name, ">"
        write_text raw_content
        raw! "</", tag_name, ">"
      end # === def write_tag

      def write_tag(tag_name : String)
        raw! "<", tag_name
        yield
        raw! "</", tag_name, ">"
      end # === def render!

      def write_tag(klass, tag_name : String)
        close_attrs

        raw! "<", tag_name

        scope = klass.new(self)
        result = with scope yield
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

  end # === module DSL

end # === module DA_HTML

require "./dsl/tags/*"
