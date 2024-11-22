# frozen_string_literal: true

class Window
  class Move
    LOCAL_DATA = '/tmp/window_rb'

    attr_reader :window

    def initialize(win)
      @window = win
    end

    def move_to(pos)
      old_pos = read('current_position')
      system(%( wmctrl -i -r #{window.id} -e 0,#{pos.x},#{pos.y},#{pos.w},#{pos.h} ))
      write('old_position', old_pos) if old_pos
      write('current_position', pos.name.to_s)
    end # def

    def read(partial_file_name)
      File.read("#{LOCAL_DATA}/#{window.id}.#{partial_file_name}.txt")
    rescue Errno::ENOENT => _e
      nil
    end # def

    def write(partial_file_name, content)
      file_name = "#{window.id}.#{partial_file_name}.txt"
      begin
        File.write "#{LOCAL_DATA}/#{file_name}", content
      rescue Errno::ENOENT => _e
        `mkdir -p "#{LOCAL_DATA}"`
        File.write "#{LOCAL_DATA}/#{file_name}", content
      end
    end # def
  end # class
end # class
