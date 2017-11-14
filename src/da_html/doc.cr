
require "./instruction"

module DA_HTML

  # It's easy to generate infinite loops when dealing with flattened hierarchies.
  #   :grab_current + :grab_body (with close-tag "body"/"html" check)
  #   prevent infinite loops when dealing with flattened hierarchies.
  #   Without :grab_current, :move would have to be made :public and
  #   to be used by the developer manually,
  #   which would lead to more hard-to-find infinite loops.
  class Doc

    getter origin = [] of Instruction
    getter pos = 0
    getter size : Int32

    def initialize
      @size = @origin.size
    end # === def initialize

    def initialize(@origin)
      @size = @origin.size
    end # === def initialize

    macro reset_size!
      @size = @origin.size
    end

    def instruct(name : String, content : String)
      self.<<({ name, content })
    end # === def instruct

    def instruct(name : String, key : String, content : String)
      self.<<({ name, key, content })
    end # === def instruct

    def <<(v : Raw_Instruction)
      self.<<(Instruction.new(v, self))
    end # === def <<

    def <<(i : Instruction)
      @origin << Instruction.new(i.origin, self)
      reset_size!
      self
    end # === def <<

    def grab_current
      val = current
      move
      val
    end # === def grab_current

    def current
      origin[pos]
    end # === def current

    def last
      (@size - 1)
    end # === def last

    def current?
      @pos <= last
    end # === def current?

    def next?
      @pos < last
    end # === def next?

    def next
      origin[pos + 1]
    end # === def next

    def prev(i : Int32 = 1)
      origin[pos - i]
    end

    private def move
      raise Exception.new("Already at end.") if @pos > last
      @pos = @pos + 1
      self
    end # === def move

    def attr?
      current.attr?
    end # === def attr?

    def empty?
      @size == 0
    end

    def each
      @origin.each { |x|
        yield x
      }
    end # === def each

    {% if env("IS_DEV") %}
      def inspect(io)
        io << "Doc["
        @origin.each_with_index { |i, index|
          io << "\n  " << i.inspect
        }
        if @origin.empty?
          io << "empty]"
        else
          io << "\n]"
        end
      end
    {% end %}

  end # === class Doc

end # === module DA_HTML
