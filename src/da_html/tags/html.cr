
module DA_HTML

  module HTML

    def html
      io.render_tag!("html") {
        yield
      }
    end

  end # === module HTML

end # === module DA_HTML
