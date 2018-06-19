
require "http/client"

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

  module Crystal
    BIN = "crystal"
    extend self

    def docs_dir
      "/progs/crystal/current/share/doc/crystal"
    end

    def src_dir
      "/progs/crystal/current/share/crystal/src"
    end

    def src_file(partial : String)
      if partial.strip.empty?
        DA.exit! 1, "Empty search string: #{partial.inspect}"
      end

      Dir.cd "/progs/crystal/current/share"
      files = `find . -type f -ipath '*#{partial}*'`.strip.split('\n').reject { |x| x.strip.empty? }
      if files.empty?
        DA.exit! "No files found for:  #{partial.inspect}"
      end
      file = if files.size > 1
               DA.fzf(files)
             else
               files.first
             end
      if file[".html"]?
        DA.success! "xdg-open", [file]
      else
        Process.exec "nvim", ["-R", file]
      end
    end # === def src_file

    def src(args : Array(String))
      Dir.cd src_dir
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
    end # def


    def docs(path)
      Dir.cd docs_dir
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
    end # def docs

    def crystal(args : Array(String))
      DA.system! "crystal", args
    end

    def shards(args : Array(String))
      DA.system! "shards", args
    end

    def init
      VoidLinux.install("
        git llvm
        gc-devel libatomic_ops pcre-devel libevent-devel libyaml-devel
        libxml2-devel
        gc-devel libatomic_ops pcre-devel libevent-devel libyaml-devel
        libxml2-devel gmp-devel libressl-devel llvm gcc pkg-config
        readline-devel libyaml-devel gmp-devel libressl-devel
      ".split)
    end # === def init

    def install
      Dir.cd "/progs"
      host = "https://github.com"
      url  = "#{host}/crystal-lang/crystal/releases"
      doc  = HTTP::Client.get(url).body
      raw  = doc.split.find { |x|
        x[/releases\/download\/.+linux-x86_64\.tar\.gz/]?
      } || ""
      href = raw.split('"')[1]
      if !href
        DA.exit!("!!! Latest release not found: #{url}")
      end

      init

      Dir.cd("/tmp") {
        file = File.basename(href)
        dir = File.basename(href, "-linux-x86_64.tar.gz")
        target = File.join("/progs/crystal", dir)
        current = "/progs/crystal/current"
        Dir.mkdir_p(File.dirname(target))
        if !Dir.exists?(target)
          if !Dir.exists?(dir)
            DA.system!("wget", ["--continue",File.join(host, href)])
            DA.system!("tar", ["-xzf", file])
          end
          DA.system! "mv #{dir} #{target}"
        end
        DA.system! "ln -sf #{target} #{current}"
        Dir.cd(current) {
          Dir.glob("share/crystal/src/openssl/lib_*.cr").each { |f|
            contents = File.read(f)
              .sub(/OPENSSL_102 = .+/, %[OPENSSL_102 = {{ `command -v pkg-config > /dev/null && pkg-config --atleast-version=1.0.2 libssl && pkg-config --exists libtls || printf succ`.stringify == "succ" }}])
              .sub(/OPENSSL_110 = .*/, %[OPENSSL_110 = {{ `command -v pkg-config > /dev/null && pkg-config --atleast-version=1.1.0 libssl && pkg-config --exists libtls || printf succ`.stringify == "succ" }}])
            File.write(f, contents)
            DA.orange! "=== {{Updated}}: BOLD{{#{f}}}"
          }
          DA.system! "bin/crystal --version"
        }
      }
    end # === def install

    def init
      repo_name  = File.basename(Dir.current)
      shard_name = File.basename(Dir.current, ".cr")
      init_bin(shard_name, repo_name)
      init_gitignore
      Dir.mkdir_p("src")
      Dir.mkdir_p("specs")
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
      development_dependencies:
        da_spec:
          github: da99/da_spec.cr
        da_process:
          github: da99/da_process.cr
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

    def shards!(run_bin_compile = true)
      shard_yml = "shard.yml"
      shard_lock = "shard.lock"

      if !File.exists?(shard_yml)
        DA.exit! "!!! No #{shard_yml} file found."
      end

      if File.exists?(shard_lock) && File.info(shard_yml).modification_time < File.info(shard_lock).modification_time
        DA.orange! "=== {{Skipping shards install/update}}: #{shard_yml} hasn't changed."
        return
      end

      lock = File.exists?(shard_lock) ? File.read(shard_lock) : ""
      DA.system! "shards install"
      DA.system! "shards update"
      DA.system! "shards prune -v"

      # Sometimes no shard.lock is made if no shards are used.
      new_lock = if File.exists?(shard_lock)
                   File.read(shard_lock)
                 else
                   ""
                 end

      if run_bin_compile
        if lock != new_lock
          bin_compile
        else
          STDERR.puts "=== Skipping bin compile. shard.lock the same."
        end
      end
    end # === def shards

    def bin_compile(args = [] of String)
      shell_script = "sh/bin_compile.sh"
      if File.exists?(shell_script) && File.executable?(shell_script)
        DA.system! shell_script, args
        DA.green! "=== {{DONE}}: BOLD{{#{shell_script}}} ==="
        return
      end

      shards!(run_bin_compile: false)

      name = File.basename(Dir.current)
      bin  = "bin/#{name}"
      tmp  = "tmp/out/#{name}"
      src  = "bin/__.cr"
      Dir.mkdir_p "tmp/out"

      if File.exists?(bin)
        raw = `file --mime #{bin}`.strip
        mime = raw.split[1].split("/").first?
        executable = raw[" executable, "]?
        if mime != "application" && !executable
          DA.exit! " Non-binary file {{already exists}}: #{bin}"
        end
      end

      if args.size == 1 && args.first == "release"
        args[0] = "--release"
      end
      is_tmp = args.size == 1 && args.first == "tmp" && args.shift
      args = "build #{src} -o #{tmp}".split.concat(args)
      fin_bin = is_tmp ? tmp : bin
      DA.orange! "=== {{Compiling}}: #{Crystal::BIN} #{args.join " "} --> BOLD{{#{fin_bin}}}"
      DA.system!(Crystal::BIN, args)

      File.rename(tmp, bin) unless is_tmp
      DA.green! "=== {{Done}}: #{bin}"
    end # === def bin_compile
  end # === module Crystal
end # === module DA
