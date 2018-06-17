
require "./da/Process"
_temp = DA.process_new("which", ["crystal"]).output.to_s.strip
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
require "./da/CLI"
require "./da/Help"
require "./da/Error"
require "./da/File"
require "./da/String"
require "./da/Repo"
require "./da/Git"
require "./da/VoidLinux"
require "./da/File_System"

require "./da/Release"
require "./da/App"
require "./da/Linux"
require "./da/Dev"
require "./da/Deploy"
require "./da/Runit"
require "./da/Public_Dir"
require "./da/PG"
