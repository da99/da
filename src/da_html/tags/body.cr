
module DA_HTML

  module DSL

    module BODY

      def body
        io.write_tag("body") {
          io.write_content {
            yield
          }
        }
      end # === def body

    end # === module BODY

  end # === module DSL

end # === module DA_HTML
