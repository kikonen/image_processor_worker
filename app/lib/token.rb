# frozen_string_literal: true

module Token
  USER_TOKEN_EXPIRE = 1.day
  SYSTEM_TOKEN_EXPIRE = 10.minutes

  DEV_ENV = Rails.env.development?
  TEST_ENV = Rails.env.test?
  PROD_ENV = Rails.env.production?

  def self.create_system_token
    secret = Secret['JWT_KEY']
    data = {
      system: true,
      exp: SYSTEM_TOKEN_EXPIRE.from_now.to_i,
    }
    jwt_token = JWT.encode(data, secret)
  end

  def self.create_user_token(user_id)
    secret = Secret['JWT_KEY']

    data = {
      user: user_id,
      exp: USER_TOKEN_EXPIRE.from_now.to_i,
    }
    jwt_token = JWT.encode(data, secret)
  end

  def self.parse_token(jwt_token)
    secret = Secret['JWT_KEY']
    data = JWT.decode(jwt_token, secret)
    Rails.logger.info(data)
    decoded = data[0]
    decoded.symbolize_keys!
  end
end
