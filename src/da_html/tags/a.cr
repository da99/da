
require "da_uri"
module DA_HTML

  module DSL

    module A
      macro a(*args, **attrs, &blok)
        io.write_tag("a") {

          {% unless args.empty? %}
            io.write_attr_id_class {{*args}}
          {% end %}

          {% for k, v in attrs %}
            io.write_attr("{{k.id}}", a_{{k.id}}({{v}}))
          {% end %}

          io.write_content {
            {{blok.body}}
          }

        }
      end # === macro a

      def a_href(s : String)
        DA_URI.clean(s) || "#invalid"
      end # === def a_href
    end # === module A

  end # === module DSL

end # === module DA_HTML
