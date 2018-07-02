
module DA

  PGSQL_SEPARATOR = /\n\s*\#\s*\-+\n/

  def pg_migrate(args : Array(String))
    dirs = [] of String
    while args.last? && File.directory?(args.last?.not_nil!)
      dirs.unshift args.pop
    end # while

    psql_args = args

    dirs.map { |dir|
      raise DA::Exit.new(1, "Directory not found: #{dir.inspect}") if !File.directory?(dir)
      Dir.glob(File.join dir, "*.sql").sort
    }.flatten.sort { |a, b| File.basename(a) <=> File.basename(b) }.each { |f|
      contents = File.read(f)
      psql(psql_args, f)
    }
  end # === def

  def psql(args : Array(String), file : String)
    final_args = %w[
      --dbname=template1
      --tuples-only
      --no-align
      --set ON_ERROR_STOP=on
      --set AUTOCOMMIT=off
    ].concat(args)

    blocks = DA::SQL_Sections.new( File.read(file) )

    condition  = blocks.condition
    run        = blocks.run
    always_run = blocks.always_run

    if condition && run
      result = DA.output!("psql", final_args + ["-c", condition]).strip
      if result.to_i != 0
        DA.orange! "=== {{Skipping}}: #{file} (#{result})"
      else
        DA.system!("psql", final_args + ["-c", run])
      end
    end # if condition

    if always_run
      DA.system!("psql", final_args + ["-c", always_run])
    end
  end # === def

end # === module DA
