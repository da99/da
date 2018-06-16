
module DA
  module Crystal
    BIN = "crystal"
    extend self

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
