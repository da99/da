
module DA_HTML

  struct SPAN

    @page : DA_HTML::Base
    def initialize(@page, *args)
    end # === def initialize

    def to_html
      @page.raw! "<span>"
      with @page yield @page
    end # === def to_html

  end # === struct SPAN

end # === module DA_HTML
