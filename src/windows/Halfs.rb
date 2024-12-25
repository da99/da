# frozen_string_literal: true

module Top_Half
  class << self
    def stamp?
      false
    end

    def x
      Fullscreen.x
    end

    def y
      Fullscreen.y
    end

    def w
      Fullscreen.w
    end

    def h
      (Fullscreen.h / 2).to_i - Window.margin
    end
  end # class
end # module

module Bottom_Half
  class << self
    include Area

    def x
      Window.root.left_padding
    end

    def y
      Top_Half.y + Top_Half.h + Window.margin + Window.border
    end

    def w
      Fullscreen.w
    end

    def h
      Window.root.h - y - Window.root.bottom_padding
    end
  end # class self
end # module

