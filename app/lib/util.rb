# frozen_string_literal: true

module Util
  DEV_ENV = Rails.env.development?
  TEST_ENV = Rails.env.test?
  PROD_ENV = Rails.env.production?
end
