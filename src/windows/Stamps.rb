# frozen_string_literal: true

module Top_Stamp
  extend self
  FACTOR = 0.25

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
end # module

module Bottom_Stamp
  extend self
  FACTOR = 0.15

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
end # module

