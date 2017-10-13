
module DA_HTML

  module Template

    macro included
      macro template(*args, **attrs, &blok)
        io.render_tag!("script") {
          template_type
        }
      end

      def var(name)
        DA_HTML::Raw.new("\{{#{name}}}")
      end # === def var!

    end # === macro included

    def template_type
      io.render_attr! "type", "text/da-html-template"
    end # === def template_type!

    def template_render
      yield
    end # === def template_render

  end # === module Template

end # === module DA_HTML
