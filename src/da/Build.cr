
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

    def all(dir)
      langs = [] of String
      Dir.cd(dir) {
        if File.exists?("bin/__.cr")
          DA::Process::Inherit.new("shards build -- --warnings all --release".split).success!
          langs << "crystal"
        end

        if File.exists?("package.json") && File.exists?("src/apps")
          DA::Build.nodejs(dir)
            langs << "js"
        end
      }

      langs
    end # def

    def nodejs(dir : String)
      dist_apps_js(dir)
      dist_www_modules(dir)
    end # def

    def dist_apps_js(dir)
      dist_files = "dist/files"
      src_apps  = "src/apps"
      return unless Dir.exists?(src_apps)
      Dir.cd(dir) {
        Dir.mkdir_p(dist_files)
        File_System::DIR
          .new("src/apps")
          .dirs(1)
          .basename
          .copy(src_apps, dist_files)
      }
    end # def

    def dist_www_modules(dir)
      node_modules = "node_modules/"
      www_modules  = "dist/files/www_modules/"
      return unless Dir.exists?(node_modules) && File.exists?("package.json")
      Dir.cd(dir) {
        package = NPM::Package_JSON.from_dir(dir)
        www = package.wwwDependencies
        return unless www
        File_System::DIRS.new(www.keys)
          .prefix(node_modules)
          .exists
          .files
          .select(/\.m?js$/)
          .relative_to(node_modules)
          .copy(node_modules, www_modules)
      } # Dir.cd
    end # def

  end # === module
end # === module
