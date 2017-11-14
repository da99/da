
module DA_HTML

  alias Raw_Instruction = Tuple(String, String) | Tuple(String, String, String)

  struct Instruction

    getter origin  : Raw_Instruction
    getter doc     : Doc
    getter doc_pos : Int32

    def initialize(@origin, @doc)
      @doc_pos = @doc.pos
    end # === def initialize

    {% for x in %w(open close).map(&.id) %}
      def {{x}}_tag?
        is?("{{x}}-tag")
      end # === def open_tag?

      def {{x}}_tag?(tag_name : String)
        {{x}}_tag? && last == tag_name
      end # === def open_tag?
    {% end %}

    def attr?
      is?("attr")
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

    def is?(raw : String)
      @origin.first == raw
    end # === def first

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
      arr = Doc.new
      while @doc.current.attr?
        arr << @doc.grab_current
      end
      arr
    end # === def grab_attrs

    def grab_body
      arr = Doc.new
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

    def each
      @origin.each { |x|
        yield x
      }
    end # === def each

    {% if env("IS_DEV") %}
      def inspect(io)
        io << "Instruction" << origin.inspect
      end
    {% end %}

  end # === struct Instruction

end # === module DA_HTML
