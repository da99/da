
module DA

  struct Cache
    DIR = "/tmp/da_cache"

    getter prefix : String
    def initialize(@prefix)
    end # === def initialize(prefix : String)

    def write(k : String, v : String)
      FileUtils.mkdir_p(DIR)
      File.write(file_name(k), v)
    end # === def write

    def read(k)
      return nil unless exists?(k)
      File.read(file_name(k))
    end

    def read_or_write(k, default_value) : String
      if !exists?(k)
        write(k, default_value)
      end
      read(k).not_nil!
    end

    def exists?(k)
      File.file?( file_name(k) )
    end

    def file_name(k)
      File.join(DIR, "#{@prefix}.#{k}")
    end

  end # === class Cache
end # === module DA
