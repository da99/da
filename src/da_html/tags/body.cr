
module DA_HTML

  module BODY

    def body
      io.render_tag!("body") {
        yield
      }
    end # === def body

  end # === module BODY

end # === module DA_HTML
