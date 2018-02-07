
module DA_HTML

  struct DIV

    @page : DA_HTML::Base
    def initialize(@page, *args)
    end # === def initialize

    def to_html
      @page.raw! "<div>"
      with @page yield @page
    end # === def to_html

  end # === struct DIV

end # === module DA_HTML
