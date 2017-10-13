
module DA_HTML

  module Text

    def text(s : String)
      io.render_text! s
    end

    def text(r : DA_HTML::Raw)
      io.raw! r
    end # === def text

    def text(*args)
      args.each { |x|
        text x
      }
    end

  end # === module Text

end # === module DA_HTML
