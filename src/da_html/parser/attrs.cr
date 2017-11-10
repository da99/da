
require "./instruction"
module DA_HTML

  module Parser

    class Attrs

      include Iterator(Instruction)

      @origin_pos : Int32
      @pos        : Int32

      def initialize(@doc : Doc)
        @origin_pos = @doc.pos
        @pos = @doc.pos
      end # === def initialize

      def next
        return stop if !@doc.current? || !@doc.current.attr?

        val = @doc.current
        @doc.move
        return val
      end # === def next

      def rewind
        @pos = @origin_pos
        @doc.rewind(@pos)
        self
      end # === def rewind

    end # === class Attrs

  end # === module Parse

end # === module DA_HTML
