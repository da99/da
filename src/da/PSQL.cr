
module DA

  PGSQL_SEPARATOR = /\n\s*\#\s*\-+\n/

  def psql_default_args
    %w[
      --dbname=template1
      --tuples-only
      --no-align
      --set ON_ERROR_STOP=on
      --set AUTOCOMMIT=off
    ]
  end # === def

  def pg_migrate(args : Array(String))
    head = [] of String
    tail = [] of String
    dashes_found = false
    args.each { |x|
      case
      when x == "--"
        dashes_found = true
      when dashes_found
        tail.push x
      else
        head.push x
      end
    }

    dirs = if dashes_found
             tail
           else
             head
           end

    psql_args = if dashes_found
             head
           else
             [] of String
           end

    dirs.each { |dir|
      raise DA::Exit.new(1, "Directory not found: #{dir.inspect}") if !File.directory?(dir)
      Dir.glob(File.join dir, "*.sql").sort.each { |f|
        contents = File.read(f)
        if File.read(f)[PGSQL_SEPARATOR]?
          psql(([] of String).concat(psql_args).concat(["-f", f]))
        else
          DA.system! "psql", psql_default_args.concat(psql_args).concat(["-f", f])
        end
      }
    }
  end # === def

  def psql(args : Array(String))
    file_found = false
    file = nil
    args = args.map { |x|
      case
      when x == "-f"
        file_found = true
        nil
      when x["--file="]?
        file = x.sub("--file=", "")
        nil
      when file_found
        file = x
        nil
      else
        x
      end
    }.compact

    final_args = psql_default_args.concat(args)
    if !file
      raise DA::Exit.new(1, "File not found.")
    end

    if !File.exists?(file)
      raise DA::Exit.new(1, "File does not exist: #{file.inspect}")
    end

    blocks = File.read(file).split(PGSQL_SEPARATOR)
    if blocks.size != 2
      raise DA::Exit.new(1, "Invalid number of blocks in file, #{file}: #{blocks.size}")
    end

    cond = blocks.first
    sql = blocks.last
    result = DA.output!("psql", final_args + ["-c", cond]).strip
    if result == "1"
      DA.orange! "=== {{Skipping}}: #{file}"
    else
      DA.system!("psql", final_args + ["-c", sql])
    end
  end # === def

end # === module DA
