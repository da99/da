# frozen_string_literal: true

module Left_Side
  extend self

  def x
    ROOT.left_padding
  end

  def y
    ROOT.top_padding
  end

  def w
    (ROOT.w * 0.70).to_i - ROOT.left_padding - Window.margin
  end

  def h
    ROOT.h - ROOT.bottom_padding - y
  end
end # module
