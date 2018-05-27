

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

when full_cmd == "first-repo"
  # === {{CMD}} first-repo
  puts DA.first_repo

when full_cmd == "next-repo"
  # === {{CMD}} next-repo
  puts DA.next_repo

when full_cmd == "next-dirty-repo"
  # === {{CMD}} next-dirty-repo
  puts DA.next_dirty_repo

else
  DA.exit! 1, "!!! Invalid arguments: #{ARGV.map(&.inspect).join " "}"

end # case

