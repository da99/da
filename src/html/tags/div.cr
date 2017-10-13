

module DA_HTML

  module DIV

    macro div(*args, **attrs, &blok)
      io.render_tag!("div") {
        {% unless args.empty? %}
          div_id_class {{*args}}
        {% end %}
        {% for k,v in attrs %}
          div_{{k}}({{v}})
        {% end %}

        div_render {
          {{blok.body}}
        }
      }
    end # === macro div

    def div_id_class(s)
      io.render_attr!("id_class", s)
    end # === def div_id_class

    def div_render
      yield
    end # === def div_render

  end # === module DIV

end # === module DA_HTML
