
module DA_HTML

  struct BODY

    @page : DA_HTML::Base
    def initialize(@page, *args)
    end # === def initialize

    def to_html
      @page.raw! "<body>"
      with @page yield @page
    end # === def to_html

  end # === struct BODY

end # === module DA_HTML
