

module DA

  POOL_CLIENTS = Array(Redis::PooledClient).new

  def self.redis_socket_path(conf_path : String)
    File.read(conf_path).lines.reverse.each { |l|
      next unless l[/^unixsocket /]?
        return l.split.last
    }
    raise "Redis socket not found!"
  end # def

  def self.new_redis(conf_path)
      socket = redis_socket_path(conf_path)
      DA.inspect! "=== Connecting to: #{socket}"
      rp = Redis::PooledClient.new(unixsocket: socket)
      POOL_CLIENTS << rp
      rp
  end # def

end # === module

at_exit { DA::POOL_CLIENTS.each { |x| x.close } }
