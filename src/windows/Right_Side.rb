# frozen_string_literal: true

module Right_Side
  extend self

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
    ROOT.h - ROOT.bottom_padding - y
  end
end # module
