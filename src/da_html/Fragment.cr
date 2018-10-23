
module DA_HTML
  struct Fragment

    getter children : Array(Node)
    getter raw      : String

    def initialize(@raw : String)
      doc = Deque(Node).new(@raw)
      @children = doc.body.children
    end

  end # === struct Fragment
end # === module DA_HTML
