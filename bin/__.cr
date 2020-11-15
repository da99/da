
require "../src/da"
# require "../src/da/Window"
require "../src/da/Network"
require "../src/da/Mouse_Pointer"

module DA

  extend self

  def bin_dir
    File.dirname(Process.executable_path)
  end # === def apps_dir

end # === module DA

if 0 == ARGV.size
  DA.red! "!!! BOLD{{No arguments specified}}."
  exit 1
end

full_cmd = ARGV.map(&.strip).join(" ")

case

when "-h --help help".split.includes?(ARGV.first)
  # === {{CMD}} -h|--help|help
  DA.print_help


when full_cmd["list usb drives"]?
  DA.cli_list_usb_drives

when ARGV.size == 3 && full_cmd["set volume "]?
  DA::OS.set_volume(ARGV.last)

when full_cmd[/^run max \d+ .+/]?
  # === {{CMD}} run max [seconds] cmd -with -args
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

# when full_cmd == "move mouse pointer to scroll bar"
#   # === {{CMD}} move mouse pointer to scroll bar
#   DA::Window.update_list
#   win = DA::Window.focused
#   if win
#     geo = win.geo
#     if geo
#       mp = DA::Mouse_Pointer.new
#       new_x = geo.x + geo.w - 5
#       new_y = 0
#       scroll_movement = (geo.h / 10).to_i
#       if scroll_movement > 10
#         if mp.x == new_x
#           new_y = mp.y + scroll_movement
#         else
#           new_y = geo.y + scroll_movement
#         end
#         DA.system! "xdotool mousemove --clearmodifiers #{new_x} #{new_y}"
#       else
#         DA.orange! "--- Scroll movement is too small: #{scroll_movement}"
#       end
#     else
#       puts "no geo found."
#     end
#   else
#     puts "no focused window"
#   end


when full_cmd[/^run .+/]?
  # === {{CMD}} run my cmd -with -args
  args = ARGV[1..-1]
  DA::Process::Inherit.new(args).success!

when "watch run" == "#{ARGV[0]?} #{ARGV[1]?}" && ARGV[2]?
  # === {{CMD}} watch run [file]
  DA::Dev.watch_run(ARGV[2])

when full_cmd == "backup"
  # === {{CMD}} backup
  DA.backup

when full_cmd == "update"
  # === {{CMD}} update
  DA::Git.update

when full_cmd == "git is clean"
  # === {{CMD}} update
  if DA::Git::Repo.new(Dir.current).clean?
    exit 0
  end
  exit 1

when full_cmd == "git status"
  # === {{CMD}} status
  DA::Process::Inherit.new("git status").success!
  repo = DA::Git::Repo.new(Dir.current)
  errs = repo.errors
  errs.each { |e| DA.red!(e) }
  exit 0 if errs.empty?
  exit 1

when full_cmd["git commit"]?
  # === {{CMD} git commit ...
  repo = DA::Git::Repo.new(Dir.current)
  if repo.staged?
    DA::Process.new(ARGV).success!
    exit 0
  end

  DA.red! "!!! Nothing has been {{staged}}."
  DA::Process::Inherit.new("git status".split)
  exit 1

when full_cmd[/\Agit\ +committed\?\Z/]?
  # === {{CMD}} git committed?
  if !DA::Git::Repo.new(Dir.current).commit_pending?
    exit 0
  end
  exit 1

when full_cmd[/\Agit\ +?commit\ +pending\??\Z/]?
  # === {{CMD}} commit pending
  if DA::Git::Repo.new(Dir.current).commit_pending?
    exit 0
  end
  exit 1

when full_cmd == "development checkpoint"
  # === {{CMD}} development checkpoint
  DA::Git::Repo.new(Dir.current).development_checkpoint

when full_cmd[/^commit .+/]?
  # === {{CMD}} commit ...args
  ARGV.shift
  DA::Git::Repo.new(Dir.current).commit ARGV

when full_cmd == "watch"
  # === {{CMD}} watch
  DA::Dev.watch

# =============================================================================

when full_cmd == "specs compile"
  # === {{CMD}} specs compile
  DA::Specs.compile

when ARGV[0..2].join(' ') == "specs compile run"
  # === {{CMD}} specs compile run
  DA::Specs.compile
  DA::Specs.run ARGV[3..-1]

# === File_System =============================================================

when ["is development", "is dev"].includes?(full_cmd)
  # === {{CMD}} is development
  if DA.development?
    exit 0
  else
    exit 1
  end

when ARGV[0..1].join(' ') == "link symbolic!" && ARGV[2]? && ARGV[3]? && !ARGV[4]?
  # === {{CMD}} link symbolic
  DA.symlink!(ARGV[2], ARGV[3])

# =============================================================================

when ARGV[0]? == "exec"
  # === {{CMD}} exec ...
  args = ARGV.clone
  args.shift
  if args.empty?
    DA.orange! "no arguments found."
    exit 1
  end
  cmd = args.shift
  DA.orange! "{{#{cmd}}} BOLD{{#{args.join ' '}}}"
  ::Process.exec(cmd, args)

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

when full_cmd =~ /^bin compile( .+)?$/
  # === {{CMD}} bin compile [args to compile]
  DA::Dev.bin_compile(ARGV[2..-1])

when full_cmd["first dirty repo"]?
  # === {{CMD}} next dirty repo DIR
  DA::Git::Repos.new(ARGV.last).repos.find { |r| r.dirty? }.try { |r| puts r.dir }

when full_cmd["next dirty repo"]?
  # === {{CMD}} next dirty repo DIR
  DA::Git::Repo.new(ARGV.last).next { |r| r.dirty? }.try { |r| puts r.dir }

# when ARGV[0..1].join(' ') == "cache read" && ARGV.size == 3
#   # === {{CMD}} cache read KEY
#   cache = DA::Cache.new("raw")
#   cache.read ARGV[2]

# when ARGV[0..1].join(' ') == "cache write" && ARGV.size == 4
#   # === {{CMD}} cache write KEY VALUE
#   cache = DA::Cache.new("raw")
#   cache.write ARGV[2], ARGV[3]

when full_cmd == "git zsh_prompt"
  # === {{CMD}} git zsh_prompt
  puts DA::Git.zsh_prompt

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

# =============================================================================
# Linux:
# =============================================================================
when full_cmd[/^create system user .+$/]?
  # === {{CMD}} create system user ...
  DA::Linux.useradd_system(ARGV.last)

# =============================================================================
# Void Linux:
# =============================================================================
when full_cmd == "voidlinux upgrade"
  # === {{CMD}} voidlinux upgrade
  DA::VoidLinux.upgrade

# =============================================================================
# Runit services:
# =============================================================================

when "service inspect" == "#{ARGV[0]?} #{ARGV[1]?}" && ARGV[2]?
  # === {{CMD}} service inspect dir_service
  service = if File.directory?(ARGV[2])
              DA::Runit.new(File.basename(ARGV[2]), ARGV[2], ARGV[2])
            else
              DA::Runit.new(ARGV[2])
            end
  puts "name        #{service.name.inspect}"
  puts "sv_dir      #{service.sv_dir.inspect}"
  puts "service_dir #{service.service_dir.inspect}"
  puts "pids        #{service.pids.inspect}"
  puts "status      #{service.status.inspect}"
  puts "run?        #{service.run?.inspect}"
  puts "down?       #{service.down?.inspect}"
  puts "exit?       #{service.exit?.inspect}"

when "service down" == "#{ARGV[0]?} #{ARGV[1]?}" && ARGV[2]? && !ARGV[3]?
  # === {{CMD}} service down dir_service
  DA::Runit.new(ARGV[2]).down!

when "service up" == "#{ARGV[0]?} #{ARGV[1]?}" && ARGV[2]?
  # === {{CMD}} service up dir_service
  DA::Runit.new(ARGV[2]).up!

when "inspect" == ARGV[0]? && ARGV[1]? && !ARGV[2]?
  # === {{CMD}} inspect app_name
  app = DA::App.new(ARGV[1])

  puts "name:       #{app.name}"
  puts "dir:        #{app.dir}"
  puts "latest:     #{DA::Release.latest(app).inspect}"
  puts "releases:   #{DA::Release.list(app).inspect}"

when "#{ARGV[0]?} #{ARGV[1]?} #{ARGV[2]?}" == "upload binary to"
  # === {{CMD}} upload binary to remote_name
  DA::Deploy.upload_binary_to_remote ARGV[3]

when "#{ARGV[0]?} #{ARGV[1]?} #{ARGV[2]?}" == "upload commit to"
  # === {{CMD}} upload commit to remote_name
  DA::Deploy.upload_commit_to_remote ARGV[3]

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

when full_cmd == "network time"
  # === {{CMD}}
  puts DA::Network.time

else
  DA.red! "!!! {{Invalid arguments}}: #{ARGV.map(&.inspect).join " "}"
  exit 1

end # case

