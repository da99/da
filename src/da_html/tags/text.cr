
module DA_HTML

  module TEXT

    def text(*args)
      args.each { |x|
        io.write_text x
      }
    end

  end # === module Text

end # === module DA_HTML
