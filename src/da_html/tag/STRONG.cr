
module DA_HTML

  module STRONG
    module Tag
      def strong
        raw! "<strong>"
        if_string(with p yield p) { |x| text! x }
        raw! "</strong>"
      end
    end # === module Tag

  end # === struct STRONG

end # === module DA_HTML
