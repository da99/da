
module DA_HTML

  module DSL

    module TITLE

      def title(s : String)
        io.write_tag("title", s)
        self
      end

    end # === module Title_Tag

  end # === module DSL

end # === module DA_HTML
