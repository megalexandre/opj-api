# frozen_string_literal: true

module CucumberAuthHelpers
  def auth_header_for(user)
    "Bearer #{JsonWebToken.encode({ user_id: user.id })}"
  end

  def set_auth_header(user)
    @current_user = user
    header 'Authorization', auth_header_for(user)
  end
end

World(CucumberAuthHelpers)
