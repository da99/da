
ORIGIN_ARGS = ARGV.dup.map(&.strip)
ARGV.clear

require "../src/da_spec"

extend DA_SPEC

class Result

  getter exit_code : Int32
  getter output : String
  getter status : Process::Status

  def initialize(@status, @exit_code, @output)
  end # === def initialize

end # === class Result

def run(raw)
  cmd    = Process.executable_path.not_nil!
  args   = raw.split
  output = IO::Memory.new

  stat = Process.run(cmd, args, output: output, error: output)
  return(Result.new(stat, stat.exit_code, output.rewind.to_s))
end # === def shell_out

def in_spec?
  ORIGIN_ARGS.empty?
end

if !in_spec?
  DA_SPEC.pattern ORIGIN_ARGS.join(' ')
end

require "./specs/*"


