
require "./dsl/attrs/id_class"

module DA_HTML

  class IO_HTML
    module BASE

      include DA_HTML::DSL::ID_CLASS

      @io__ = IO::Memory.new

      def empty?
        @io__.empty?
      end

      def write_attr(val : String)
        raw!( " ", val)
        self
      end # === def write_attr

      def write_attr(name : String, val : String)
        raw!( " ", name, "=", escape(val).inspect)
        self
      end # === def write_attr

      def write_attr(attr : DA_HTML::Instruction)
        raise Invalid_Attr.new(attr) unless attr.attr?
        raw!( " ", attr.attr_name, "=", escape(attr.attr_content).inspect)
        self
      end # === def write_attr

      def escape(s)
        DA_HTML_ESCAPE.escape(s) || ""
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

      def open_tag(tag_name : String)
        raw! "<", tag_name, ">"
      end # === def open_tag

      def open_tag_attrs(tag_name : String)
        raw! "<", tag_name
      end # === def open_tag

      def open_tag_attrs(tag_name : String)
        raw! "<", tag_name
        yield self
        close_attrs
      end # === def open_tag

      def close_attrs
        raw! ">"
      end # === def close_attrs

      def close_tag(tag_name : String)
        raw! "</", tag_name, ">"
      end # === def close_tag

      def raw!(*args)
        args.each { |x|
          @io__ << x
        }
      end # === def raw!

      def to_html
        @io__.to_s
      end # === def to_html

      def to_s
        @io__.to_s
      end # === def to_s

    end # === module IO_HTML
    include BASE
  end # === class IO_HTML

end # === module DA_HTML
