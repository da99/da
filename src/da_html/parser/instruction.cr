
module DA_HTML

  module Parser

    struct Instruction

      getter origin : INSTRUCTION
      getter doc : Doc
      getter doc_pos : Int32
      def initialize(@origin, @doc)
        @doc_pos = @doc.pos
      end # === def initialize

      {% for x in %w(open close).map(&.id) %}
        def {{x}}_tag?
          origin.first == "{{x}}-tag"
        end # === def open_tag?

        def {{x}}_tag?(tag_name : String)
          {{x}}_tag? && origin.last == tag_name
        end # === def open_tag?
      {% end %}

      def attr?
        @origin.first == "attr"
      end # === def attr?

      def attr_name
        @origin[1]
      end

      def attr_content
        @origin.last
      end

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
        doc.move unless doc.current.attr?
        Parser::Attrs.new(doc)
      end # === def attrs

      def children
        doc.move if @doc_pos == doc.pos
        Children.new(@doc, origin.last)
      end # === def children

    end # === struct Instruction

  end # === module Parser

end # === module DA_HTML
