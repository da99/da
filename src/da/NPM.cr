
require "json"
require "./Process"

module DA
  module NPM
    class Package_JSON
      def self.from_dir(x)
        Dir.cd(x) {
          pkg = from_json(File.read "package.json")
          pkg.dir = x
          return pkg
        }
      end # def

      include JSON::Serializable

      getter dependencies :  Hash(String, String)?

      getter devDependencies : Hash(String, String)?

      property dir : String = Dir.current

      def git_modules
        mods = [] of Module_Package_JSON
        x = dependencies
        [dependencies, devDependencies].each { |x|
          next unless x
          x.each { |name, src|
            next unless Module_Package_JSON.git_src?(src)
            raw = File.read(File.join dir, "node_modules/#{name}/package.json")
            mods << Module_Package_JSON.from_json(raw)
          }
        }
        mods
      end # def
    end # class

    class Package_Requested
      include JSON::Serializable

      @[JSON::Field(key: "raw")]
      property raw : String

      @[JSON::Field(key: "rawSpec")]
      property rawSpec : String
    end # === class

    class Module_Package_JSON
      def self.git_src?(src : String)
        src[/^[^@].+\/.+/]?
      end # def

      include JSON::Serializable

      @current_commit = ""
      @latest_commit = ""

      getter name : String
      getter _resolved : String
      getter _from : String
      getter _requiredBy : Array(String)
      getter _requested : Package_Requested

      def url
        "https://github.com/#{_from.split(':').last.split('#').first}"
      end # def

      def current_commit
        if @current_commit.empty?
          @current_commit = _resolved.split('#').last
        end
        @current_commit
      end # def

      def latest_commit
        if @latest_commit.empty?
          @latest_commit = `git ls-remote #{url} HEAD`.strip.split.first
        end
        @latest_commit
      end # def

      def new_src
        "#{_from.split('#').first}##{latest_commit}"
      end

      def dev?
        _requiredBy.includes? "#DEV:/"
      end

      def update?
        latest_commit != current_commit
      end # def

      def update!
        DA::Process::Inherit.new("npm remove #{name}").success!
        if dev?
          DA::Process::Inherit.new("npm install --save-dev #{_requested.rawSpec}").success!
        else
          DA::Process::Inherit.new("npm install --save     #{_requested.rawSpec}").success!
        end
      end # def
    end # === class
  end # === module
end # === class
