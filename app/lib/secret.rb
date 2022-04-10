# frozen_string_literal: true

module Secret
  @cache = {}

  def self.[](key)
    @cache[key] ||= File.read("/var/run/secrets/#{key}").chomp
  end
end
