
require "yaml"

case ARGV[0]?
when "version"
  data = YAML.parse File.read("shard.yml")
  version = data["version"]? || raise Exception.new("No version in shard.yml found.")
  puts version

when "bump"
  if !`git status --porcelain`.strip.empty?
    STDERR.puts "!!! repo is not clean"
    exit 2
  end

  shard_yml = File.read("shard.yml")
  matched = shard_yml.match(/^version:\s+([0-9\.]+)$/m).not_nil!
  version = matched[1]?.not_nil!

  pieces = version.to_s.split(".")
  major = pieces.shift.to_i
  minor = pieces.shift.to_i
  patch = pieces.shift.to_i

  case ARGV[1]?
  when "major"
    major += 1
    minor = 0
    patch = 0
  when "minor"
    minor += 1
    patch = 0
  when "patch"
    patch += 1
  else
    raise Exception.new("Invalid bump: #{ARGV[1]?.inspect}")
  end

  new_ver = "#{major}.#{minor}.#{patch}"
  File.write("shard.yml", shard_yml.sub(matched[0], "version: #{new_ver}") )

else
  if ARGV.empty?
    raise Exception.new("Invalid request: [no options specified]")
  else
    raise Exception.new("Invalid request: #{ARGV.map(&.inspect).join(" ")}")
  end
end
