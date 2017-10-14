
module DA_HTML

  module SPAN

    macro span(*args, **attrs, &blok)
      io.write_tag("span") {
        {% unless args.empty? %}
          io.write_id_class {{*args}}
        {% end %}

        {% for k,v in attrs %}
          io.write_attr "{{k.id}}", span_{{k}}({{v}})
        {% end %}

        io.write_content {
          {{blok.body}}
        }
      }
    end # === macro span

  end # === module SPAN

end # === module DA_HTML
