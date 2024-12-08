# frozen_string_literal: true

module Fullscreen
  extend self

  def x
    Window.root.left_padding
  end

  def y
    Window.root.top_padding
  end

  def w
    Window.root.w - x - Window.border - Window.margin
  end

  def h
    Window.root.h - Window.root.top_padding - Window.root.bottom_padding
  end
end # module
