
module DA

  # =============================================================================
  struct Process
    # Linux systems can't use an exit status code higher than 255:
    # https://unix.stackexchange.com/questions/394639/why-do-high-exit-codes-on-linux-shells-256-not-work-as-expected
    # For TTY, use `STDOUT.tty?`.

    module Class_Methods
      def bin_name : String
        File.basename(::Process.executable_path.not_nil!)
      end # === def

      def app_dir : String
        exec_path = ::Process.executable_path
        if exec_path
          dir = File.dirname(exec_path)
          if File.basename(dir) == "bin"
            File.dirname(dir)
          else
            dir
          end
        else
          Dir.current
        end
      end # def app_dir

      def app_dir(*args : String)
        File.join(*args)
      end # === def app_dir

      def exec!(bin : String, args : Array(String) = [] of String, *others)
        DA.orange! "=== {{Exec}}: BOLD{{#{bin}}} #{args.map(&.inspect).join ' '}"
        ::Process.exec(bin, args, *others)
      end

    end # === module Class_Methods

    extend Class_Methods

    getter output = IO::Memory.new
    getter error  = IO::Memory.new
    getter cmd    : String
    getter args   : Array(String)
    getter status : ::Process::Status

    def initialize(raw_cmd : String | Array(String))
      full_cmd = case raw_cmd
                 when String
                   raw_cmd.split
                 else
                   raw_cmd
                 end # case

      @cmd = full_cmd.shift
      @args = full_cmd
      DA.debug "=== {{Running}}: #{@cmd} #{@args.join ' '}"
      @status = ::Process.run(@cmd, @args, output: @output, error: @error)
      @output.rewind
      @error.rewind
    end # === def initialize

    def success?
      @status.success?
    end # === def success?

    def success!
      return self if success?
      DA.red! "{{\"#{@cmd} #{@args.join ' '}}}\" failed.\n#{output}\n#{error}"
      ::exit status.exit_code
    end # def

    def out_err
      output.to_s + error.to_s
    end

    struct Inherit
      getter cmd    : String
      getter args   : Array(String)
      getter status : ::Process::Status

      def initialize(raw_cmd : String | Array(String))
        full_cmd = case raw_cmd
                   when String
                     raw_cmd.split
                   else
                     raw_cmd
                   end # case

        @cmd = full_cmd.shift
        @args = full_cmd
        if STDERR.tty? || DA.debug?
          DA.orange! "=== {{Running}}: #{@cmd} #{@args.join ' '}"
        end
        @status = ::Process.run(@cmd, @args, output: ::Process::Redirect::Inherit, error: ::Process::Redirect::Inherit, input: ::Process::Redirect::Inherit)
      end # === def initialize

      def success?
        @status.success?
      end # === def success?

      def success!
        return self if success?
        DA.red! "{{\"#{@cmd} #{@args.join ' '}}}\" failed."
        ::exit status.exit_code
      end # def
    end # === struct
  end # === struct Child_Process

end # === module DA
