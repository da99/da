
module DA_HTML

  struct INPUT_TEXT

    module Tag

      def input_text(*args, **attrs)
        INPUT_TEXT.new(self, *args, **attrs).to_html
      end # === def input_text

    end # === module Tag

    @page : DA_HTML::Base
    @required = false
    @maxlength : Int32?

    def initialize(@page, *args, **attrs)
      args.each { |x|
        case x
        when :required
          @required = true
        else
          raise Invalid_Attr_Value.new(%[input (of type text)], x)
        end
      }
      attrs.each { |k, v|
        case k
        when :maxlength
        else
          raise Invalid_Attr_Value.new(%[input (of type text)], k, v)
        end
      }
    end # === def initialize

    def to_html
      @page.raw! %[<input type="text"]
      @page.raw! %[>]
    end # === def to_html

  end # === struct INPUT_TEXT

end # === module DA_HTML
