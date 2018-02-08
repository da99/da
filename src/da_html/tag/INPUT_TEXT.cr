
module DA_HTML
  module INPUT_TEXT
    module Tag

      def input_text(*args, **attrs)
        is_required = false
        max : Int32 = 250

        args.each { |x|
          case x
          when :required
            is_required = true
          else
            raise Invalid_Attr_Value.new(%[input (of type text)], x)
          end
        }
        attrs.each { |k, v|
          case k
          when :maxlength
            max = v
          else
            raise Invalid_Attr_Value.new(%[input (of type text)], k, v)
          end
        }
        raw! %[<input type="text"]
        attr!(:required) if is_required
        attr!(:maxlength, max)
        raw! %[>]
      end # === def input_text

    end # === module Tag
  end # === struct INPUT_TEXT
end # === module DA_HTML
