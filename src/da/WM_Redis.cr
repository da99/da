
module DA
  class WM_Redis

    def self.socket_path(conf_path : String)
      File.read(conf_path).lines.reverse.each { |l|
        next unless l[/^unixsocket /]?
        return l.split.last
      }
      raise "Redis socket not found!"
    end # def

    # =============================================================================
    # Instance:
    # =============================================================================

    getter redis_pool : Redis::PooledClient

    delegate del, get, set, lpush, rpush, lpop, to: @redis_pool

    def initialize(conf_path)
      socket = WM_Redis.socket_path(conf_path)
      DA.inspect! "=== Connecting to: #{socket}"
      rp = @redis_pool = Redis::PooledClient.new(unixsocket: socket)
      at_exit { rp.close }
    end # def

    def push(s : String)
      redis_pool.rpush("wm_commands", s.split.join(' '))
    end # def

    def get_windows(k : String)
        raw = redis_pool.get(k)
        v = Hash(String, Array(String)).new
        if raw
          raw.split('|').each { |raw_group|
            group_name, raw_windows = raw_group.split(':')
            v[group_name] = raw_windows.split(',')
          }
        end
        v
    end # def

    def next
      redis_pool.lpop("wm_commands")
    end # def

    def set(k, v : Hash(String, Array(Window)))
      io = IO::Memory.new
      v.map { |group_name, windows|
        "#{group_name}:#{windows.map { |x| x.focus? ? "*#{x.id}" : x.id}.join ','}"
      }.join('|', io)
      set(k, io.to_s)
    end # def

  end # === class
end # === module
