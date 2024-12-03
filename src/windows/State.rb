# frozen_string_literal: true

class State
  LOCAL_DATA = '/tmp/window_rb'
  attr_reader :window

  def initialize(win)
    @window = win
  end # def

  class << self
    def move_window(window, location)
      state = State.new(window)
      case window.wm_class
      when 'smplayer.smplayer'
        case location
        when Bottom_Stamp
          # Ctrl-C
        else
          if state.location?(Bottom_Stamp)
            # Ctrl-C
          end
        end # case
      else
        window.move_to(location)
      end
    end # def

    def write_position(window, location)
      file_name = "#{window.id}.location.txt"
      content = location.name.to_s
      begin
        File.write "#{LOCAL_DATA}/#{file_name}", content
      rescue Errno::ENOENT => _e
        `mkdir -p "#{LOCAL_DATA}"`
        File.write "#{LOCAL_DATA}/#{file_name}", content
      end
    end
  end # class
end # class

STATE = State.new
