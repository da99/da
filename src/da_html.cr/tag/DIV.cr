
module DA_HTML

  module DIV
    module Tag
      def div(id_class : String? = nil)
        raw! "<div"
        id_class!(id_class) if id_class
        raw! '>'
        text? {
          with self yield self
        }
        raw! "</div>"
      end
    end # === module Tag
  end # === module DIV

end # === module DA_HTML
