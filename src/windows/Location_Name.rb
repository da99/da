#!/usr/bin/env ruby
# frozen_string_literal: true

class Location_Name
  CORNER_AREA = 100
  attr_reader :point, :area

  def initialize(area, mouse_pointer)
    @point = mouse_pointer
    @area = area
  end # def

  def name
    return nil unless inside?

    tb = if top_edge?
           'top'
         else
           (bottom_edge? ? 'bottom' : nil)
         end

    lr = if left_edge?
           'left'
         else
           (right_edge? ? 'right' : nil)
         end

    return "#{tb}_#{lr}_corner" if tb && lr
    return "#{tb}_edge" if tb
    return "#{lr}_edge" if lr
    return 'center' if center?

    return 'left_side' if left_side?

    'right_side' if right_side?
  end

  def top_edge?
    point.y >= area.y && point.y < (area.y + CORNER_AREA)
  end

  def bottom_edge?
    point.y <= (area.y + area.h) && point.y > (area.y + area.h - CORNER_AREA)
  end

  def left_edge?
    point.x < (area.x + CORNER_AREA)
  end

  def right_edge?
    point.x >= (area.x + area.w - CORNER_AREA)
  end

  def left_side?
    point.x < (area.x + (area.w / 2).to_i)
  end

  def right_side?
    inside? && !left_side?
  end

  def x_inside?
    point.x < (area.x + area.w) && point.x >= area.x
  end

  def y_inside?
    point.y < (area.y + area.h) && point.y >= area.y
  end

  def inside?
    x_inside? && y_inside?
  end

  def center?
    center_x = area.x + (area.w / 2).to_i
    center_y = area.y + (area.h / 2).to_i
    half_w = (area.w * 0.15).to_i
    half_h = (area.h * 0.20).to_i
    point.x >= (center_x - half_w) && point.x < (center_x + half_w) &&
      point.y >= (center_y - half_h) && point.y < (center_y + half_h)
  end
end # class
