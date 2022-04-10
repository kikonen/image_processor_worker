# frozen_string_literal: true

module Util
  DEV_ENV = Rails.env.development?
  TEST_ENV = Rails.env.test?
  PROD_ENV = Rails.env.production?

  OJ_ENCODE_OPT = {
    mode: :json,
    use_as_json: true,
    escape_mode: :json,
  }.freeze

  OJ_DECODE_OPT = {
    symbol_keys: true,
    mode: :strict,
  }.freeze

  def self.encode_json(data)
    data.nil? ? nil : Oj.dump(data, OJ_ENCODE_OPT)
  end

  def self.decode_json(json)
    json.nil? ? nil : Oj.load(json, OJ_DECODE_OPT)
  end
end
