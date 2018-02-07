
module DA_HTML

  struct STRONG

    module Tag
      def strong
        STRONG.new(self).to_html { |p|
          with p yield p
        }
      end
    end # === module Tag

    @page : DA_HTML::Base
    def initialize(@page)
    end # === def initialize

    def to_html
      p = @page
      p.raw! "<strong>"
      p.text?(with p yield p)
      p.raw! "</strong>"
    end # === def to_html

  end # === struct STRONG

end # === module DA_HTML
