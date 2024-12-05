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

  def stamp?
    !!location[/Stamp/]
  end # def

  def previous_stamp?
    !!previous_location[/Stamp/]
  end

  def previous_fullscreen?
    previous_location == Fullscreen.name.to_s
  end

  def fullscreen?
    location == Fullscreen.name.to_s
  end

  def move_to(new_location)
    State.write(window, 'previous_location', location)
    State.write(window, 'location', new_location.name)
  end # def

  def previous_location
    State.read(window, 'previous_location')
  end

  def location
    State.read(window, 'location')
  end

  def previous_location!
    prev = previous_location
    return Left_Side if prev.empty?

    Object.const_get(prev)
  end

  def location!
    curr = location
    return Left_Side if curr.empty?

    Object.const_get(curr)
  end

  class << self
    def ctrl_c
      `xdotool sleep 0.1 key --clearmodifiers ctrl+c`.strip
    end # def

    def move_window(window, location)
      state = State.new(window)

      if window.wm_class == 'smplayer.smplayer'
        if location.stamp? && !state.previous_stamp? # going into stamp
          ctrl_c
        elsif state.previous_stamp? && !location.stamp? # coming out of stamp
          ctrl_c
        end # if
      end # case

      if location == Fullscreen && state.previous_fullscreen?
        location = state.previous_location!
      end # if Fullscreen

      state.move_to(location) unless state.location?(location)
      window.move_to location
    end # def

    def read(window, title)
      File.read "#{LOCAL_DATA}/#{window.id}.#{title}.txt"
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
  end # class << self
end # class
