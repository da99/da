
require "./instruction"

module DA_HTML

  module Parser

    # It's easy to generate infinite loops when dealing with flattened hierarchies.
    #   :grab_current + :grab_body (with close-tag "body"/"html" check)
    #   prevent infinite loops when dealing with flattened hierarchies.
    #   Without :grab_current, :move would have to be made :public and
    #   to be used by the developer manually,
    #   which would lead to more hard-to-find infinite loops.
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
