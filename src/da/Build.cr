
require "./Process"
require "./NPM"
require "./File_System"
require "./Default"

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

    FU    = FileUtils
    F     = File_System::FILE
    FILES = File_System::FILES
    DIR   = File_System::DIR
    DIRS  = File_System::DIRS

    def crystal_shard(dir)
      Dir.cd(dir) {
        DA::Process::Inherit.new("shards build -- --warnings all --release".split).success!
      }
    end # def

    def all(dir)
      langs = [] of String
      Dir.cd(dir) {
        if File.exists?("shard.yml")
          crystal_shard(dir)
          langs << "crystal"
        end

        if File.exists?("package.json") && File.exists?("src/apps")
          DA::Build.nodejs_www_app(dir)
          langs << "js"
        end

        if File.exists?("sh/build")
          DA::Process::Inherit.new("sh/build").success!
          langs << "sh/build"
        end
      }

      langs
    end # def

    def cloudflare_worker(dir : String)
      tsconfig = "tsconfig.json"
      dist_worker = "dist/worker"

      Dir.cd(dir) {
        FU.mkdir_p("dist")
        FU.cp_r("src/worker", dist_worker)

        DIR.new(dist_worker)
          .copy_unless_exists(tsconfig, DA.default_path("config/tsconfig.cloudflare.worker.json"))
          .link_unless_exists("node_modules", DA.default_path("node_modules"))

        Dir.cd(dist_worker) {
          DA::Process::Inherit.new("tsc")
          ts_js_mjs(".")
          fix_mjs_import_extensions(Dir.current)
        } # Dir.cd dist_worker
      } # Dir.cd
    end # def

    # Workaround because TypeScript, NodeJS + Browsers handle
    # paths differently:
    # Set all import statements to use .mjs or .js
    def fix_mjs_import_extensions(dir)
      Dir.cd(dir) {
        DIR.new(".").files.select(/\.mjs$/).each { |f|
          content = File.read(f)
          new_content = content.gsub(/import .+['"](?<file>.+)['"]/) { |full_match, m|
            js = "#{m["file"]}.js"
            mjs = "#{m["file"]}.mjs"
            Dir.cd(File.dirname(f)) {
              case
              when File.exists?(mjs)
                full_match.sub(m["file"], mjs)
              when File.exists?(js)
                full_match.sub(m["file"], js)
              else
                full_match
              end
            }
          } # .gsub
          if new_content != content
            File.write(f, new_content)
          end
        }
      }
    end # def

    def nodejs_www_app(dir : String)
      tsconfig = "tsconfig.json"
      Dir.cd(dir) {
        FileUtils.mkdir_p("dist/Public")
        FileUtils.cp_r("src/apps", "dist/Public/apps")

        # Needed to help TypeScript find imported files:
        dist_www_modules(dir)

        Dir.cd("dist/Public/apps") {
          DIR.new
            .copy_unless_exists(tsconfig, DA.default_path("config/tsconfig.www.json"))
            .link_unless_exists("node_modules", DA.default_path("node_modules"))

          Process::Inherit.new("tsc".split).success!

          DIR.new
            .files
            .select(/\.ts$/)
            .each_file { |ts|
              js, mjs = ts.new_ext(".ts", ".js", ".mjs")
              js.mv mjs if js.exists?
              ts.rm
            }

          dist_html_mjs(Dir.current)
          ts_js_mjs(".")
          fix_mjs_import_extensions(".")

          ts_js_mjs("../www_modules")
        } # cd apps
      } # Dir.cd
    end # def

    # Deletes any tsconfig.json
    # Deletes any .ts files.
    # Renames .js to .mjs
    def ts_js_mjs(dir)
      Dir.cd(dir) {
        files = File_System::DIR.new.files
        files.new.select_basename(/^tsconfig\.json$/).rm
        files.new.select(/\.ts$/).each_file do |ts|
          ts.rm
          js, mjs = ts.new_ext(".ts", ".js", ".mjs")
          # We check in case this is a .d.ts file w/o .js counterpart
          js.mv(mjs) if js.exists?
        end
        FileUtils.rm("node_modules") if File.exists?("node_modules")
      }
    end # def

    def dist_www_modules(dir)
      node_modules = "node_modules/"
      www_modules  = "dist/Public/www_modules/"
      return unless Dir.exists?(node_modules) && File.exists?("package.json")
      Dir.cd(dir) {
        package = NPM::Package_JSON.from_dir(dir)
        www = package.wwwDependencies
        return unless www
        File_System::DIRS.new(www.keys)
          .prefix(node_modules)
          .exists
          .files
          .select(/\.(m?js|ts)$/)
          .relative_to(node_modules)
          .each { |file|
            www_file = File.join(www_modules, file)
            FileUtils.mkdir_p File.dirname(www_file)
            FileUtils.cp(
              File.join(node_modules, file),
              www_file
            )
          }
      } # Dir.cd
    end # def

    def dist_html_mjs(dir)
      Dir.cd(dir) {
        header = IO::Memory.new
        header << "import fs from \"fs\";\n"
        body = IO::Memory.new

        templates = File_System::DIR
          .new
          .files
          .relative_to(Dir.current)
          .select(/\.html\.mjs$/)
          .reject(/\.partial\.html\.mjs$/)

        templates
          .raw
          .each_with_index { |template, i|
            new_file = F.new(template).ext(".html.mjs", ".html")
            header << %[ import { html as html#{i} } from "#{File.join ".", template}"; ] << '\n'
            body << %[ fs.writeFileSync("#{new_file}", html#{i}); ] << '\n'
          }

        Process::Inherit.new(["node", "--input-type=module", "-e", (header << body).to_s]).success!

        templates.rm
      } # Dir.cd
    end # def

    def dist_postcss
      postcss = File.join(File.dirname(__FILE__), "../../sh/build.postcss.mjs")
      Process::Inherit.new("node #{postcss}".split).success!
    end # def

  end # === module
end # === module
