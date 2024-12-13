# frozen_string_literal: true

module Right_Top
  extend self

  def stamp?
    false
  end

  def x
    (Window.root.w * 0.70).to_i + Window.margin
  end

  def y
    Window.root.top_padding
  end

  def w
    Window.root.w - x - Window.border
  end

  def h
    (Window.root.h / 2).to_i - Window.root.top_padding - Window.margin
  end
end # module

module Right_Half
  extend self

  def stamp?
    false
  end

  def x
    (Window.root.w * 0.50).to_i + Window.margin
  end

  def y
    Window.root.top_padding
  end

  def w
    Window.root.w - x - Window.border
  end

  def h
    Window.root.h - Window.root.bottom_padding - y
  end
end # module

module Right_Side
  extend self

  def stamp?
    false
  end

  def x
    (Window.root.w * 0.70).to_i + Window.margin
  end

  def y
    Window.root.top_padding
  end

  def w
    Window.root.w - x - Window.border
  end

  def h
    Window.root.h - Window.root.bottom_padding - y
  end
end # module

module Right_Bottom
  extend self

  def stamp?
    false
  end

  def x
    (Window.root.w * 0.70).to_i + Window.margin
  end

  def y
    (Window.root.h / 2).to_i + Window.margin
  end

  def w
    Window.root.w - x - Window.border
  end

  def h
    (Window.root.h / 2).to_i - Window.margin - Window.border
  end
end # module

