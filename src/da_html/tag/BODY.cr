
module DA_HTML

  struct BODY

    module Tag

      def body(*args, **attrs)
        BODY.new(self, *args, **attrs).to_html { |p|
          with p yield p
        }
      end

    end # === module Tag

    @page     : DA_HTML::Base
    @id_class : String? = nil
    def initialize(@page, @id_class : String? = nil, **attrs)
    end # === def initialize

    def to_html
      p = @page
      p.raw! "<body"
      p.raw! '>'
      p.text?(with p yield p)
      p.raw! "</body>"
    end # === def to_html

  end # === struct BODY

end # === module DA_HTML
