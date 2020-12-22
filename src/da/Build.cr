
require "./Process"
require "./NPM"
require "./File_System"

module DA

  struct WWW_DEP
    getter name : String
    getter dir : String
    getter files : File_System::FILES

    def initialize(@name)
      @dir = "node_modules/#{name}"
      @files = FILES.new(@dir)
    end # def

    def exists?
      File.exists? File.join(dir, "package.json")
    end # def

    def ignored
      files.select { |x|
        case x
        when "LICENSE", "README.md", "README"
          true
        end
      }
    end # def
  end # === struct

  module Build
    extend self

    def www_modules
      package = NPM::Package_JSON.from_dir(Dir.current)
      www = package.wwwDependencies
      return unless www
      node_modules = "node_modules/"
      www_modules  = "dist/files/www_modules/"
      File_System
        .dirs(www.keys)
        .prefix(node_modules)
        .exists
        .files
        .select(/\.(m?js|tsc)$/)
        .relative_to(node_modules)
        .copy(node_modules, www_modules)
    end # def

  end # === module
end # === module
