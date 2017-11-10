
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

      def tag_name
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
        arr = [] of Instruction
        if !@doc.current.attr? && @doc.next? && @doc.next.attr?
          @doc.move
        end

        while @doc.current.attr?
          arr << @doc.current
          doc.move
        end
        arr
      end # === def attrs

      def children
        arr = [] of INSTRUCTION
        open = 1
        while @doc.next?
          curr = doc.current
          case
          when curr.open_tag?(tag_name)
            open += 1
          when curr.close_tag?(tag_name)
            open -= 1
          end
          if open == 0
            return arr
          end
          arr << curr.origin
          doc.move
        end
        arr
      end # === def children

    end # === struct Instruction

  end # === module Parser

end # === module DA_HTML
