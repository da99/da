
module DA_HTML

  module HEAD

    def head
      io.render_tag!("head") {
        yield
      }
    end # === def head

  end # === module HEAD

end # === module DA_HTML
