# frozen_string_literal: true

Resque.logger = Logger.new(File.join(Rails.root, "log/resque_#{Rails.env}.log"))

# NOTE KI https://gist.github.com/Diasporism/5631030
Resque.redis = Redis.new(host: ENV['REDIS_HOST'], port: 6379)

Resque.logger.level = Logger::DEBUG
