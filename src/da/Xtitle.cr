
module DA
  class Xtitle

    getter input_pipe      : IO::FileDescriptor
    getter send_to_input   : IO::FileDescriptor
    getter get_from_output : IO::FileDescriptor
    getter output_pipe     : IO::FileDescriptor

    getter process : Process

    def initialize(cmd_args : Array(String) = ["-s"])
      @input_pipe, @send_to_input = IO.pipe
      @get_from_output, @output_pipe = IO.pipe
      @process = Process.new("xtitle", cmd_args, input: @input_pipe, output: @output_pipe)
    end

    def write(str : IO::Memory | String)
      send_to_input.puts str
    end

    def read_line
      get_from_output.gets
    end

  end # === class

end # === module
