
module DA

  PGSQL_SEPARATOR = /\n\s*\#\s*\-+\n/

  module Postgres

    extend self

    PGPASS   = "#{ENV["HOME"]}/.pgpass"
    PG_CONF  = "/etc/postgresql/postgresql.conf"
    HBA_CONF = File.expand_path("#{THIS_DIR}/config/pg_hba.conf")
    ERRORS   = {} of String => String

    def setup
      setup_pgpass_file
      setup_hba_conf
      setup_pg_conf
      OS.create_system_user("web_app")

      if !ERRORS.empty?
        raise Error.new(ERRORS.values.join(", "))
      end
    end # === def setup

    def setup_hba_conf
      perm = File.stat(HBA_CONF).perm
      if perm > 420_u32
        ERRORS[HBA_CONF] = "Set permissions on #{HBA_CONF} to 0644 or lower"
        return false
      end

      DA_Dev.green! "=== {{#{HBA_CONF}}}: permissions BOLD{{0644}} or lower"
      true
    end # === def hba_conf

    def setup_pgpass_file
      perm = File.stat(PGPASS).perm
      if perm > 384_u32
        ERRORS[PGPASS] = "Set to 0600 or lower: #{PGPASS}"
        return false
      end

      DA_Dev.green! "=== {{#{PGPASS}}}: permissions BOLD{{0600}} or lower"
      true
    end # === def setup_pgpass_file

    def setup_pg_conf
      if !File.exists?(PG_CONF)
        ERRORS[PG_CONF] = "Not found: #{PG_CONF}"
        return false
      end

      lines = File.read(PG_CONF).lines
      hba_file_setting = lines.select { |x| x[/\Ahba_file\s+=\s+'#{HBA_CONF}'/]? }

      case
      when hba_file_setting.size == 1
        DA_Dev.green! "=== {{#{PG_CONF}}}: hba = 'BOLD{{#{HBA_CONF}}}'"

      when hba_file_setting.size > 1
        ERRORS[HBA_CONF] = "Too many repeats in #{PG_CONF}: #{HBA_CONF}"
        return false
      else
        ERRORS[HBA_CONF] = "Write in #{PG_CONF}: hba_file = '#{HBA_CONF}'"
        return false
      end

      tz_setting = lines.select { |x| x[/\Atimezone\s+=\s+'UTC'\Z/]? }
      case
      when tz_setting.size == 1
        DA_Dev.green! "=== {{#{PG_CONF}}}: timezone = 'BOLD{{UTC}}'"
      when tz_setting.size > 1
        ERRORS[HBA_CONF] = "Too many repeats in #{PG_CONF}: timezone"
        return false
      else
        ERRORS[HBA_CONF] = "Write in #{PG_CONF}: timezone = 'UTC'"
        return false
      end

      true
    end # === def setup_pg_conf

  end # === module Postgres

  struct PG

    getter name : String
    getter app  : App
    getter linked_dir : String
    getter latest : String?

    def initialize(@name)
      @app        = App.new(@name)
      @linked_dir = @app.dir("pg")
      @latest     = __latest = @app.latest("pg")
      @is_exist   = !!(__latest && File.directory?(__latest))
    end # === def initialize

    def user
      "pg-#{name}"
    end

    def group_socket
      "socket-#{name}"
    end

    def exists?
      @is_exist
    end

    def link!
      `ln -sf #{latest} #{linked_dir}`
    end # === def link!

  end # === struct PG

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
      psql(psql_args, f)
    }
  end # === def

  def sql_temp_file(filename : String, content : String)
    dir = File.dirname(filename)
    prepends = [
      File.expand_path(File.join dir, "../prepend.sql"),
      File.expand_path(File.join dir, "prepend.sql")
    ].map { |f|
      File.read(f) if File.exists?(f)
    }.compact

    full_script = (prepends + [content]).join('\n')
    temp_file = "/tmp/#{Time.now.epoch}.#{File.basename(filename)}.#{full_script.size}.sql"

    File.write(temp_file, full_script)
    begin
      yield temp_file
    ensure
      FileUtils.rm(temp_file) if File.exists?(temp_file)
    end
  end # def

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
      result = sql_temp_file(file, condition) { |temp_file|
        DA.output!("psql", final_args + ["-f", temp_file]).strip
      }

      if result.to_i != 0
        DA.orange! "=== {{Skipping}}: #{file} (#{result})"
      else
        sql_temp_file(file, run) { |temp_file|
          DA.system!("psql", final_args + ["-f", temp_file])
        }
      end
    end # if condition

    if always_run
      sql_temp_file(file, always_run) { |temp_file|
        DA.system!("psql", final_args + ["-f", temp_file])
      }
    end # if

  end # === def

end # === module DA_Dev
