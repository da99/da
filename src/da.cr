
require "file_utils"

module DA
  extend self
  class Exception < ::Exception
  end
end # === module DA

require "./da/Process"
require "./da/Crystal"
require "./da/Dev"
require "./da/Backup"
require "./da/Cache"
require "./da/CLI"
require "./da/Help"
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
require "./da/Postgresql"
require "./da/Time"

require "./da/Script"

require "./da/Utility"

require "./da/Specs"

