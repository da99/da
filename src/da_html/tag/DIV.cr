
module DA_HTML

  struct DIV

    @page : DA_HTML::Base
    def initialize(@page, *args)
    end # === def initialize

    def to_html
      p = @page
      p.raw! "<div>"
      p.text?(with p yield p)
      p.raw! "</div>"
    end # === def to_html

  end # === struct DIV

end # === module DA_HTML
