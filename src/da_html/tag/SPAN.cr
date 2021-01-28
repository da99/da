
module DA_HTML

  module SPAN

    module Tag

      def span(id_class : String? = nil)
        raw! "<span"
        id_class!(id_class) if id_class
        raw! '>'
        text? {
          with self yield self
        }
        raw! "</span>"
      end

    end # === module Tag

  end # === struct SPAN

end # === module DA_HTML
