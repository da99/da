#!/usr/bin/env ruby
# frozen_string_literal: true

require 'English'
require_relative 'Root_Window'

class Mouse_Pointer
  attr_reader :x, :y, :window, :root

  def initialize(root_window, raw_window)
    @root = root_window
    @window = raw_window
    raw_x, raw_y, _raw_screen, _raw_window = `xdotool getmouselocation --shell`.strip.split("\n")
    @x = raw_x.split('=').last.to_i
    @y = raw_y.split('=').last.to_i
  end

  def inspect
    "Mouse: #{x} #{y}"
  end

  def location_name
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
    y >= window.y && y < (window.y + CORNER_AREA)
  end

  def bottom_edge?
    y <= (window.y + window.h) && y > (window.y + window.h - CORNER_AREA)
  end

  def left_edge?
    x >= window.x && x < (window.x + CORNER_AREA)
  end

  def right_edge?
    x < (window.x + window.w) && x >= (window.x + window.w - CORNER_AREA)
  end

  def center?
    center_x = window.x + (window.w / 2).to_i
    center_y = window.y + (window.h / 2).to_i
    padding = 20
    half_corner = (CORNER_AREA + padding).to_i
    x >= (center_x - half_corner) && x < (center_x + half_corner) &&
      y >= (center_y - half_corner) && y < (center_y + half_corner)
  end

  class << self
    def location_name
      Mouse_Pointer.new(Root_Window.new, Window.new).location_name
    end
  end # class
end # === class Mouse

