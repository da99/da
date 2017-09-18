
class HTML

  module Element

    # module To_Html
    #   def to_html
    #     @doc << ">#{@body.to_s}</#{tag_name.to_s}>"
    #     @doc
    #   end # === def to_html
    # end # === module To_Html

    module Has_Content

      def close(s : String)
        @doc.close_tag
        @has_body = true
        @doc << ">" << s << "</" << tag_name << ">"
        @doc
      end # === def close

      def close
        result = yield

        case result
        when String
          self.close(result) unless @has_body
          @has_body = true
        else
          self.close("")
        end

        @doc
      end # === def close

    end # === module Has_Content

  end # === module Element

end # === class HTML
