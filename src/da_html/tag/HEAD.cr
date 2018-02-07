
module DA_HTML

  struct HEAD

    @page : DA_HTML::Base
    def initialize(@page, *args)
    end # === def initialize

    def to_html
      @page.raw! "<head>"
      with @page yield @page
    end # === def to_html

  end # === struct HEAD

end # === module DA_HTML
