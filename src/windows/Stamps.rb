# frozen_string_literal: true

module Top_Stamp
  FACTOR = 0.25

  class << self
    def stamp?
      true
    end

    def x
      Window.root.w - w - Window.border
    end

    def y
      Window.root.top_padding
    end

    def w
      return (1920 * FACTOR).to_i if Window.root.hd?

      (Window.root.w * FACTOR).to_i
    end

    def h
      (Window.root.h * FACTOR).to_i
    end
  end # class self
end # module

module Bottom_Stamp
  FACTOR = 0.15

  class << self
    def stamp?
      true
    end

    def x
      Window.root.w - w - Window.border
    end

    def y
      Window.root.h - h - Window.border
    end

    def w
      return (1920 * FACTOR).to_i if Window.root.hd?

      (Window.root.w * FACTOR).to_i
    end

    def h
      (Window.root.h * 0.15).to_i
    end
  end # class self
end # module

