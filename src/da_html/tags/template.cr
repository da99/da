
module DA_HTML

  module DSL

    module TEMPLATE

      class INPUT_OUTPUT
        include DA_HTML::IO_HTML::BASE

        def write_text(v : DA_HTML::DSL::TEMPLATE::VAR)
          raw! v.to_s
        end # === def text

        def write_content_result(v : DA_HTML::DSL::TEMPLATE::VAR)
          raw! v.to_s
        end # === def write_content_result

        # def escape(x : String)
        #   cleaned = super(x)
        #   return "" unless cleaned
        #   cleaned.gsub(/\{|\}/) { |x|
        #     case x
        #     when "{"
        #       "&#123;"
        #     when "}"
        #       "&#125;"
        #     else
        #       x
        #     end
        #   }
        # end
      end # === class INPUT_OUTPUT

      macro included
        macro template(str_id, &blok)
          io.write_tag("script") {
            io.write_attr_id \{{str_id}}
            io.write_attr "type", "text/da-html-template"
            io.write_content{
              template_render {
                \{{blok.body}}
              }
            }
          }
        end
      end # === macro included

      struct VAR
        @prefix : String
        @value  : String

        def initialize(@value, @prefix )
        end # === def initialize

        def initialize(@value)
          @prefix = ""
        end # === def initialize

        def to_s
          "{{#{@prefix}#{@value}}}"
        end
      end # === struct VAR

      def var(name : String)
        DA_HTML::DSL::TEMPLATE::VAR.new(name)
      end # === def var!

      def var_each(name : String)
        io.write_text(DA_HTML::DSL::TEMPLATE::VAR.new(name, "#"))
        yield
        io.write_text(DA_HTML::DSL::TEMPLATE::VAR.new(name, "/"))
      end # === def var_each

      def var_not(s : String)
        io.write_text(DA_HTML::DSL::TEMPLATE::VAR.new(s, "^"))
        yield
        io.write_text(DA_HTML::DSL::TEMPLATE::VAR.new(s, "/"))
      end # === def var_not

      def template_render
        origin_io = io
        @io = DA_HTML::DSL::TEMPLATE::INPUT_OUTPUT.new
        io.write_content_result(yield)
        origin_io.raw! @io.to_html.gsub(/[<>&]/) { |s|
          case s
          when "<"
            "&#x3c;"
          when ">"
            "&#x3e;"
          when "&"
            "&#x26;"
          else
            raise Exception.new("Not handled: #{s.inspect}")
          end
        }
        @io = origin_io
      end # === def template_render

    end # === module TEMPLATE

  end # === module DSL

end # === module DA_HTML
