
module DA_HTML

  module HEAD

    module Tag

      def head(*args)
        raw! "<head>"
        if_string(with self yield self) { |x| text! x }
        raw! "</head>"
      end # === def head

    end # === module Tag

  end # === struct HEAD

end # === module DA_HTML
