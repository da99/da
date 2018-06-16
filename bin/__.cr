

require "../src/da"

module DA

  extend self

  def bin_dir
    File.dirname(Process.executable_path)
  end # === def apps_dir

end # === module DA

if 0 == ARGV.size
  DA.exit! 1, "!!! No arguments specified."
end

full_cmd = ARGV.map(&.strip).join(" ")
case

when "-h --help help".split.includes?(ARGV.first)
  # === {{CMD}} -h|--help|help
  substring = (ARGV[1]? || "").strip
  if substring.empty?
    DA.print_help
  else
    DA.print_help substring
  end

when full_cmd == "crystal install"
  # === {{CMD}} crystal install
  DA::Crystal.install

when ARGV[0]? == "crystal" && ARGV[1]?
  # === {{CMD}} crystal --args ...
  args = ARGV.clone
  DA::Crystal.crystal args.shift, args

when ARGV[0]? == "service" && ARGV[1]? && ARGV[2]?
  # === {{CMD}} service sv service
  DA::VoidLinux.service! ARGV[1], ARGV[2]

when "watch run" == "#{ARGV[0]?} #{ARGV[1]?}" && ARGV[2]?
  # === {{CMD}} watch run [file]
  DA::Dev.watch_run(ARGV[2])

when full_cmd == "backup"
  # === {{CMD}} backup
  DA.backup

when full_cmd == "update"
  # === {{CMD}} update
  DA::Git.update

when full_cmd == "status"
  # === {{CMD}} status
  DA::Git.status

when full_cmd == "development checkpoint"
  # === {{CMD}} development checkpoint
  DA::Git.development_checkpoint

when full_cmd == "watch"
  # === {{CMD}} watch
  DA::Dev.watch

when full_cmd == "deps"
  # === {{CMD}} deps
  DA::Crystal.deps

when full_cmd == "bin compile"
  # === {{CMD}} bin compile [release]
  DA::Crystal.bin_compile
when full_cmd == "bin compile release"
  DA::Crystal.bin_compile(["release"])

when full_cmd == "first-repo"
  # === {{CMD}} first-repo
  puts DA.first_repo

when full_cmd == "next-repo"
  # === {{CMD}} next-repo
  puts DA.next_repo

when full_cmd == "next-dirty-repo"
  # === {{CMD}} next-dirty-repo
  puts DA.next_dirty_repo

when ARGV[0..1].join(' ') == "cache read" && ARGV.size == 3
  # === {{CMD}} cache read KEY
  cache = DA::Cache.new("raw")
  cache.read ARGV[2]

when ARGV[0..1].join(' ') == "cache write" && ARGV.size == 4
  # === {{CMD}} cache write KEY VALUE
  cache = DA::Cache.new("raw")
  cache.write ARGV[2], ARGV[3]

when full_cmd == "git zsh_prompt"
  # === {{CMD}} git zsh_prompt
  puts DA::Git.zsh_prompt

# =============================================================================
# Deploy
# =============================================================================
when full_cmd == "generate release id"
  # === {{CMD}} generate release id
  puts DA::Release.generate_id

when full_cmd == "releases"
  # === {{CMD}} releases # Prints list of release in current working directory
  DA.releases(Dir.current).each { |dir|
    puts dir
  }

when full_cmd == "latest"
  # === {{CMD}} latest release
  puts DA::Release.latest!(Dir.current)

when full_cmd == "deploy init"
  # === {{CMD}} deploy init
  DA::Deploy.init

when full_cmd == "deploy init ssh"
  # === {{CMD}} deploy ssh
  DA::Deploy.init_ssh

when full_cmd == "deploy init www"
  # === {{CMD}} deploy init www
  DA::Deploy.init_www

when "#{ARGV[0]?} #{ARGV[1]?}" == "deploy remove" && ARGV[2]?
  # === {{CMD}} deploy remove app_name
  DA::App.new(ARGV[2]).remove!

when "#{ARGV[0]?} #{ARGV[1]?}" == "deploy Public" && ARGV[2]?
  # === {{CMD}} deploy Public service_name
  DA::Deploy.public(ARGV[2])

when full_cmd["upload shell config to "]?
  # === {{CMD}} upload shell config
  DA::Deploy.upload_shell_config_to(ARGV.last)

# =============================================================================
# Runit services:
# =============================================================================

when "service inspect" == "#{ARGV[0]?} #{ARGV[1]?}" && ARGV[2]?
  # === {{CMD}} service inspect dir_service
  service = DA::Runit.new(ARGV[2])
  {% for x in "name service_link latest_linked? app_dir pids latest".split %}
    puts "{{x.id}}:  #{service.{{x.id}}.inspect}"
  {% end %}
  if service.latest?
    puts "sv_dir:  #{service.sv_dir}"
  end

when "service down" == "#{ARGV[0]?} #{ARGV[1]?}" && ARGV[2]?
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
  puts "latest:     #{app.latest}"
  puts "releases:   #{app.releases.size}"
  puts "public dir: #{app.public_dir?}"
  puts "sv dir:     #{app.public_dir?}"

when "#{ARGV[0]?} #{ARGV[1]?} #{ARGV[2]?}" == "upload binary to"
  # === {{CMD}} upload binary to remote_name
  DA::Deploy.upload_binary_to_remote ARGV[3]

when "#{ARGV[0]?} #{ARGV[1]?} #{ARGV[2]?}" == "upload commit to"
  # === {{CMD}} upload commit to remote_name
  DA::Deploy.upload_commit_to_remote ARGV[3]


else
  DA.exit! 1, "!!! Invalid arguments: #{ARGV.map(&.inspect).join " "}"

end # case

