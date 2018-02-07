
module DA_HTML

  struct STRONG

    module Tag
      def strong(*args, **attrs)
        STRONG.new(self, *args, **attrs)
      end
    end # === module Tag

    @page : DA_HTML::Base
    def initialize(@page, *args, **attrs)
    end # === def initialize

    def to_html
      with @page yield @page
    end # === def to_html

  end # === struct STRONG

end # === module DA_HTML
