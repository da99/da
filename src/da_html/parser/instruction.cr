
module DA_HTML

  module Parser

    struct Instruction

      getter origin : INSTRUCTION
      getter doc : Doc
      def initialize(@origin, @doc)
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

      def attrs
        doc.move if doc.current.origin == origin
        Parser::Attrs.new(doc)
      end # === def attrs

      def children
        doc.move if doc.current.origin == origin
        Children.new(@doc, origin.last)
      end # === def children

    end # === struct Instruction

  end # === module Parser

end # === module DA_HTML
