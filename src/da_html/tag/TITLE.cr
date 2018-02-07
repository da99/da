
module DA_HTML

  struct TITLE

    @page : DA_HTML::Base
    def initialize(@page, *args)
    end # === def initialize

    def to_html
      @page.raw! "<title>"
      with @page yield @page
    end # === def to_html

  end # === struct TITLE

end # === module DA_HTML
