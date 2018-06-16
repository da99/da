

require "da_redis"
if ENV["DEV_REDIS_PORT"]?
  DA_Redis.port ENV["DEV_REDIS_PORT"].to_i32
end
