
_temp = `which crystal`.strip
if !_temp.empty?
  _dir = File.dirname(File.dirname(_temp))
  ENV["SHARDS_INSTALL_PATH"] = File.join(Dir.current, "/.shards/.install")
  ENV["CRYSTAL_PATH"] = "#{_dir}/share/crystal/src:#{Dir.current}/.shards/.install"
end
require "file_utils"

module DA
  extend self
end # === module DA

require "./da/Inspect"
require "./da/Crystal"
require "./da/Dev"
require "./da/Backup"
require "./da/Cache"
require "./da/Process"
require "./da/CLI"
require "./da/Help"
require "./da/Error"
require "./da/File"
require "./da/String"
require "./da/Repo"
require "./da/Git"
require "./da/Exit"
require "./da/VoidLinux"
require "./da/File_System"

require "./da_deploy/Init"
require "./da_deploy/Release"
require "./da_deploy/App"
require "./da_deploy/Linux"
require "./da_deploy/Dev"
require "./da_deploy/Deploy"
require "./da_deploy/Runit"
require "./da_deploy/Public_Dir"
require "./da_deploy/PG"
