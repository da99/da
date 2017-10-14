

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
          io.write_attr "{{k.id}}", form_{{k}}({{v}})
        {% end %}

        io.write_content {
          {{blok.body}}
        }
      }
    end

    def form_action(s : String)
      s
    end # === def form_action(

    def form_method(s : String)
      case s
      when "get", "post"
        s
      else
        raise Exception.new("Invalid form method: #{s.inspect}")
      end
    end # === def form_method

  end # === module FORM

end # === module DA_HTML
