
module DA_HTML

  struct SPAN

    @page : DA_HTML::Base
    def initialize(@page, *args)
    end # === def initialize

    def to_html
      p = @page
      p.raw! "<span>"
      p.text?(with p yield p)
      p.raw! "</span>"
    end # === def to_html

  end # === struct SPAN

end # === module DA_HTML
