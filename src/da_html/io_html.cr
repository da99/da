
require "./dsl/attrs/id_class"

module DA_HTML

  class IO_HTML
    module BASE

      include DA_HTML::DSL::ID_CLASS

      @io__ = IO::Memory.new
      @attrs_open = false

      def empty?
        @io__.empty?
      end

      def attrs_should_be_open!
        raise Invalid_Printing.new("Attrs are not open.") unless @attrs_open
        self
      end # === def attrs_open!

      def attrs_should_be_closed!
        raise Invalid_Printing.new("Attrs are not closed.") if @attrs_open
        self
      end # === def attrs_open!

      def write_attr(val : String)
        attrs_should_be_open!
        raw!( " ", val)
        self
      end # === def write_attr

      def write_attr(name : String, val : String)
        attrs_should_be_open!
        raw!( " ", name, "=", escape(val).inspect)
        self
      end # === def write_attr

      def write_attr(attr : DA_HTML::Instruction)
        raise Invalid_Attr.new(attr) unless attr.attr?
        write_attr(attr.attr_name, attr.attr_content)
        self
      end # === def write_attr

      def escape(s)
        DA_HTML_ESCAPE.escape(s) || ""
      end # === def escape

      def write_text(s : String)
        attrs_should_be_closed!
        raw! escape(s)
      end # === def write_text

      def write_text(x)
        attrs_should_be_closed!
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
        open_attrs(tag_name) {
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
        }
      end # === def write_closed_tag

      def write_tag(tag_name : String, raw_content : String)
        open_and_close_attrs(tag_name)
        write_text raw_content
        raw! "</", tag_name, ">"
      end # === def write_tag

      def open_tag(tag_name : String)
        open_and_close_attrs(tag_name) {
        }
      end # === def open_tag

      def open_and_close_attrs(tag_name : String)
        open_attrs(tag_name)
        close_attrs
      end # === def open_attrs

      def open_and_close_attrs(tag_name : String)
        open_attrs(tag_name)
        yield
        close_attrs
      end # === def open_attrs

      def open_attrs(tag_name : String)
        open_attrs(tag_name)
        yield self
        close_attrs
      end # === def open_tag

      def open_attrs(tag_name : String)
        attrs_should_be_closed!
        @attrs_open = true
        raw! "<", tag_name
      end # === def open_attrs

      def close_attrs
        attrs_should_be_open!
        @attrs_open = false
        raw! ">"
      end # === def close_attrs

      def close_tag(tag_name : String)
        attrs_should_be_closed!
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
