
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
require "../src/da/Script"
require "../src/da/OS"
require "../src/da/Linux"

full_cmd = ARGV.map(&.strip).join(" ")

DA::CLI.parse do |o|
  o.desc "fs list usb drives"
  o.run_if(full_cmd == "list usb drives") {
    DA::File_System.usb_drives.each { |x|
      puts x
    }
  }

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
    repos = [repo.parent_dir].concat(ARGV[3..-1]).
      uniq.
      map { |dir| DA::Git::Repos.new(dir).repos }.
      flatten
    DA.round_about(repos, ->(r : DA::Git::Repo) { r.dir == repo.dir }) { |r|
      if r.dirty?
        puts r.dir
        exit 0
      end
    }
    DA.green! "All repos {{clean}}."
  }

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

  o.desc "build"
  o.run_if(full_cmd == "build") {
    langs = DA::Dev.build
    if langs.empty?
      DA.red! "!!! No acceptable languages."
      exit 1
    end
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

case

# === File_System =============================================================



# =============================================================================

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

# when full_cmd == "crystal install"
#   # === {{CMD}} crystal install
#   DA::Crystal.install

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

when full_cmd[/^script run .+/]? && ARGV.size == 3
  # === {{CMD}} script run file
  file = ARGV.last
  DA::Script.new(file).run

# when full_cmd == "list windows"
#   # === {{CMD}} list windows
#   DA::Window.update_list
#   DA::Window.list.each { |w|
#     puts "#{w.id} #{w.focused?} #{w.title.inspect}"
#   }

else

end # case

