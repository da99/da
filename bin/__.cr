
require "../src/da"
require "../src/da/CLI"
require "../src/da/Git"
require "../src/da/Enumerable"
require "../src/da/Network"
require "../src/da/CLI"
require "../src/da/File_System"
require "../src/da/String"
require "../src/da/Process"
require "../src/da/Dev"
require "../src/da/OS"
require "../src/da/Linux"
require "../src/da/Build"

full_cmd = ARGV.map(&.strip).join(" ")

DA::CLI.parse do |o|
  o.desc "fs list editable files [DIR]"
  o.run_if(full_cmd[/^fs list editable files/]?) {
    dir = ARGV[4]? || Dir.current
    Dir.cd(dir) {
      if Dir.exists?(".git")
        DA::Process::Inherit.new("git --git-dir=#{dir}/.git ls-files -oc --exclude-standard")
      else
        DA::Process::Inherit.new(<<-EOF.split).success!
          find ./ -maxdepth 5          \
            ! -path "*/lib/*"     \
            ! -path "*/.shards/*"     \
            ! -path "*/tmp/*"     \
            ! -path "*/node_modules/*"     \
            ! -path "*/bower_components/*"
        EOF
      end
    }
  } # run_if

  o.desc "fs remove files with ext [.ext .ext2 ...]"
  o.run_if(full_cmd[/^fs remove files with ext (.+)$/]?) {
    ARGV[4..-1].each { |ext|
      DA::File_System::FILES
        .new(Dir.current)
        .select_ext(ext)
        .each_file { |f|
          f.remove
          puts f.raw
        }
    } # each
  } # run_if

  o.desc "fs remove files named [STRING] ..."
  o.run_if(full_cmd[/^fs remove files named .+$/]?) {
    files = ARGV[4..-1]
    DA::File_System::FILES
      .new(Dir.current)
      .each_file { |f|
        if files.includes?(f.basename)
          f.remove
          puts f.raw
        end
      }
  } # run_if

  o.desc "fs rename files with ext [.ext1] [.ext2]"
  o.run_if(full_cmd[/^fs rename files with ext (\.[\.a-zA-Z0-9\-]+)\ +(\.[\.a-zA-Z0-9\-]+)$/]?) {
    DA::File_System::FILES.new(Dir.current)
      .select_ext(ARGV[-2])
      .each_file { |f|
        f.move f.rename_ext(ARGV[-2], ARGV.last)
        puts f.raw
      }
  } # run_if

  o.desc %{
    fs fix mjs import from extensions
      (Add ".js" or ".mjs" if the file exists in an "import ... from" statement.)
  }
  o.run_if(full_cmd == "fs fix mjs import from extensions") {
    DA::Build.fix_mjs_import_extensions(Dir.current)
  } # run_if

  o.desc %{ fs find node_modules }
  o.run_if(full_cmd == "fs find node_modules") {
    x = DA::Build.find_node_modules(Dir.current)
    if x
      puts x
    else
      exit 1
    end
  }

  o.desc %{ fs find js module file STRING }
  o.run_if(full_cmd["fs find js module file "]?) {
    x = DA::Build.find_js_module_file(ARGV.last)
    if x
      puts x
    else
      exit 1
    end
  }

  o.desc %{ reload keep-alive }
  o.run_if(full_cmd == "reload keep-alive") {
    DA::Process::Inherit.new(["pkill", "-USR1", "-f", "^da keep running"])
  } # run_if

  o.desc %{ keep-alive cmd -with args }
  o.run_if(full_cmd[/^keep-alive .+/]?) {
    raise "!!! Only run this on an interactive terminal." unless STDERR.tty?
    DA.orange! "=== \{\{Main process}}: #{Process.pid}"
    cmd = ARGV[1]
    args = ARGV[2..-1]
    pid = nil
    keep_running = true
    Signal::USR1.trap do
      case
      when pid.is_a?(Int64) && Process.exists?(pid.not_nil!)
        DA.orange! "--- Sending INT to: \{\{#{pid}}}"
        Process.signal(Signal::INT, pid.not_nil!)
      else
        puts "=== No process found."
      end
    end # trap

    while keep_running
      DA.orange! "=== {{Running}}: #{cmd} #{args.map(&.inspect).join ' '}"
      p = ::Process.new(
        cmd, args,
        output: ::Process::Redirect::Inherit,
        error: ::Process::Redirect::Inherit,
        input: ::Process::Redirect::Inherit
      )
      pid = p.pid
      DA.orange! "=== \{\{Current pid}}: #{pid}"
      p.wait
      puts "=== Process ended: #{pid}\n"
      sleep 1.second
    end
  } # run_if

  o.desc "run max [seconds] cmd -with args"
  o.run_if(full_cmd[/^run max \d+ .+/]?) {
    max = (ARGV[2].to_i32 * 10)
    if max < 1 || max > 250
      DA.red!("Max is out of range: 1-250")
      exit 1
    end
    cmd_with_args = ARGV[3..-1]
    count = 0
    while !DA::Process.new(cmd_with_args).success?
      sleep 0.1
      count += 1
      if count > max
        Process.exit 1
      end
    end
  }

  o.desc "backup"
  o.run_if(full_cmd == "backup") {
    DA.backup
  }

  # =============================================================================
  # NPM:
  # =============================================================================
  o.desc "npm install globals"
  o.run_if(full_cmd == "npm install globals") {
    # NOTE: Security: Prevent arbitiary code from running.
    DA::Process::Inherit.new(%w[
      npm config set ignore-scripts true
    ])
    DA::Process::Inherit.new(%w[
      npm install -g
      typescript
      jshint
      @cloudflare/wrangler
      stylelint
      stylelint-config-standard
    ])
  }

  o.desc "stylelint (uses default config file and \"**/*.css\")"
  o.run_if(full_cmd == "stylelint") {
    DA::Process::Inherit.new(["stylelint", "--config", DA.default_path("config/.stylelintrc.json"), "**/*.css"]).success!
  }

  o.desc "stylelint (uses default config file)"
  o.run_if(full_cmd[/^stylelint .+/]?) {
    DA::Process::Inherit.new(["stylelint", "--config", DA.default_path("config/.stylelintrc.json")].concat(ARGV[1..-1])).success!
  }

  # =============================================================================
  # Git:
  # =============================================================================
  o.desc "git is clean"
  o.run_if(full_cmd == "git is clean") {
    if DA::Git::Repo.new(Dir.current).clean?
      exit 0
    end
    exit 1
  }

  o.desc "git update"
  o.run_if(full_cmd == "update") {
    DA::Git::Repo.new(Dir.current).update_tree
  }

  o.desc "git status"
  o.run_if(full_cmd == "git status") {
    DA::Process::Inherit.new("git status").success!
    repo = DA::Git::Repo.new(Dir.current)
    errs = repo.errors
    errs.each { |e| DA.red!(e) }
    exit 0 if errs.empty?
    exit 1
  }

  o.desc "git is staged"
  o.run_if(full_cmd == "git is staged") {
    repo = DA::Git::Repo.new(Dir.current)
    if repo.staged?
      exit 0
    else
      exit 1
    end
  }

  o.desc "git commit ..."
  o.run_if(full_cmd[/^git commit /]?) {
    repo = DA::Git::Repo.new(Dir.current)
    if repo.staged?
      DA::Process::Inherit.new(ARGV).success!
      DA::Process::Inherit.new("git status".split)
      exit 0
    end

    DA.red! "BOLD{{!!!}} Nothing has been {{staged}}."
    DA::Process::Inherit.new("git status".split)
    exit 1
  }

  o.desc "git is committed"
  o.run_if(full_cmd == "git is committed") {
    if !DA::Git::Repo.new(Dir.current).commit_pending?
      exit 0
    end
    exit 1
  }

  o.desc "git commit is pending"
  o.run_if(full_cmd == "git commit is pending") {
    if DA::Git::Repo.new(Dir.current).commit_pending?
      exit 0
    end
    exit 1
  }

  o.desc "git commit ..."
  o.run_if(full_cmd[/^git commit .+/]?) {
    DA::Git::Repo.new(Dir.current).commit ARGV[2...-1]
  }

  o.desc "git development checkpoint"
  o.run_if(full_cmd == "git development checkpoint") {
    if File.exists?("sh/devcheck")
      DA::Process::Inherit.new("sh/devcheck".split)
    end
    DA::Git::Repo.new(Dir.current).development_checkpoint
  }

  o.desc "git latest tag"
  o.run_if(full_cmd == "git latest tag") {
    puts DA::Git::Repo.new(Dir.current).latest_tag
  }

  o.desc "repo update packages"
  o.run_if(full_cmd == "repo update packages") {
    DA::Git::Repo.new(Dir.current).update_packages
  }

  o.desc "next dirty repo [directory]? [directory]? ..."
  o.run_if(full_cmd[/^next dirty repo/]?) {
    repo = DA::Git::Repo.new(Dir.current)
    repos = ARGV[3..-1].map { |dir|
      raise("!!! Directory does not exist: #{dir}") unless Dir.exists?(dir)
      if DA::Git.repo?(dir)
        DA::Git::Repo.new(dir)
      else
        DA::Git::Repos.new(dir).repos
      end
    }.compact.flatten

    DA.round_about(repos, ->(r : DA::Git::Repo) { r.dir == repo.dir }) { |r|
      if r.dirty?
        puts r.dir
        exit 0
      end
    }
  }

  o.desc "gitignore"
  o.run_if(full_cmd == "gitignore") {
    repo = DA::Git::Repo.new(Dir.current)
    origin = File.exists?(".gitignore") ? File.read(".gitignore").split('\n') : Array(String).new
    if repo.crystal?
      origin << "/lib/"
    end

    if repo.typescript?
      origin << "/build/"
    end

    if repo.nodejs?
      origin << "/node_modules/"
    end

    if repo.wrangler?
      origin << "/dist/"
      entry_point = File.read("wrangler.toml")
      match = File.read("wrangler.toml").match(/entry-point\s+=\s+"(.+)"/)
      if match
        origin <<  File.expand_path(File.join(match[1], "worker/"), "/")
        origin <<  File.expand_path(File.join(match[1], "node_modules/"), "/")
      end
    end

    origin.uniq!
    origin << ""
    File.write(".gitignore", origin.join('\n'))
  } # run_if

  # =============================================================================
  # Crystal:
  # =============================================================================

  # =============================================================================
  # Dev:
  # =============================================================================
  o.desc "watch"
  o.run_if(full_cmd == "watch") {
    DA::Dev.watch
  }

  o.desc "watch run [file]"
  o.run_if(full_cmd[/^watch run .+/]?) {
    DA::Dev.watch_run(ARGV[2])
  }

  o.desc "is dev"
  o.run_if(full_cmd == "is dev") {
    exit 0 if DA.development?
    exit 1
  }

  o.desc "build crystal shard"
  o.run_if(full_cmd == "build crystal shard") {
    DA::Build.crystal_shard(Dir.current)
  }

  o.desc "build nodejs www app"
  o.run_if(full_cmd == "build nodejs www app") {
    DA::Build.nodejs_www_app(Dir.current)
  }

  o.desc "build src/apps [NAME]"
  o.run_if(full_cmd[/^build src\/apps ([A-Za-z0-9\.\-]+)$/]?) {
    DA::Build.create_src_app(ARGV.last)
    DA::Process::Inherit.new("tree src/apps/#{ARGV.last}".split)
  }

  o.desc "build (Build everything.)"
  o.run_if(full_cmd == "build") {
    langs = DA::Build.all(Dir.current)
    if langs.empty?
      DA.red! "!!! No builds found."
      exit 1
    end
  }

  o.desc "build cloudflare worker"
  o.run_if(full_cmd == "build cloudflare worker") {
    DA::Build.cloudflare_worker(Dir.current)
  }

  o.desc "build .html from .html.mjs"
  o.run_if(full_cmd == "build .html from .html.mjs") {
    DA::File_System::FILES.new(Dir.current)
      .select_ext(".html.mjs")
      .each_file { |file|
        new_file = file.remove_ext(".mjs")
        new_file.write(DA::Process.new(["node", file.raw]).success!.output)
        puts new_file.raw
      } # each_file
  }

  # =============================================================================
  # Linux:
  # =============================================================================
  o.desc "os create system user [string]"
  o.run_if(full_cmd[/^os create system user .+$/]?) {
    DA::Linux.useradd_system(ARGV.last)
  }

  o.desc "os name"
  o.run_if(full_cmd == "os name") {
    puts DA::OS.name
  }

  o.desc "os upgrade"
  o.run_if(full_cmd == "os upgrade") {
    DA::OS.upgrade
  }

  o.desc "link symbolic [origin] [new_location]"
  o.run_if(full_cmd[/^link symbolic\!? .+ .+$/]?) {
    DA::File_System.symlink!(ARGV[2], ARGV[3])
  }

  o.desc "GREEN .... text ... [STDOUT]"
  o.run_if(full_cmd[/^GREEN .+$/]?) {
    DA.green! ARGV[1..-1].join(' ')
  }

  o.desc "ORANGE .... text ... [STDERR]"
  o.run_if(full_cmd[/^ORANGE .+$/]?) {
    DA.orange! ARGV[1..-1].join(' ')
  }

  o.desc "RED .... text ... [STDERR]"
  o.run_if(full_cmd[/^RED .+$/]?) {
    DA.red! ARGV[1..-1].join(' ')
  }

  # =============================================================================
  # Void Linux:
  # =============================================================================
  o.desc "voidlinux upgrade"
  o.run_if(full_cmd == "voidlinux upgrade") {
    DA::VoidLinux.upgrade
  }

  # =============================================================================
  # Network:
  # =============================================================================
  o.desc "network time"
  o.run_if(full_cmd == "network time") {
    puts DA::Network.time
  }

  # =============================================================================
  # Release:
  # =============================================================================
  o.desc "bump [major|minor|patch]"
  o.run_if(full_cmd[/^bump (major|minor|patch)$/]?) {
    DA::Git::Repo.new(Dir.current).bump(ARGV.last)
  }

end # parse

DA::CLI.exit!

# === File_System =============================================================
# =============================================================================
# when full_cmd[/void install .+/]?
#   # === {{CMD}} void install ...packages...
#   DA::VoidLinux.install ARGV[2..-1]

# when ARGV[0..1].join(' ') == "crystal docs"
#   # === {{CMD}} crystal doc partial_path ...
#   # View a Crystal docs HTML file in the browser.
#   DA::Crystal.docs ARGV[2]

# when ARGV[0..1].join(' ') == "crystal src"
#   # === {{CMD}} crystal src -args to rg
#   # Search the Crystal source code using ripgrep (rg).
#   DA::Crystal.src(ARGV[2..-1]

# when ARGV[0..1].join(' ') == "crystal file"
#   # === {{CMD}} crystal file search_path
#   # Search for a Crystal source file or a doc HTML file
#   #   using find . -type f -ipath '*#{YOUR_STRING}*'
#   DA::Crystal.src_file(ARGV[2])

# when ARGV[0]? == "crystal" && ARGV[1]?
#   # === {{CMD}} crystal --args ...
#   args = ARGV.clone
#   args.shift
#   DA::Crystal.crystal args
# =============================================================================

# when full_cmd == "crystal shards cache clear"
#   # === {{CMD}} shards cache clear
#   DA::Crystal.shards_clear!

# when ARGV[0]? == "shards"
#   # === {{CMD}} shards [--args ...]
#   args = ARGV.clone
#   args.shift
#   DA::Crystal.shards args

# when full_cmd == "shards!"
#   # === {{CMD}} shards!
#   DA::Crystal.shards!



# when ARGV[0..1].join(' ') == "cache read" && ARGV.size == 3
#   # === {{CMD}} cache read KEY
#   cache = DA::Cache.new("raw")
#   cache.read ARGV[2]

# when ARGV[0..1].join(' ') == "cache write" && ARGV.size == 4
#   # === {{CMD}} cache write KEY VALUE
#   cache = DA::Cache.new("raw")
#   cache.write ARGV[2], ARGV[3]


# =============================================================================
# Deploy
# =============================================================================
# when full_cmd == "generate release id"
#   # === {{CMD}} generate release id
#   puts DA::Release.generate_id

# when full_cmd == "releases"
#   # === {{CMD}} releases # Prints list of release in current working directory
#   DA::Release.list(DA::App.new).each { |dir|
#     puts dir
#   }

# when full_cmd == "latest"
#   # === {{CMD}} latest release
#   puts DA::Release.latest!(DA::App.new)

# when full_cmd == "deploy init"
#   # === {{CMD}} deploy init
#   DA::Deploy.init

# when full_cmd == "deploy init ssh"
#   # === {{CMD}} deploy ssh
#   DA::Deploy.init_ssh

# when "#{ARGV[0]?} #{ARGV[1]?}" == "deploy remove" && ARGV[2]?
#   # === {{CMD}} deploy remove app_name
#   DA::App.new(ARGV[2]).remove!

# when "#{ARGV[0]?} #{ARGV[1]?}" == "deploy Public" && ARGV[2]?
#   # === {{CMD}} deploy Public app_name
#   DA::Deploy.public(ARGV[2])

# when full_cmd["upload shell config to "]?
#   # === {{CMD}} upload shell config to app_name
#   DA::Deploy.upload_shell_config_to(ARGV.last)

# # =============================================================================
# # Runit services:
# # =============================================================================

# when "service inspect" == "#{ARGV[0]?} #{ARGV[1]?}" && ARGV[2]?
#   # === {{CMD}} service inspect dir_service
#   service = if File.directory?(ARGV[2])
#               DA::Runit.new(File.basename(ARGV[2]), ARGV[2], ARGV[2])
#             else
#               DA::Runit.new(ARGV[2])
#             end
#   puts "name        #{service.name.inspect}"
#   puts "sv_dir      #{service.sv_dir.inspect}"
#   puts "service_dir #{service.service_dir.inspect}"
#   puts "pids        #{service.pids.inspect}"
#   puts "status      #{service.status.inspect}"
#   puts "run?        #{service.run?.inspect}"
#   puts "down?       #{service.down?.inspect}"
#   puts "exit?       #{service.exit?.inspect}"

# when "service down" == "#{ARGV[0]?} #{ARGV[1]?}" && ARGV[2]? && !ARGV[3]?
#   # === {{CMD}} service down dir_service
#   DA::Runit.new(ARGV[2]).down!

# when "service up" == "#{ARGV[0]?} #{ARGV[1]?}" && ARGV[2]?
#   # === {{CMD}} service up dir_service
#   DA::Runit.new(ARGV[2]).up!

# when "inspect" == ARGV[0]? && ARGV[1]? && !ARGV[2]?
#   # === {{CMD}} inspect app_name
#   app = DA::App.new(ARGV[1])

#   puts "name:       #{app.name}"
#   puts "dir:        #{app.dir}"
#   puts "latest:     #{DA::Release.latest(app).inspect}"
#   puts "releases:   #{DA::Release.list(app).inspect}"

# when "#{ARGV[0]?} #{ARGV[1]?} #{ARGV[2]?}" == "upload binary to"
#   # === {{CMD}} upload binary to remote_name
#   DA::Deploy.upload_binary_to_remote ARGV[3]

# when "#{ARGV[0]?} #{ARGV[1]?} #{ARGV[2]?}" == "upload commit to"
#   # === {{CMD}} upload commit to remote_name
#   DA::Deploy.upload_commit_to_remote ARGV[3]

# when full_cmd[/^pg migrate .+/]?
#   # === {{CMD}} pg migrate [-args to psql] dir
#   DA.pg_migrate ARGV[2..-1]

# when full_cmd[/^sql inspect .+/]? && ARGV.size == 3
#   # === {{CMD}} sql inspect file.sql
#   DA.sql_inspect(ARGV.last)

# when full_cmd == "list windows"
#   # === {{CMD}} list windows
#   DA::Window.update_list
#   DA::Window.list.each { |w|
#     puts "#{w.id} #{w.focused?} #{w.title.inspect}"
#   }

