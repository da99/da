# frozen_string_literal: true

module Bottom_Half
  extend self

  def x
    ROOT.left_padding
  end

  def y
    Top_Half.y + Top_Half.h
  end

  def w
    Fullscreen.w
  end

  def h
    ROOT.h - y - Window.border - ROOT.bottom_padding
  end
end # module

