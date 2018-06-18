
ORIGIN_ARGS = ARGV.dup
ARGV.clear

require "../src/da_spec"

extend DA_SPEC

class Result

  getter exit_code : Int32
  getter output : String
  def initialize(@exit_code, @output)
  end # === def initialize

end # === class Result

def run(raw)
  cmd    = "tmp/out/specs"
  args   = raw.split
  output = IO::Memory.new

  stat = Process.run(cmd, args, output: output, error: output)
  return(Result.new(stat.exit_code, output.rewind.to_s))
end # === def shell_out

def in_spec?
  ORIGIN_ARGS.empty?
end

if !in_spec?
  DA_SPEC.pattern ORIGIN_ARGS.join(" ")
end

require "./specs/*"




