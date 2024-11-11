#!/usr/bin/env ruby
# frozen_string_literal: true

require 'English'

class Root_Window
  attr_reader :w, :h

  def initialize
    raw_w, raw_h = begin
                     File.read('/tmp/monitor.resolution.txt').strip.split('x')
                   rescue Object => _e
                     resolution = `xrandr -q | grep "*" | awk '{ print $1 }'`.strip
                     File.write('/tmp/monitor.resolution.txt', resolution)
                     resolution
                   end
    @w = raw_w.to_i
    @h = raw_h.to_i
  end

  def four_k?
    h == 2160
  end

  def qhd?
    h == 2160
  end

  def two_k?
    h == 1440
  end

  def hd?
    h == 1080
  end

  def left_padding
    50
  end

  def right_padding
    20
  end

  def top_padding
    40
  end

  def bottom_padding
    30
  end
end # class

