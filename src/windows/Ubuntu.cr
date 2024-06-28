
require "./File_System"
require "./Process"

module DA
  module Ubuntu
    extend self

    def upgrade
      [
        "journalctl --vacuum-time=1d",
        "journalctl --vacuum-size=100M",
        "apt update",
        "apt autoremove",
        "apt autoclean",
        "apt clean",
        "apt upgrade",
        "apt autoremove",
        "apt autoclean",
      ].each { |x|
        DA::Process::Inherit.new("sudo #{x}").success!
      }

      x = (File_System.free_space("/tmp") / 1024).to_i
      if x < 500
        raise "!!! Not enouch space in /tmp: #{x} MB"
      end

      OS.free_space_check
    end # def
  end # === module
end # === module
