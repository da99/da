
module DA_HTML

  module Parser

    struct Instruction

      getter origin : INSTRUCTION
      getter doc : Doc
      getter doc_pos : Int32
      def initialize(@origin, @doc)
        @doc_pos = @doc.pos
      end # === def initialize

      def open_tag?
        origin.first == "open-tag"
      end # === def open_tag?

      def attr?
        @origin.first == "attr"
      end # === def attr?

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
        doc.move if !attr?
        Parser::Attrs.new(doc)
      end # === def attrs

      def children
        doc.move if @doc_pos == doc.pos
        Children.new(@doc, origin.last)
      end # === def children

    end # === struct Instruction

  end # === module Parser

end # === module DA_HTML
