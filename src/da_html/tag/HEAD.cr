
module DA_HTML

  struct HEAD

    @page : DA_HTML::Base
    def initialize(@page)
    end # === def initialize

    def to_html
      p = @page
      p.raw! "<head>"
      p.text?(with p yield p)
      p.raw! "</head>"
    end # === def to_html

  end # === struct HEAD

end # === module DA_HTML
