
module DA_HTML

  module Parser

    struct Instruction

      getter origin : INSTRUCTION
      def initialize(@origin)
      end # === def initialize

      def open_tag?
        origin.first == "open-tag"
      end # === def open_tag?

      def first
        @origin.first
      end # === def first

      def last
        @origin.last
      end # === def last

      def []?(i : Int32)
        @origin[i]?
      end # === def []

      def [](i : Int32)
        @origin[i]
      end # === def []

    end # === struct Instruction

  end # === module Parser

end # === module DA_HTML
