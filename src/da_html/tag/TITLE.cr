
module DA_HTML

  struct TITLE

    @page : DA_HTML::Base
    def initialize(@page, *args)
    end # === def initialize

    def to_html
      p = @page
      p.raw! "<title>"
      p.text!(with p yield p)
      p.raw! "</title>"
    end # === def to_html

  end # === struct TITLE

end # === module DA_HTML
