
module DA_Dev
  module Specs
    extend self
    extend DA_Dev

    def src
      "specs/__.cr"
    end

    def tmp
      "tmp/out/specs"
    end

    def compile
      Dir.mkdir_p(File.dirname tmp)
      STDERR.puts Colorize.orange "=== {{Compiling}}: specs ==="
      system(CRYSTAL_BIN, "build #{src} -o tmp/out/specs".split)
      stat = $?
      if DA_Process.success?(stat)
        green! "=== {{DONE}}: compiling specs ==="
      else
        raise Error.new("Specs failed to build: exit #{stat.exit_code}")
      end
      stat
    end

    def run(args = [] of String)
      if !File.exists?(tmp)
        compile
      end

      system(tmp, args)
      stat = $?
      if DA_Process.success?(stat)
        green! "=== {{DONE}}: BOLD{{spec run}} ==="
      else
        raise Error.new("Specs failed: exit #{stat.exit_code}")
      end
      stat
    end # === def run

  end # === module Specs
end # === module DA_Dev
