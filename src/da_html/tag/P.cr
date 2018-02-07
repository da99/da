
module DA_HTML

  struct P

    module Tag

      def p(*args, **attrs)
        P.new(self, *args, **attrs).to_html { |page|
          with page yield page
        }
      end

    end # === module Tag

    @page : DA_HTML::Base
    def initialize(@page, *args, **attrs)
    end # === def initialize

    def to_html
      p = @page
      p.raw! "<p"
      p.raw! '>'
      p.text?(with p yield p)
      p.raw! "</p>"
    end # === def to_html

  end # === struct P

end # === module DA_HTML
