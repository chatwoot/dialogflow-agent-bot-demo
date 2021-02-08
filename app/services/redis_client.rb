class RedisClient
  def self.client
    Redis.new(url: ENV.fetch('REDIS_URL', 'redis://localhost:6379'))
  end
end
