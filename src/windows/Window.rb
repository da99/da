# frozen_string_literal: true

class Window
  class Root
    attr_reader :w, :h, :x, :y

    def initialize
      @x = @y = 0
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

  class << self
    def root
      @root ||= Root.new
    end

    def border
      3
    end

    def margin
      10
    end

    def new_current
      raw_id = `xdotool getactivewindow`.strip
      raise 'No current window found.' if raw_id.empty?

      Window.new raw_id
    end # def
  end # class

  attr_reader :id, :x, :y, :w, :h, :border_x, :border_y

  def initialize(raw_id)
    @id = 0
    @x = @y = 0
    @w = @h = 0
    @border_x = @border_y = 0
    @wm_class = nil
    @title = nil

    @id = raw_id.to_i

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

