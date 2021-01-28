
module DA_HTML

  module BODY

    module Tag
      def body(*args)
        raw! "<body"
        raw! '>'
        if_string(with self yield self) { |x| text! x }
        raw! "</body>"
      end
    end # === module Tag

  end # === struct BODY

end # === module DA_HTML
