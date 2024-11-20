# frozen_string_literal: true

class State
  LOCAL_DATA = '/tmp/window_rb'

  def initialize; end

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

STATE = State.new
