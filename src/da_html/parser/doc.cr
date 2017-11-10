
require "./instruction"

module DA_HTML

  module Parser

    class Doc

      getter origin : DOC
      getter pos = 0
      getter last : Int32

      def initialize(arr : Array(Instruction))
        @origin = arr.map { |x| x.origin }
        @last = (@origin.size - 1)
      end # === def initialize

      def initialize(@origin)
        @last = (@origin.size - 1)
      end # === def initialize

      def grab_current
        val = current
        move
        val
      end # === def grab_current

      def current
        Instruction.new(origin[pos], self)
      end # === def current

      def current?
        @pos <= @last
      end # === def current?

      def next?
        @pos < @last
      end # === def next?

      def next
        Instruction.new(origin[pos + 1], self)
      end # === def next

      def prev
        Instruction.new(origin[pos - 1], self)
      end

      private def move
        raise Exception.new("Already at end.") if @pos > @last
        @pos = @pos + 1
        self
      end # === def move

      def attr?
        current.first == "attr"
      end # === def attr?

    end # === class Doc

  end # === module Parser

end # === module DA_HTML
