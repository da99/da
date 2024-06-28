
module DA_HTML

  module P

    module Tag
      def p(id_class : String? = nil)
        raw! "<p"
        id_class!(id_class) if id_class
        raw! '>'
        x = with self yield self
        if x.is_a?(String)
          text! x
        end
        raw! "</p>"
      end
    end # === module Tag

  end # === struct P

end # === module DA_HTML
