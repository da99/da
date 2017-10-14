
module DA_HTML

  module TEMPLATE

    macro included
      macro template(str_id, &blok)
        io.render_tag!("script") {
          io.render_id! \{{str_id}}
          io.render_attr! "type", "text/da-html-template"
          template_render() {
            \{{blok.body}}
          }
        }
      end

      def var(name)
        DA_HTML::Raw.new("\{{#{name}}}")
      end # === def var!

    end # === macro included

    def template_render
      fragment = template_scope.new
      with fragment yield
      io.render_text! fragment.to_html
    end # === def template_render

    def template_scope
      self.class
    end # === def template_scope

  end # === module TEMPLATE

end # === module DA_HTML
