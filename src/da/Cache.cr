
module DA

  struct Cache
    DIR = if DA.development?
            "/tmp/da_cache"
          else
            "/deploy/da_cache"
          end

    getter prefix : String
    def initialize(@prefix)
    end # === def initialize(prefix : String)

    def delete(k : String)
      f = file_name(k)
      if File.exists?(f)
        File.delete(f)
        true
      else
        false
      end
    end

    def write(k : String, v : String)
      if !Dir.exists?(DIR)
        FileUtils.mkdir_p(DIR)
        # Process.run("chmod", ["o+rXw", DIR])
      end
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
