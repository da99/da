# frozen_string_literal: true

module Right_Bottom
  extend self

  def x
    (ROOT.w * 0.70).to_i + Window.margin
  end

  def y
    (ROOT.h / 2).to_i + Window.margin
  end

  def w
    ROOT.w - x - Window.border
  end

  def h
    (ROOT.h / 2).to_i - Window.margin - Window.border
  end
end # module
