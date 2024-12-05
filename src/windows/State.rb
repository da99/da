# frozen_string_literal: true

def ctrl_c
  `xdotool sleep 0.1 key --clearmodifiers ctrl+c`
end

class State
  LOCAL_DATA = '/tmp/window_rb'
  attr_reader :window

  def initialize(win)
    @window = win
  end # def

  def write_previous_location(location)
    State.write(window, 'previous_location', location.name.to_s)
  end # def

  def write_location(location)
    State.write(window, 'location', location.name)
  end # def

  def location?(location)
    State.read(window, 'location') == location.name.to_s
  end # def

  class << self
    def move_window(window, location)
      state = State.new(window)
      case window.wm_class
      when 'smplayer.smplayer'
        case location
        when Bottom_Stamp
          ctrl_c
          window.move_to(location)
        else
          if state.location?(Bottom_Stamp)
            ctrl_c
          end
        end # case
      end

      window.move_to(location)
    end # def

    def read(window, title)
      File.read("#{LOCAL_DATA}/#{window.id}.#{title}.txt")
    rescue Errno::ENOENT => _e
      ''
    end # def

    def write(window, title, content)
      file_name = "#{LOCAL_DATA}/#{window.id}.#{title}.txt"
      begin
        File.write file_name, content.to_s
      rescue Errno::ENOENT => _e
        `mkdir -p "#{LOCAL_DATA}"`
        File.write file_name, content
      end
    end # der
  end # class << self
end # class

STATE = State.new
