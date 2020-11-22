
require "da_spec"

# ENV["IS_DEBUG"] = "YES"
  # DA_Spec.pattern "name of test"
  # DA_Spec.pattern /name of test/

# require "../src/da/Dev"
# require "../src/da/Git"
# require "../src/da/Process"
extend DA_SPEC



class SPEC

  DIR = Dir.current

  # def self.io_capture
  #   io = IO::Memory.new
  #   origin_err = STDERR
  #   origin_out = STDOUT
  #   STDERR = io
  #   STDOUT = io
  #   yield
  #   STDERR = origin_err
  #   STDOUT = origin_out
  #   io.rewind
  #   io.to_s
  # end # def

  def self.dir
    "/tmp/da_spec"
  end

  def self.da_bin
    File.join DIR, "bin/da"
  end # def

  def self.tmp_dir
    tmp = File.join dir, Time.utc.to_unix.to_s
    `mkdir -p #{tmp}`
    Dir.cd(tmp) {
      yield
    }
    `rm -rf #{tmp}`
  end # def

end # === class

# include Microtest::DSL
# Microtest.run!

