#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH << File.dirname(File.expand_path(__FILE__))

require 'English'
require_relative 'Root_Window'
require_relative 'Mouse_Pointer'
require_relative 'Location_Name'

cmd = ARGV.join(' ')
prog = __FILE__.split('/').last

def smplayer?
  !!`xtitle`[' - SMPlayer']
end

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

    @id = if raw_id.nil?
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

module Top_Stamp
  extend self
  FACTOR = 0.25

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

module Bottom_Half
  extend self

  def x
    ROOT.left_padding
  end

  def y
    Top_Half.y + Top_Half.h
  end

  def w
    Fullscreen.w
  end

  def h
    ROOT.h - y - Window.border - ROOT.bottom_padding
  end
end # module

case cmd
when '-h', '--help', 'help'
  puts "#{prog} -h|--help|help  --  Show this message."

when 'inspect'
  puts Window.new.inspect

when 'mouse_location'
  puts Location_Name.new(Window.new, Mouse_Pointer.new).name

when 'root_mouse_location'
  puts Location_Name.new(ROOT, Mouse_Pointer.new).name

when 'move_to left'
  Window.new.move_to(Left_Side)
  exit($CHILD_STATUS.exitstatus)

when 'move_to bottom_stamp'
  Window.new.move_to(Bottom_Stamp)
  exit($CHILD_STATUS.exitstatus)

when 'move_to right_top'
  Window.new.move_to(Right_Top)
  exit($CHILD_STATUS.exitstatus)

when 'move_to right_bottom'
  Window.new.move_to(Right_Bottom)
  exit($CHILD_STATUS.exitstatus)

when 'move_to fullscreen'
  Window.new.move_to(Fullscreen)
  exit($CHILD_STATUS.exitstatus)

when 'move_to top_half'
  Window.new.move_to(Top_Half)
  exit($CHILD_STATUS.exitstatus)

when 'move_to bottom_half'
  Window.new.move_to(Bottom_Half)
  exit($CHILD_STATUS.exitstatus)

when 'run_action'
  loc = Location_Name.new(ROOT, Mouse_Pointer.new)
  win = Window.new

  case loc.name
  when 'top_left_corner'
    win.move_to(Left_Side)
  when 'top_right_corner'
    win.move_to(Right_Top)
  when 'bottom_left_corner'
    win.move_to(Right_Bottom)
  when 'bottom_right_corner'
    puts 'bottom_right_corner'
  when 'top_edge'
    if smplayer?
      win.move_to(Top_Half)
    else
      win.move_to(Top_Stamp)
    end
  when 'bottom_edge'
    if smplayer?
      win.move_to(Bottom_Half)
    else
      win.move_to(Bottom_Stamp)
    end
  when 'left_edge'
    system 'xdotool key --clearmodifiers Alt_L+Left'
  when 'right_edge'
    system 'xdotool key --clearmodifiers Alt_L+Right'
  when 'center'
    win.move_to(Fullscreen)
  else
    puts loc.name.inspect
  end # case

else
  warn "!!! Unknown command: #{cmd}"
  exit 1

end # case
