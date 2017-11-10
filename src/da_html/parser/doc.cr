
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

      # def rewind(@pos)
      #   self
      # end # === def rewind

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

      def move
        raise Exception.new("Already at end.") if @pos > @last
        @pos = @pos + 1
        self
      end # === def move

      # Returns: the `close-tag` of `tag_name`, while moving past all attrs and child
      # instructions.
      def skip_tag(tag_name : String) : Instruction
        open = 1
        while open != 0 && next?
          case current.first
          when "open-tag"
            case current.last
            when tag_name
              open += 1
            end
          when "close-tag"
            case current.last
            when tag_name
              open -= 1
            end
          end # === case

          move
          return prev if open == 0
        end # === while
        raise Exception.new("No closing tag for #{tag_name} found.")
      end # === def move_tag

      def attr?
        current.first == "attr"
      end # === def attr?

    end # === class Doc

  end # === module Parser

end # === module DA_HTML
