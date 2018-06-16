

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

else
  DA.exit! 1, "!!! Invalid arguments: #{ARGV.map(&.inspect).join " "}"

end # case

