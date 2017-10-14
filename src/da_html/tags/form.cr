

module DA_HTML

  module FORM

    macro post(*args, **attrs, &blok)
      form({{*args}}, {{**attrs}}, method: "post") {
        {{blok.body}}
      }
    end

    macro form(*id_class, **args, &blok)
      io.render_tag!("form") {

        {% unless id_class.empty? %}
          io.render_id_class!({{*id_class}})
        {% end %}

        {% for k, v in args %}
          form_{{k}}({{v}})
        {% end %}

        form_render {
          {{blok.body}}
        }
      }
    end

    def form_action(s : String)
      io.render_attr!("action", s)
    end # === def form_action(

    def form_method(s : String)
      io.render_attr!("method", s)
    end # === def form_method

    def form_render
      yield
    end # === def form_render

  end # === module FORM

end # === module DA_HTML
