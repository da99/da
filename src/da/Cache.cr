
module DA
  CACHE_DIR = "/tmp/da_cache"

  def cache_write(k : String, v : String)
    FileUtils.mkdir_p(CACHE_DIR)
    File.write(cache_file_name(k), v)
  end # === def write

  def cache_read(k)
    return nil unless cache_exists?(k)
    File.read(cache_file_name(k))
  end

  def cache_read_or_write(k, default_value)
    return read(k) if cache_exists?(k)
    cache_write(k, default_value)
    cache_read(k)
  end

  def cache_exists?(k)
    File.file?( cache_file_name(k) )
  end

  def cache_file_name(k)
    File.join(CACHE_DIR, k)
  end
end # === module DA
