
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
      src_apps = "src/apps"
      www_modules = "../www_modules"
      dist_public_apps = "dist/Public/apps"
      Dir.cd(dir) {
        FileUtils.mkdir_p("dist/Public")
        if Dir.exists?(src_apps)
          FileUtils.cp_r(src_apps, "dist/Public/apps")
        end

        # Needed to help TypeScript find imported files:
        dist_www_modules(dir)

        if Dir.exists?(dist_public_apps)
          Dir.cd(dist_public_apps) {
            DIR.new
              .copy_unless_exists(tsconfig, DA.default_path("config/tsconfig.www.json"))
              .link_unless_exists("node_modules", DA.default_path("node_modules"))

            Process::Inherit.new("tsc".split).success!

            dist_html_templates(Dir.current)
            ts_js_mjs(".")
            fix_mjs_import_extensions(".")
            ts_js_mjs(www_modules) if Dir.exists?(www_modules)
          } # cd apps
        end # if
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

    def dist_html_templates(dir)
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

    def create_src_app(dirname : String)
      new_dir = "src/apps/#{dirname}"
      FU.mkdir_p(new_dir)
      Dir.cd(new_dir) {
        html, ts, css = F.new("index").new_append_exts(".html", ".ts", ".css")
        html.default_content(<<-EOF)
        <!doctype html>

        <html lang="en">
          <head>
            <meta charset="utf-8">
            <title>#{dirname}</title>
            <link rel="stylesheet" href="apps/#{dirname}/index.css?v=1.0">
          </head>

          <body>
            <p>loading...</p>
            <script type="module" src="apps/#{dirname}/index.mjs"></script>
          </body>
        </html>

        EOF

        ts.default_content(<<-EOF)
          console.log("#{dirname}");

        EOF

        css.default_content(<<-EOF)
          p { font-size: 2em; align-text: center; }

        EOF
      } # Dir.cd
    end # def

  end # === module
end # === module
