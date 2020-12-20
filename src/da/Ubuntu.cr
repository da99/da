
module DA
  module Ubuntu
    extend self

    def upgrade
      DA::Process::Inherit.new("sudo apt-get autoclean").success!
      DA::Process::Inherit.new("sudo apt-get clean").success!
      # DA::Process::Inherit.new("sudo journalctl --vacuum-size=500M").success!
      DA::Process::Inherit.new("sudo apt-get update").success!
      DA::Process::Inherit.new("sudo apt-get upgrade").success!
      DA::Process::Inherit.new("sudo apt autoremove").success!
    end # def
  end # === module
end # === module
