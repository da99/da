# frozen_string_literal: true

class Window
  class << self
    def border
      3
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
    @wm_class = nil
    @title = nil

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
    "Window id #{id}: w:#{w} h:#{h} x:#{x} y:#{y} wm_class:#{wm_class} title: #{title}"
  end

  def wm_class
    @wm_class ||= `xprop  -id #{id} '=$0.$1' WM_CLASS`.split('=').last.gsub('"', '')
  end

  def smplayer?
    wm_class == 'smplayer.smplayer'
  end

  def title
    @title ||= `xtitle #{id}`
  end

  def move_to(pos)
    system(%( wmctrl -i -r #{id} -e 0,#{pos.x},#{pos.y},#{pos.w},#{pos.h} ))
  end
end # === class Window
