
module DA_HTML

  module TITLE

    module Tag
      def title
        raw! "<title>"
        text!(with self yield self)
        raw! "</title>"
      end # === def title
    end # === module Tag

  end # === struct TITLE

end # === module DA_HTML
