
module DA_HTML

  module HTML

    def html
      io.write_tag("html") {
        io.write_content {
          yield
        }
      }
    end

  end # === module HTML

end # === module DA_HTML
