
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

      def grab_attrs
        arr = [] of Instruction
        while @doc.current.attr?
          arr << @doc.grab_current
        end
        arr
      end # === def grab_attrs

      def grab_body
        arr = [] of Instruction
        open = 1
        loop do
          curr = doc.current
          if curr.close_tag?("body") || curr.close_tag?("html")
            raise Exception.new("Closing tag not found for: #{tag_name}")
          end
          case
          when curr.open_tag?(tag_name)
            open += 1
          when curr.close_tag?(tag_name)
            open -= 1
          end
          break if open == 0
          arr << doc.grab_current
          break if !doc.next?
        end # === loop
        arr
      end # === def grab_body

    end # === struct Instruction

  end # === module Parser

end # === module DA_HTML
