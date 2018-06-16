
module DA_Dev
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
end # === module DA_Dev
