# frozen_string_literal: true

module Right_Top
  extend self

  def stamp?
    false
  end

  def x
    (ROOT.w * 0.70).to_i + Window.margin
  end

  def y
    ROOT.top_padding
  end

  def w
    ROOT.w - x - Window.border
  end

  def h
    (ROOT.h / 2).to_i - ROOT.top_padding - Window.margin
  end
end # module
