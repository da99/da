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

    'center' if center?
  end

  def top_edge?
    point.y >= area.y && point.y < (area.y + CORNER_AREA)
  end

  def bottom_edge?
    point.y <= (area.y + area.h) && point.y > (area.y + area.h - CORNER_AREA)
  end

  def left_edge?
    point.x >= area.x && point.x < (area.x + CORNER_AREA)
  end

  def right_edge?
    point.x < (area.x + area.w) && point.x >= (area.x + area.w - CORNER_AREA)
  end

  def center?
    center_x = area.x + (area.w / 2).to_i
    center_y = area.y + (area.h / 2).to_i
    padding = 20
    half_corner = (CORNER_AREA + padding).to_i
    point.x >= (center_x - half_corner) && point.x < (center_x + half_corner) &&
      point.y >= (center_y - half_corner) && point.y < (center_y + half_corner)
  end
end # class
