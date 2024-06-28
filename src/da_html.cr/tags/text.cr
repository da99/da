
module DA_HTML

  module DSL

    module TEXT

      def text(*args)
        args.each { |x|
          io.write_text x
        }
      end

    end # === module Text

  end # === module DSL

end # === module DA_HTML
