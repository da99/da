

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
  when "-h --help help".split.includes?(full)
    # === {{CMD}} -h|--help|help
    DA::Help.print
  else
    DA.exit! 1, "!!! Invalid arguments: #{ARGV.map(&.inspect).join " "}"
  end
end # case

