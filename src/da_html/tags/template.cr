
module DA_HTML

  module TEMPLATE

    class INPUT_OUTPUT
      include DA_HTML::INPUT_OUTPUT_BASE

      def write_content_result(x : DA_HTML::TEMPLATE::VAR)
        raw! x.to_s
      end # === def write_content_result
    end # === class INPUT_OUTPUT

    macro included
      macro template(str_id, &blok)
        io.write_tag("script") {
          io.write_id \{{str_id}}
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
      def initialize(@value : String)
      end # === def initialize
      def to_s
        "{{#{@value}}}"
      end
    end # === struct VAR

    def var(name)
      DA_HTML::TEMPLATE::VAR.new(name)
    end # === def var!

    def template_render
      origin_io = io
      @io = DA_HTML::TEMPLATE::INPUT_OUTPUT.new
      io.write_content_result(yield)
      origin_io.write_text @io.to_html
      @io = origin_io
    end # === def template_render

  end # === module TEMPLATE

end # === module DA_HTML
