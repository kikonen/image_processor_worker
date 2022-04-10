# frozen_string_literal: true

# NOTE KI https://gist.github.com/Diasporism/5631030
Resque.redis = Redis.new(host: ENV['REDIS_HOST'], port: 6379)
