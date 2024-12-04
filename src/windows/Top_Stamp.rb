# frozen_string_literal: true

module Top_Stamp
  extend self
  FACTOR = 0.25

  def stamp?
    true
  end

  def x
    ROOT.w - w - Window.border
  end

  def y
    ROOT.top_padding
  end

  def w
    return (1920 * FACTOR).to_i if ROOT.hd?

    (ROOT.w * FACTOR).to_i
  end

  def h
    (ROOT.h * FACTOR).to_i
  end
end # module
