
module DA_HTML

  module HEAD

    def head
      io.write_tag("head") {
        io.write_content {
          yield
        }
      }
    end # === def head

  end # === module HEAD

end # === module DA_HTML
