full_cmd = ARGV.map(&.strip).join(' ')

bin = ARGV.first
args = ARGV[1..-1]

{bin, "my_#{bin}", "#{bin}_setup"}.each { |name|
  file = "/apps/#{name}/bin/#{name}"
  if File.executable?(file)
    Process.exec(file, args)
  end # case
}

STDERR.puts "!!! Nothing found for #{bin}."
Process.exit 2
