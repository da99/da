
module DA
  struct Xprop

    # =============================================================================
    # Instance:
    # =============================================================================

    getter input_pipe      : IO::FileDescriptor
    getter send_to_input   : IO::FileDescriptor
    getter get_from_output : IO::FileDescriptor
    getter output_pipe     : IO::FileDescriptor

    getter process : Process

    def initialize(cmd_args : Array(String))
      @input_pipe, @send_to_input = IO.pipe
      @get_from_output, @output_pipe = IO.pipe
      @process = Process.new("xprop", cmd_args, input: @input_pipe, output: @output_pipe)
    end # def

    # Setup a spy process for the window:
    def self.new_spy_title(win_id : String)
      new(["-id", win_id, "-spy", "_NET_WM_NAME"])
    end # def

    def write(str : IO::Memory | String)
      send_to_input.puts str
    end

    def read_line
      get_from_output.gets
    end

    def read_title
      s = read_line
      if s.is_a?(String)
        match = s.match /^.+ = "(.+)"$/
        if match
          return match[1]
        end
      end
    end

  end # === struct
end # module DA
