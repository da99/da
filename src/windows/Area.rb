# frozen_string_literal: true

class Area
  attr_reader :area, :window

  def initialize(raw_area, raw_window)
    @area = raw_area
    @window = raw_window
  end # end

  def stamp?
    area.stamp?
  end

  def x
    area.x
  end

  def y
    area.y
  end

  def h
    area.h
  end

  def w
    area.w
  end
end # class
