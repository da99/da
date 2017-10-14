

module DA_HTML

  module FORM

    macro post(*args, **attrs, &blok)
      form({{*args}}, {{**attrs}}, method: "post") {
        {{blok.body}}
      }
    end

    macro form(*id_class, **args, &blok)
      io.write_tag("form") {

        {% unless id_class.empty? %}
          io.write_id_class({{*id_class}})
        {% end %}

        {% for k, v in args %}
          form_{{k}}({{v}})
        {% end %}

        io.write_content {
          {{blok.body}}
        }
      }
    end

    def form_action(s : String)
      io.write_attr("action", s)
    end # === def form_action(

    def form_method(s : String)
      io.write_attr("method", s)
    end # === def form_method

  end # === module FORM

end # === module DA_HTML
