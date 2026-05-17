# frozen_string_literal: true

module AuthHelpers
  def auth_token_for(user)
    "Bearer #{JsonWebToken.encode({ user_id: user.id })}"
  end
end

RSpec.shared_context 'with auth token' do
  let(:user)          { create(:user) }
  let(:Authorization) { "Bearer #{JsonWebToken.encode({ user_id: user.id })}" }

  before { Current.user = user }
  after  { Current.user = nil }
end
