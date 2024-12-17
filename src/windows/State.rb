# frozen_string_literal: true

class State
  LOCAL_DATA = '/tmp/window_rb'
  attr_reader :window

  def initialize(win)
    @window = win
  end # def

  def inspect
    "#{window.id}: #{location} #{previous_location}"
  end

  def write_previous_location(new_location)
    State.write(window, 'previous_location', new_location.name.to_s)
  end # def

  def write_location(new_location)
    State.write(window, 'location', new_location.name)
  end # def

  def location?(q_location)
    case q_location
    when String
      !!location.downcase[q_location.downcase]
    when Regexp
      !!location[q_location]
    else
      location == q_location.name.to_s
    end
  end # def

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
    def old
      ids = Window.list_ids
      `ls -1 #{State::LOCAL_DATA}`.strip.split("\n").reject do |x|
        ids.include?(x.split('.').first.to_i)
      end
    end # def

    def prune
      old.each { |x| File.unlink(File.join(State::LOCAL_DATA, x)) }
    end

    def re_move
      Window.list_ids.map do |wid|
        w = Window.new(wid)
        s = State.new w
        w.move_to s.location!
        s
      end # Window
    end # def

    def ctrl_c
      `xdotool sleep 0.1 key --clearmodifiers ctrl+c`.strip
    end # def

    def move_window(window, custom_area)
      state = State.new(window)
      current_location = state.location

      case window.wm_class
      when 'smplayer.smplayer'
        if custom_area.stamp? && !current_location['Stamp'] # going into stamp
          ctrl_c
        elsif !custom_area.stamp? && current_location['Stamp'] # coming out of stamp
          ctrl_c
        end # if
      end # case .wm_class

      if custom_area.area == Fullscreen && current_location['Fullscreen']
        custom_area.area = state.previous_location!
      end # if Fullscreen

      state.move_to(custom_area) unless current_location[custom_area.name]
      window.move_to custom_area
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
