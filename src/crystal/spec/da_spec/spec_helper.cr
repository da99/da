
ORIGIN_ARGS = ARGV.dup.map(&.strip)
ARGV.clear

require "../../../src/DA_Spec"

extend DA_Spec

class Result

  getter exit_code : Int32
  getter output : String
  getter err : String
  getter status : Process::Status

  def initialize(@status, @exit_code, @output, @err)
  end # === def initialize

end # === class Result

def run(raw)
  args   = raw.split
  output = IO::Memory.new
  err = IO::Memory.new

  stat = Process.run(
    Process.executable_path.not_nil!,
    args,
    output: output,
    error: err
  )
  return(Result.new(stat, stat.exit_code, output.rewind.to_s, err.rewind.to_s))
end # === def shell_out

def in_spec?
  ORIGIN_ARGS.empty?
end

if !in_spec?
  DA_Spec.pattern ORIGIN_ARGS.join(' ')
end



