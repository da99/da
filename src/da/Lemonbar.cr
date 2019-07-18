
module DA
  class Lemonbar

    BACKGROUND       = "#000000"
    FOREGROUND       = "#D8EAFF"
    ORANGE           = "#F17400"
    LIGHT_FOREGROUND = "#1F6E55" # "#44000000" 
    PIPE             = "%{F#{LIGHT_FOREGROUND}} | %{F-}"

    getter input_pipe      : IO::FileDescriptor
    getter send_to_input   : IO::FileDescriptor
    getter get_from_output : IO::FileDescriptor
    getter output_pipe     : IO::FileDescriptor

    getter process : Process

    def self.new_loading(msg : String)
      bar = new("-B #000000 -F #D59C07 -n loading_#{Time.now.to_unix}".split)
      bar.write("%{c}#{msg}%{-c}")
      bar
    end # === def

    def initialize(args : Array(String)? = nil)
      cmd_args = "
      -p -a 20
        -B #{BACKGROUND}
        -F #{FOREGROUND}
        -f helv:size=9:antialias=true
        -f fixed:size=9:antialias=true
        -f japanese:size=10:antialias=true:lang=ja
        -f fontawesome5freesolid:size=10:antialias=true
        -f fontawesome5brands:size=10:antialias=true
      ".split
      cmd_args.concat(args) if args
      @input_pipe, @send_to_input = IO.pipe
      @get_from_output, @output_pipe = IO.pipe
      @process = Process.new("lemonbar", cmd_args, input: @input_pipe, output: @output_pipe)
    end

    def <<(x : IO::Memory | String)
      send_to_input << x
    end

    def pipe
      send_to_input << Lemonbar::PIPE
    end

    # Write a newline to input pipe.
    def write
      send_to_input << '\n'
    end

    def join(x : Enumerable)
      last_i = x.size - 1
      x.each_with_index { |y, i|
        self << y 
        unless i == last_i
          self.pipe
        end
      }
      self
    end

    def write(str : IO::Memory | String)
      send_to_input.puts str
    end

    def read_line
      get_from_output.gets
    end

    def highlight(s)
      self << "%{F#{Lemonbar::ORANGE}}#{s}%{F-}"
    end

  end # === class Lemonbar

end # === module
