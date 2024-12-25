# frozen_string_literal: true

module Left_Side
  class << self
    include Area

    def x
      Window.root.left_padding
    end

    def y
      Window.root.top_padding
    end

    def w
      (Window.root.w * 0.70).to_i - Window.root.left_padding - Window.margin
    end

    def h
      Window.root.h - Window.root.bottom_padding - y
    end

    def inspect
      "#{name} x:#{x} y:#{y} w:#{w} h:#{h}"
    end
  end # class self
end # module
