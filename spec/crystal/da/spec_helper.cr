

require "../../../src/DA_Spec"
require "../../../src/da"

extend DA_Spec

if !ARGV.empty?
  DA_Spec.pattern /#{ARGV.join ' '}/
  DA.orange! "=== {{Pattern}}: #{DA_Spec.pattern.inspect}"
end

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

  def reset_file_system
    `rm -rf   /tmp/specs_deploy`
    `mkdir -p /tmp/specs_deploy/var/service`
    `mkdir -p /tmp/specs_deploy/etc/sv`
    Dir.cd("/tmp/specs_deploy") {
      yield
    }
  end # === def reset_file_system

end # === class

