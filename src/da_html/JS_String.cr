
module DA_HTML
  struct JS_String

    getter raw : String

    def initialize(@raw)
    end # === def

    def to_s(io)
      io << @raw
    end

  end # === struct JS_String
end # === module DA_HTML
