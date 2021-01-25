
require "./File_System"
require "./Process"

module DA
  module Ubuntu
    extend self

    def upgrade
      # DA::Process::Inherit.new("sudo journalctl --vacuum-size=500M").success!
      DA::Process::Inherit.new("sudo apt update").success!
      DA::Process::Inherit.new("sudo apt upgrade").success!
      DA::Process::Inherit.new("sudo apt autoremove").success!
      DA::Process::Inherit.new("sudo apt autoclean").success!
      DA::Process::Inherit.new("sudo apt clean").success!

      x = (File_System.free_space("/tmp") / 1024).to_i
      if x < 500
        raise "!!! Not enouch space in /tmp: #{x} MB"
      end

      OS.free_space_check
    end # def
  end # === module
end # === module
