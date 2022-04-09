# frozen_string_literal: true

Thread.current.name = 'INIT' unless Thread.current.name

# config/boot.rb
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

# NOTE KI bootsnap crashes with segmentation fault
#require 'bootsnap/setup' # Speed up boot time by caching expensive operations.

# @see https://github.com/rails/rails/issues/28968#issuecomment-326437354
require 'rails/command'
require 'rails/commands/server/server_command'

# No stdout for logger
module Rails
  class Server < ::Rack::Server
    alias_method :orig_initialize, :initialize
    def initialize(options)
      orig_initialize(options.merge(log_stdout: false, AccessLog: []))
    end
  end
end

#
# HACK KI
# ActiveRecord::Railtie starts outputting to STDERR via "rails c"; forbid such malware
#
module ActiveSupport
  class Logger < ::Logger
    def self.logger_outputs_to?(logger, *sources)
      logdev = logger.instance_variable_get("@logdev")
      logger_source = logdev.dev if logdev.respond_to?(:dev)
      sources.any? { |source| source == logger_source || source == STDERR || source == STDOUT }
    end
  end
end
