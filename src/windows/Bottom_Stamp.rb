# frozen_string_literal: true

module Bottom_Stamp
  extend self
  FACTOR = 0.15

  def x
    ROOT.w - w - Window.border
  end

  def y
    ROOT.h - h - Window.border
  end

  def w
    return (1920 * FACTOR).to_i if ROOT.hd?

    (ROOT.w * FACTOR).to_i
  end

  def h
    (ROOT.h * 0.15).to_i
  end
end # module

