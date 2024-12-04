# frozen_string_literal: true

class State
  LOCAL_DATA = '/tmp/window_rb'
  attr_reader :window

  def initialize(win)
    @window = win
  end # def

  def stamp?
    !!State.read(window, 'location')[/Stamp/]
  end # def

  def previous_stamp?
    !!State.read(window, 'previous_location')[/Stamp/]
  end

  def move_to(location)
    previous = State.read(window, 'location')
    State.write(window, 'previous_location', previous)
    State.write(window, 'location', location.name)
  end # def

  class << self
    def ctrl_c
      `xdotool sleep 0.1 key --clearmodifiers ctrl+c`.strip
    end # def

    def move_window(window, location)
      state = State.new(window)

      case window.wm_class
      when 'smplayer.smplayer'
        if location.stamp? && !state.previous_stamp? # going into stamp
          ctrl_c
        elsif state.previous_stamp? && !location.stamp? # coming out of stamp
          ctrl_c
        end # if
      end # case

      state.move_to(location)
    end # def

    def read(window, title)
      File.write "#{LOCAL_DATA}/#{window.id}.#{title}.txt"
    rescue Errno::ENOENT => _e
      ''
    end # def

    def write(window, title, raw_content)
      file_name = "#{LOCAL_DATA}/#{window.id}.#{title}.txt"
      content = raw_content.to_s
      begin
        File.write file_name, content
      rescue Errno::ENOENT => _e
        `mkdir -p "#{LOCAL_DATA}"`
        File.write file_name, content
      end
    end # def
  end # class
end # class
