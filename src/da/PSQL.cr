
module DA

  PGSQL_SEPARATOR = /\n\s*\#\s*\-+\n/

  def pg_migrate(args : Array(String))
    dirs = [] of String
    while args.last? && File.directory?(args.last?.not_nil!)
      dirs.unshift args.pop
    end # while

    psql_args = args

    if dirs.empty?
      raise DA::Exit.new(1, "No valid dirs found at the end of argument list: #{args.join ' '}")
    end # if

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

    temp_file = "/tmp/#{Time.now.epoch}.#{File.basename(file)}.sql"

    begin
      if condition && run
        File.write(temp_file, condition)
        result = DA.output!("psql", final_args + ["-f", temp_file]).strip
        if result.to_i != 0
          DA.orange! "=== {{Skipping}}: #{file} (#{result})"
        else
          File.write(temp_file, run)
          DA.system!("psql", final_args + ["-f", temp_file])
        end
      end # if condition

      if always_run
        File.write(temp_file, always_run)
        DA.system!("psql", final_args + ["-f", temp_file])
      end
    ensure
      FileUtils.rm(temp_file) if File.exists?(temp_file)
    end

  end # === def

end # === module DA
