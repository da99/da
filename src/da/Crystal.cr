
require "http/client"
require "./Process"

module DA
  def fzf(stuff : Array(String))
    r, w = IO.pipe
    stuff.each { |str|
      w.puts str
    }
    results = IO::Memory.new
    Process.run("fzf", "--reverse --no-hscroll --ansi --tabstop=2 -i".split, output: results, input: r, error: STDERR)
    results.to_s.strip
  end

  class Crystal
    BIN = "crystal"

    struct Release
      getter path     : String
      getter version  : String
      getter basename : String
      getter dirname  : String

      def initialize
        host = "https://github.com"
        url  = "#{host}/crystal-lang/crystal/releases"
        doc  = HTTP::Client.get(url).body
        raw  = doc.split.find { |x|
          x[/releases\/download\/.+linux-x86_64\.tar\.gz/]?
        } || raise("!!! Latest version not found.")

        @path = raw.split('"')[1]? || raise("!!! Latest version not found.")
        @basename = File.basename(@path)
        @version = File.basename(@basename, ".tar.gz").sub("-linux-x86_64","").sub("crystal-", "")
        @dirname =  File.basename(@basename, "-linux-x86_64.tar.gz")
      end # def
    end # === struct

    def self.latest_version
    end # def

    getter base_dir : String = "/progs/crystal"
    getter target_version : String = "1.0.0-1"

    def initialize
    end # def

    def initialize(@base_dir, @target_version)
    end # def

    def docs_dir
      File.join base_dir, "current/share/doc/crystal"
    end

    def src_dir
      File.join base_dir, "current/share/crystal/src"
    end

    def src_file(partial : String)
      if partial.strip.empty?
        DA.exit! 1, "Empty search string: #{partial.inspect}"
      end

      Dir.cd(File.join(base_dir, "current/share")) {
        files = `find . -type f -ipath '*#{partial}*'`.strip.split('\n').reject { |x| x.strip.empty? }
        if files.empty?
            DA.exit! "No files found for:  #{partial.inspect}"
        end

        if files.size > 1
          DA.fzf(files)
        else
          files.first
        end
      }
      # if file[".html"]?
      #   file
      #   DA.success! "xdg-open", [file]
      # else
      #   Process.exec "nvim", ["-R", file]
      # end
    end # === def src_file

    def src(args : Array(String))
      Dir.cd(src_dir) {
        if args.includes?("-l") || args.includes?("--files-with-matches")
          files = DA.output("rg", args).strip
          if files.empty?
            DA.orange! "=== No files found."
            return
          else
            file = DA.fzf(files.split('\n'))
            if File.file?(file)
              Process.exec("nvim", ["-R", file])
            else
              return
            end
          end
        else
          Process.exec("rg", args)
        end
      }
    end # def


    def docs(path)
      Dir.cd(docs_dir) {
        files = `find . -type f -ipath '*#{path}*'`.strip.split('\n').reject { |x| x.strip.empty? }
        file = if files.size > 1
                 DA.success! "which fzf"
                 r, w = IO.pipe
                 files.each { |f|
                   w.puts f
                 }
                 results = IO::Memory.new
                 Process.run("fzf", "--reverse --no-hscroll --ansi --tabstop=2 -i".split, output: results, input: r, error: STDERR)
                 results.to_s.strip
               else
                 files.first
               end

        if File.file?(file)
          Process.exec "xdg-open", [file]
        end

        puts Dir.current.inspect
        puts file.inspect
        puts File.expand_path(file).inspect
        DA.exit! 1, "File not found: #{path} -> #{file}"
        exit 1
      }
    end # def docs

    # def crystal(args : Array(String))
    #   DA.system! "crystal", args
    # end

    def shards(args : Array(String))
      DA.system! "shards", args
    end

    def install
      Dir.mkdir_p base_dir
      Dir.cd(base_dir) {

        release = Release.new

        puts release.version
        puts release.basename
        puts release.dirname

        if Dir.exists?(release.dirname)
          puts "Directory exists: #{release.dirname}"
        end
      } # dir.cd


      exit 0

      # Dir.cd("/tmp") {
      #   file = File.basename(path)
      #   dir = File.basename(path, "-linux-x86_64.tar.gz")
      #   target = File.join("/progs/crystal", dir)
      #   current = "/progs/crystal/current"
      #   Dir.mkdir_p(File.dirname(target))
      #   if !Dir.exists?(target)
      #     if !Dir.exists?(dir)
      #       DA::Process.new("wget --continue #{File.join host, path}").success!
      #       DA::Process.new("tar -xzf #{file}").success!
      #     end
      #     DA::Process.new("mv #{dir} #{target}").success!
      #   end
      #   DA::Process.new("ln -sf #{target} #{current}").success!
      #   Dir.cd(current) {
      #     DA::Process.new("bin/crystal --version").success!
      #   }
      # }
    end # === def install

    def init
      repo_name  = File.basename(Dir.current)
      shard_name = File.basename(Dir.current, ".cr")
      init_bin(shard_name, repo_name)
      init_gitignore
      Dir.mkdir_p("src")
      Dir.mkdir_p("spec")
      init_shard_yml(shard_name, repo_name)
    end

    def init_bin(shard_name, repo_name)
      Dir.mkdir_p("bin")
      file = "bin/__.cr"
      default_contents = <<-EOF

      THIS_DIR = File.dirname(__DIR__)
      require "da"
      full_cmd = ARGV.join(" ")
      args     = ARGV.dup
      cmd      = args.shift

      case

      when "-h --help help".split.includes?(full_cmd)
        # === {{CMD}} -h|--help|help
        DA::Documentation.print_help([__FILE__])

      else
        red! "!!! Invalid arguments: \#{ARGV.map(&.inspect).join " "}"
        exit 1

      end # === case

      EOF

      if !File.exists?(file)
        File.write(file, default_contents)
        DA.green! "=== BOLD{{Wrote}}: {{#{file}}}"
      end
    end # === def init_bin

    def init_shard_yml(shard_name, repo_name)
      default_contents = <<-EOF
      name: #{shard_name}
      version: 0.0.0
      dependencies:
        da:
          github: da99/da
      EOF
      if File.exists?("shard.yml")
        DA::Crystal.shards!
      else
        File.write("shard.yml", default_contents)
        DA.green! "=== BOLD{{Wrote}}: {{shard.yml}}"
      end
    end # === def init_shard_yml

    def init_gitignore
      file = ".gitignore"
      old_contents = ""
      contents = if File.exists?(file)
                   old_contents = File.read(file).strip
                   old_contents.split("\n")
                 else
                   [] of String
                 end
      contents = contents.concat(%w[/tmp/ /.js_packages/ /shard.lock /.shards/]).sort.uniq
      contents.push("")
      contents = contents.join('\n')
      if !File.exists?(file)
        File.write(file, contents)
        DA.green! "=== BOLD{{Wrote}}: {{#{file}}}"
      else
        if old_contents.strip != contents.strip
          File.write(file, contents)
          DA.green! "=== BOLD{{Updated}}: {{#{file}}}"
        end
      end
    end

    def shards_clear!
      [File.join(ENV["HOME"], ".cache/shards"), ".shards"].each { |dir|
        if File.directory?(dir)
          DA.system! "rm -rf #{dir}"
        else
          DA.orange! "=== {{Not found}}: BOLD{{#{dir}}}"
        end
      }
    end

    # Returns a Boolean on whether the shard.lock file was updated.
    # You can use this to determine if you want to re-build your shard.
    def shards!(run_bin_compile = true) : Bool
      shard_yml = "shard.yml"
      shard_lock = "shard.lock"

      if !File.exists?(shard_yml)
        DA.red! "!!! No #{shard_yml} file found."
        exit 1
      end

      if File.exists?(shard_lock) && File.info(shard_yml).modification_time < File.info(shard_lock).modification_time
        DA.orange! "=== {{Skipping shards install/update}}: #{shard_yml} hasn't changed."
        return false
      end

      lock = File.exists?(shard_lock) ? File.read(shard_lock) : ""
      DA::Process::Inherit.new( "shards install" ).success!
      DA::Process::Inherit.new( "shards update" ).success!
      DA::Process::Inherit.new( "shards prune -v" ).success!

      # Sometimes no shard.lock is made if no shards are used.
      new_lock = if File.exists?(shard_lock)
                   File.read(shard_lock)
                 else
                   ""
                 end

      lock != new_lock
    end # === def shards

    def bin_compile(args = [] of String)
      # Check if a shell file exists in place of the target bin file:
      bin = "/apps/#{Dir.current}/bin/#{Dir.current}"
      if File.exists?(bin)
        raw = `file --mime #{bin}`.strip
        mime = raw.split[1].split("/").first?
        executable = raw[" executable, "]?
          if mime != "application" && !executable
            DA.red! " Non-binary file {{already exists}}: #{bin}"
            exit 1
        end
      end

      # Install and update shards, then build:
      shards!
      new_args = "build -- --warnings all".split.concat(args)
      if !File.read("shard.yml")["targets:"]?
          DA.red! "!!! No {{targets}} set in {{shard.yml}}."
          exit 1
      end

      DA.orange! "=== {{shards}} #{new_args.join ' '}"
      DA::Process::Inherit.new(["shards"].concat new_args).success!
    end # === def bin_compile
  end # === module Crystal
end # === module DA
