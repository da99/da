# frozen_string_literal: true

class Custom_Area
  attr_accessor :area
  attr_reader :window
  attr_writer :x, :y, :w, :h

  def initialize(raw_area, raw_window)
    @area = case raw_window.wm_class
            when 'smplayer.smplayer'
              case raw_area
              when Bottom_Half
                Bottom_Stamp
              when Top_Half
                Top_Stamp
              else
                raw_area
              end
            else
              raw_area
            end
    @window = raw_window
    @name = @area.name
  end # end

  def name
    area.name
  end

  def stamp?
    area.stamp?
  end

  def x
    area.x
  end

  def y
    area.y
  end

  def w
    case window.wm_class
    when 'Alacritty.Alacritty', 'caja.Caja', 'Navigator.Firefox'
      area.w - Window.border
    else
      area.w
    end # .wm_class
  end

  def h
    case window.wm_class
    when 'Alacritty.Alacritty', 'caja.Caja', 'Navigator.Firefox'
      area.h - Window.border
    else
      area.h
    end # .wm_class
  end
end # class
