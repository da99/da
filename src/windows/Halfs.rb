# frozen_string_literal: true


module Top_Half
  extend self

  def stamp?
    false
  end

  def x
    Window.root.left_padding
  end

  def y
    Window.root.top_padding
  end

  def w
    Fullscreen.w
  end

  def h
    (Fullscreen.h / 2).to_i
  end
end # module

module Bottom_Half
  extend self

  def stamp?
    false
  end

  def x
    Window.root.left_padding
  end

  def y
    Top_Half.y + Top_Half.h
  end

  def w
    Fullscreen.w
  end

  def h
    Window.root.h - y - Window.border - Window.root.bottom_padding
  end
end # module

