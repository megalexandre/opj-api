# frozen_string_literal: true

module JsonWebToken
  SECRET_KEY = ENV.fetch('JWT_SECRET_KEY') { Rails.application.secret_key_base }
  EXPIRY = 24.hours

  module_function

  def encode(payload, exp: EXPIRY.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY, 'HS256')
  end

  def decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: 'HS256' })
    HashWithIndifferentAccess.new(decoded.first)
  end
end
