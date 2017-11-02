
module DA_HTML

  module DSL

    module P

      macro p(*ic, **attrs, &blok)
        io.write_tag("p") {
          {% unless ic.empty? %} io.write_attr_id_class {{*ic}} {% end %}

          {% for k,v in attrs %}
            io.write_attr "{{k.id}}", p_{{k}}({{v}})
          {% end %}

          io.write_content {
            {{blok.body}}
          }
        }
      end # === macro p

    end # === module P

  end # === module DSL

end # === module DA_HTML
