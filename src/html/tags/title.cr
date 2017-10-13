
module DA_HTML

  module TITLE

    def title(s : String)
      io.render_tag!("title", s)
      self
    end

  end # === module Title_Tag

end # === module DA_HTML
