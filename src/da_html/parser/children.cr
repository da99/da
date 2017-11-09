
module DA_HTML

  module Parser

    class Children

      include Iterator(INSTRUCTION)

      @pos        : Int32
      @origin_pos : Int32
      def initialize(@doc : Doc, @tag : String)
        @open       = 1
        @pos        = doc.pos
        @origin_pos = doc.pos
      end # === def initialize

      def next
        return stop if !@doc.current?
        action = @doc.current.first

        case action
        when "open-tag"
          new_tag = @doc.current.last
          case new_tag
          when @tag
            @open += 1
          end
        when "close-tag"
          old_tag = @doc.current.last
          case old_tag
          when @tag
            @open -= 1
          end
        end

        if @open == 0
          return stop
        end
        val = @doc.current
        @doc.move
        val
      end # === def next

      def rewind
        @pos = @origin_pos
        @open = 1
        @doc.rewind(@pos)
        self
      end # === def rewind

    end # === class Children

  end # === module Parser

end # === module DA_HTML
