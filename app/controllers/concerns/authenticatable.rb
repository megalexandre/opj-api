# frozen_string_literal: true

module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  private

  def authenticate_user!
    token = extract_token_from_header
    payload = JsonWebToken.decode(token)
    @current_user = User.find(payload[:user_id])
    Current.user = @current_user
  rescue JWT::ExpiredSignature
    render json: { message: 'Token has expired' }, status: :unauthorized
  rescue JWT::DecodeError
    render json: { message: 'Invalid token' }, status: :unauthorized
  rescue ActiveRecord::RecordNotFound
    render json: { message: 'User not found' }, status: :unauthorized
  end

  def current_user
    @current_user
  end

  def extract_token_from_header
    header = request.headers['Authorization']
    raise JWT::DecodeError, 'Missing token' if header.blank?

    header.split.last
  end
end
