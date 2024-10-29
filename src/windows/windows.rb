#!/usr/bin/env ruby
# frozen_string_literal: true

cmd = ARGV.join(' ')
prog = __FILE__.split('/').last

CORNER_AREA = 100

class Root_Window
  attr_reader :w, :h

  def initialize
    raw_w, raw_h = File.read('/tmp/monitor.resolution.txt').strip.split('x')
    @w = raw_w.to_i
    @h = raw_h.to_i
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
    50
  end

end # class

ROOT = Root_Window.new

class Window
  class << self
    def border
      4
    end

    def margin
      10
    end
  end # class

  attr_reader :id, :x, :y, :w, :h, :border_x, :border_y

  def initialize(raw_id = nil)

    @id = 0
    @x = @y = 0
    @w = @h = 0
    @border_x = @border_y = 0

    @id = if raw_id === nil
            `xdotool getactivewindow`.strip.to_i
          else
            raw_id.to_i
          end

    `xwininfo -id #{@id}`.strip.each_line do |line|
      last_piece = line.split.last
      case line
      when /Absolute upper-left X/
        @x = last_piece.to_i
      when /Absolute upper-left Y/
        @y = last_piece.to_i
      when /Relative upper-left X/
        @border_x = last_piece.to_i
      when /Relative upper-left Y/
        @border_y = last_piece.to_i
      when / Width: /
        @w = last_piece.to_i
      when / Height: /
        @h = last_piece.to_i
      end
    end # each_line
  end # def initialize

  def inspect
    "Window id #{id}: w:#{w} h:#{h} x:#{x} y:#{y}"
  end

  def move_to(pos)
    system(%( wmctrl -i -r #{id} -e 0,#{pos.x},#{pos.y},#{pos.w},#{pos.h} ))
  end

  def mouse_location
    m = Mouse_Pointer.new
    Pointer_Location.edge_name(self, m)
  end

end # === class Window

module Left_Side
  extend self

  def x
    ROOT.left_padding
  end

  def y
    ROOT.top_padding
  end

  def w
    (ROOT.w * 0.70).to_i - ROOT.left_padding - Window.margin
  end

  def h
    ROOT.h - ROOT.bottom_padding - y
  end

end # module

module Right_Top
  extend self

  def x
    (ROOT.w * 0.70).to_i + Window.margin
  end

  def y
    ROOT.top_padding
  end

  def w
    ROOT.w - x - Window.border
  end

  def h
    (ROOT.h / 2).to_i - ROOT.top_padding - Window.margin
  end
end # module

module Right_Bottom
  extend self

  def x
    (ROOT.w * 0.70).to_i + Window.margin
  end

  def y
    (ROOT.h / 2).to_i + Window.margin
  end

  def w
    ROOT.w - x - Window.border
  end

  def h
    (ROOT.h / 2).to_i - Window.margin - Window.border
  end
end # module

module Bottom_Stamp
  extend self

  def x
    ROOT.w - w - Window.border
  end

  def y
    ROOT.h - h - Window.border
  end

  def w
    return (1920 * 0.15).to_i if ROOT.h == 1080

    (ROOT.w * 0.15).to_i
  end

  def h
    (ROOT.h * 0.15).to_i
  end
end # module

module Fullscreen
  extend self

  def x
    ROOT.left_padding
  end

  def y
    ROOT.top_padding
  end

  def w
    ROOT.w - x - Window.border - Window.margin
  end

  def h
    ROOT.h - ROOT.top_padding - ROOT.bottom_padding
  end
end # module

module Window_Location
  extend self
end # === module

module Pointer_Location
  extend self

  def edge_name(window, mouse)
    tb = if top_edge?(window, mouse)
           'top'
         else
           (bottom_edge?(window, mouse) ? 'bottom' : nil)
         end
    lr = if left_edge?(window, mouse)
           'left'
         else
           (right_edge?(window, mouse) ? 'right' : nil)
         end

    return "#{tb}_#{lr}_corner" if tb && lr
    return "#{tb}_edge" if tb
    return "#{lr}_edge" if lr

    'center' if center?(window, mouse)
  end

  def top_edge?(window, mouse)
    mouse.y >= window.y && mouse.y < (window.y + CORNER_AREA)
  end

  def bottom_edge?(window, mouse)
    mouse.y <= (window.y + window.h) && mouse.y > (window.y + window.h - CORNER_AREA)
  end

  def left_edge?(window, mouse)
    mouse.x >= window.x && mouse.x < (window.x + CORNER_AREA)
  end

  def right_edge?(window, mouse)
    mouse.x < (window.x + window.w) && mouse.x >= (window.x + window.w - CORNER_AREA)
  end

  def center?(window, mouse)
    center_x = window.x + (window.w / 2).to_i
    center_y = window.y + (window.h / 2).to_i
    padding = 20
    half_corner = (CORNER_AREA + padding).to_i
    mouse.x >= (center_x - half_corner) && mouse.x < (center_x + half_corner) &&
      mouse.y >= (center_y - half_corner) && mouse.y < (center_y + half_corner)
  end
end # class

class Mouse_Pointer
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

case cmd
when '-h', '--help', 'help'
  puts "#{prog} -h|--help|help  --  Show this message."

when 'inspect'
  puts Window.new.inspect

when 'current_position'
  win_info = Window.new
  puts win_info.location

when 'mouse_location'
  puts Window.new.mouse_location

when 'move_to left'
  Window.new.move_to(Left_Side)
  exit($?.exitstatus)

when 'move_to bottom_stamp'
  Window.new.move_to(Bottom_Stamp)
  exit($?.exitstatus)

when 'move_to right_top'
  Window.new.move_to(Right_Top)
  exit($?.exitstatus)

when 'move_to right_bottom'
  Window.new.move_to(Right_Bottom)
  exit($?.exitstatus)

when 'move_to fullscreen'
  Window.new.move_to(Fullscreen)
  exit($?.exitstatus)


else
  warn "!!! Unknown command: #{cmd}"
  exit 1

end # case
