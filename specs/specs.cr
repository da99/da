

require "../src/da_spec"

extend DA_SPEC

def run(raw)
  cmd    = "tmp/out/specs"
  args   = raw.split
  output = IO::Memory.new

  stat = Process.run(cmd, args, output: output, error: output)
  return({ stat.exit_code, output.rewind.to_s })
end # === def shell_out

if ARGV.empty?
  app = "tmp/out/specs"
  puts run("Good").last.inspect
  puts run("Bad").last.inspect
else
  Describe.pattern ARGV.join(" ")
  describe "Good" do
    it "passes" { assert 1 == 1 }
  end
  describe "Bad" do
    it "fails" { assert 1 == 2 }
  end # === desc "Bad"
end
