
ENV["SHARDS_INSTALL_PATH"] = File.join(Dir.current, "/.shards/.install")
ENV["CRYSTAL_PATH"] = "/usr/lib/crystal:#{Dir.current}/.shards/.install"
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
