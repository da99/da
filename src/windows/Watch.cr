


module DA

  # Example Usage:
  #
  # ----------------------------------------------
  # Signal::INT.trap { Signal::INT.reset; exit 0 }
  # Signal::TERM.trap { Signal::TERM.reset; exit 0 }
  # # ----------------------------------------------
  #
  # watches.each { |w|
  #   spawn {
  #     while w.readable?
  #       puts "--- getting: #{w.cmd}"
  #       puts w.read_line.inspect
  #       puts "--- done #{w.cmd}"
  #       sleep 0.1
  #     end
  #   }
  # }
  class Watch
    getter get_from_output : IO::FileDescriptor
    getter output_pipe     : IO::FileDescriptor

    getter proc    : Process
    getter cmd     : String
    getter args    : Array(String)
    getter seconds : Int32 = 0

    def self.new(cmd : String)
      self.new(0, cmd)
    end # def

    def initialize(@seconds, cmd : String)
      @get_from_output, @output_pipe = IO.pipe
      @args = cmd.split
      @cmd = args.shift.not_nil!
      proc = @proc = Process.new(@cmd, @args, output: @output_pipe, error: @output_pipe)
      w = self
      at_exit { w.kill }
    end

    def long_running?
      @seconds == 0
    end # def

    def readable?
      if long_running?
        !@proc.terminated?
      else
        true
      end
    end # def

    def kill
      unless proc.terminated?
        proc.kill
        DA.inspect! "killed: #{cmd.inspect} #{args.join ' '}: #{proc.pid}"
      end
    end # def

    def read_line
      return nil if long_running? && !readable?

      return @get_from_output.gets if long_running? && readable?

      if !long_running? && @proc.terminated?
        sleep seconds
        # DA.inspect! "=== Running #{cmd} #{args.join ' '}"
        @proc = Process.new(cmd, args, output: output_pipe, error: output_pipe)
      end

      @get_from_output.gets
    end # def

  end # === class

end # === module

