
module DA_HTML

  module P

    macro p(*args, **attrs, &blok)
      io.render_tag!("p") {
        {% unless args.empty? %}
          p_id_class {{*args}}
        {% end %}
        {% for k,v in attrs %}
          p_{{k}}({{v}})
        {% end %}

        p_render {
          {{blok.body}}
        }
      }
    end # === macro p

    def p_id_class(s)
      io.render_attr!("id_class", s)
    end # === def p_id_class

    def p_render
      yield
    end # === def p_render

  end # === module P

end # === module DA_HTML
