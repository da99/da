
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
      Dir.cd(dir) {
        FileUtils.mkdir_p("dist/Public")
        FileUtils.cp_r("src/apps", "dist/Public/apps")
        FileUtils.cp_r("src/worker/", "dist/worker")
      }

      dist_postcss

      # Needed to help TypeScript find imported files:
      dist_www_modules(dir)

      Dir.cd(dir) {
        %w[dist/worker dist/Public/apps].each { |dist_dir|
          if File_System::DIR.new(dist_dir).files().any?(/\.ts$/)
            Process::Inherit.new("tsc --project #{dist_dir}".split).success!
          end
        }

        File_System::DIRS.new(%w[dist/Public/apps dist/worker])
          .files()
          .select(/\.ts$/)
          .raw
          .each { |ts|
            js = File_System::FILE.change_extension(ts, ".ts", ".js")
            mjs = File_System::FILE.change_extension(ts, ".ts", ".mjs")
            if File.exists?(js)
              FileUtils.mv js, mjs
            end
            FileUtils.rm(ts)
          }
      } # Dir.cd

      dist_html_mjs(dir)

      # Workaround: Set all import statements to use .mjs or .js
      File_System::DIR.new("dist/Public/apps")
        .files
        .raw
        .each { |f|
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
        } # each

      # Delete any redundant .js files if .mjs version exists.
      File_System::DIR.new("dist/Public/")
        .files
        .select(/\.js/)
        .raw
        .each { |f|
          mjs = File_System::FILE.change_extension(f, ".js", ".mjs")
          if File.exists?(mjs)
            FileUtils.rm f
          end
        }

      # Remove TypeScript related files.
      File_System::DIR.new("dist")
        .files
        .raw
        .each { |f|
          basename = File.basename(f)
          FileUtils.rm(f) if basename == "tsconfig.json" || basename[/\.ts$/]?
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
          .copy(node_modules, www_modules)
      } # Dir.cd
    end # def

    def dist_html_mjs(dir)
      Dir.cd(dir) {
        header = IO::Memory.new
        header << "import fs from \"fs\";\n"
        body = IO::Memory.new

        templates = File_System::DIR
          .new("dist/Public/apps/")
          .files
          .select(/\.html\.mjs$/)
          .reject(/\.partial\.html\.mjs$/)

        templates
          .raw
          .each_with_index { |template, i|
            new_file = File_System::FILE.change_extension(template, ".html.mjs", ".html")
            header << %[ import { html as html#{i} } from "./#{template}"; ] << '\n'
            body << %[ fs.writeFileSync("#{new_file}", html#{i}); ] << '\n'
          }

        Process::Inherit.new(["node", "--input-type=module", "-e", (header << body).to_s]).success!

        templates.remove()
      } # Dir.cd
    end # def

    def dist_postcss
      postcss = File.join(File.dirname(__FILE__), "../../sh/build.postcss.mjs")
      Process::Inherit.new("node #{postcss}".split).success!
    end # def

  end # === module
end # === module
