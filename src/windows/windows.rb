#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH << File.dirname(File.expand_path(__FILE__))

require 'English'
require_relative 'Root_Window'
require_relative 'Window'
require_relative 'Mouse_Pointer'
require_relative 'Location_Name'

require_relative 'Fullscreen'
require_relative 'Left_Side'
require_relative 'Right_Bottom'
require_relative 'Right_Side'
require_relative 'Top_Half'
require_relative 'Top_Stamp'
require_relative 'Bottom_Half'
require_relative 'Bottom_Stamp'

cmd = ARGV.join(' ')
prog = __FILE__.split('/').last

def smplayer?
  !!`xtitle`[' - SMPlayer']
end

ROOT = Root_Window.new

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
