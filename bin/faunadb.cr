
ENV["FAUNADB_KEY"] = File.read("/progs/faunadb/key.txt").strip
cmd = ARGV.shift
Process.exec(cmd, ARGV)


