

module DA_HTML

  module DIV

    macro div(*args, **attrs, &blok)
      io.write_tag("div") {
        {% unless args.empty? %}
          io.write_id_class {{*args}}
        {% end %}
        {% for k,v in attrs %}
          div_{{k}}({{v}})
        {% end %}

        io.write_content {
          {{blok.body}}
        }
      }
    end # === macro div

  end # === module DIV

end # === module DA_HTML
