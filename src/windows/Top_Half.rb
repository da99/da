# frozen_string_literal: true

module Top_Half
  extend self

  def x
    ROOT.left_padding
  end

  def y
    ROOT.top_padding
  end

  def w
    Fullscreen.w
  end

  def h
    (Fullscreen.h / 2).to_i
  end
end # module
