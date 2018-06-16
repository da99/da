
module DA
  module Crystal
    BIN = "crystal"
    extend self

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
      require "da_dev"
      full_cmd = ARGV.join(" ")
      args     = ARGV.dup
      cmd      = args.shift

      case

      when "-h --help help".split.includes?(full_cmd)
        # === {{CMD}} -h|--help|help
        DA_Dev::Documentation.print_help([__FILE__])

      else
        red! "!!! Invalid arguments: \#{ARGV.map(&.inspect).join " "}"
        exit 1

      end # === case

      EOF

      if !File.exists?(file)
        File.write(file, default_contents)
        DA_Dev.green! "=== BOLD{{Wrote}}: {{#{file}}}"
      end
    end # === def init_bin

    def init_shard_yml(shard_name, repo_name)
      default_contents = <<-EOF
      name: #{shard_name}
      version: 0.0.0
      dependencies:
        da_dev:
          github: da99/da_dev
      development_dependencies:
        da_spec:
          github: da99/da_spec.cr
        da_process:
          github: da99/da_process.cr
      EOF
      if File.exists?("shard.yml")
        DA_Dev.deps
      else
        File.write("shard.yml", default_contents)
        DA_Dev.green! "=== BOLD{{Wrote}}: {{shard.yml}}"
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
        DA_Dev.green! "=== BOLD{{Wrote}}: {{#{file}}}"
      else
        if old_contents.strip != contents.strip
          File.write(file, contents)
          DA_Dev.green! "=== BOLD{{Updated}}: {{#{file}}}"
        end
      end
    end

    def deps(run_bin_compile = true)
      shard_file = "shard.lock"
      shard_lock = File.exists?(shard_file) ? File.read(shard_file) : ""
      DA.system! "#{BIN} deps update"
      DA.system! "#{BIN} deps prune"
      new_shard_lock = File.read(shard_file)
      if run_bin_compile
        if shard_lock != new_shard_lock
          bin_compile
        else
          STDERR.puts "=== Skipping bin compile. shard.lock the same."
        end
      end
    end # === def deps

    def bin_compile(args = [] of String)
      shell_script = "sh/bin_compile.sh"
      if File.exists?(shell_script) && File.executable?(shell_script)
        DA.system! shell_script, args
        DA.green! "=== {{DONE}}: BOLD{{#{shell_script}}} ==="
        return
      end

      shard_yml = "shard.yml"
      shard_lock = "shard.lock"

      if File.exists?(shard_yml)
        if !File.exists?(shard_lock) || File.stat(shard_yml).mtime > File.stat(shard_lock).mtime
          deps(run_bin_compile: false)
        end
      end # if

      name = File.basename(Dir.current)
      bin  = "bin/#{name}"
      tmp  = "tmp/out/#{name}"
      src  = "bin/__.cr"
      Dir.mkdir_p "tmp/out"

      if File.exists?(bin)
        mime = `file --mime #{bin}`.split[1].split("/").first?
        if mime != "application"
          DA.exit_with_error! " Non-binary file {{already exists}}: #{bin}"
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
