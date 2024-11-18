# frozen_string_literal: true

module Fullscreen
  extend self

  def x
    ROOT.left_padding
  end

  def y
    ROOT.top_padding
  end

  def w
    ROOT.w - x - Window.border - Window.margin
  end

  def h
    ROOT.h - ROOT.top_padding - ROOT.bottom_padding
  end
end # module
