

require "../src/da"

module DA

  extend self

  def bin_dir
    File.dirname(Process.executable_path)
  end # === def apps_dir

end # === module DA


case ARGV.size
when 0
  DA.exit! 1, "!!! No arguments specified."
else
  full = ARGV.map(&.strip).join(" ")
  case
  when "-h --help help".split.includes?(ARGV.first)
    # === {{CMD}} -h|--help|help
    substring = (ARGV[1]? || "").strip
    if substring.empty?
      DA::Help.print
    else
      DA::Help.print substring
    end
  else
    DA.exit! 1, "!!! Invalid arguments: #{ARGV.map(&.inspect).join " "}"
  end
end # case

