#!/usr/bin/env ruby
# frozen_string_literal: true

require 'English'

class Mouse_Pointer
  CORNER_AREA = 100
  attr_reader :x, :y

  def initialize
    raw_x, raw_y, _raw_screen, _raw_window = `xdotool getmouselocation --shell`.strip.split("\n")
    @x = raw_x.split('=').last.to_i
    @y = raw_y.split('=').last.to_i
  end

  def inspect
    "Mouse: #{x} #{y}"
  end
end # === class Mouse

