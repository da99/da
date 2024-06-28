
module DA
  struct Pactl

    def self.volume!
      match = `amixer get Master`.match(/\[([0-9]+)\%\]/)
      if match
        match[1].to_i32
      else
        -1
      end
    end # === def self.volume!

    def self.running?
      !!`pacmd list-sink-inputs`["state: RUNNING"]?
    end

    # =============================================================================
    # Instance:
    # =============================================================================

    getter input_pipe      : IO::FileDescriptor
    getter send_to_input   : IO::FileDescriptor
    getter get_from_output : IO::FileDescriptor
    getter output_pipe     : IO::FileDescriptor

    getter volume     : Int32 = -1
    getter is_running : Bool = false

    getter process : Process

    def initialize(cmd_args : Array(String) = ["subscribe"])
      @input_pipe, @send_to_input = IO.pipe
      @get_from_output, @output_pipe = IO.pipe

      @volume     = self.class.volume!
      @is_running = self.class.running?
      proc = @process    = Process.new("pactl", cmd_args, input: @input_pipe, output: @output_pipe)
      at_exit {
        unless proc.terminated?
          proc.kill
          DA.inspect! "killed pactl process: #{proc.pid}"
        end
      }
    end

    def write(str : IO::Memory | String)
      send_to_input.puts str
    end

    def read_line
      get_from_output.gets
    end

    def update
      @volume = self.class.volume!
      @is_running = self.class.running?
    end

    def running?
      @is_running
    end
  end # struct
end # === module
