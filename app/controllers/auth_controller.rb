# frozen_string_literal: true

class AuthController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[register login]
  before_action :authorize_main!, only: :index

  def register
    user = User.new(register_params)
    user.save!
    render json: { token: JsonWebToken.encode({ user_id: user.id }), user: user_json(user) }, status: :created
  end

  def login
    user = User.find_by(email: login_params[:email]&.downcase)
    if user&.authenticate(login_params[:password])
      render json: { token: JsonWebToken.encode({ user_id: user.id }), user: user_json(user) }
    else
      render json: { message: 'Invalid email or password' }, status: :unauthorized
    end
  end

  def me
    render json: user_json(current_user)
  end

  def index
    users = User.all
    render json: users.map { |user| user_json(user) }
  end

  private

  def register_params
    params.permit(:name, :email, :profile, :password, :password_confirmation)
  end

  def login_params
    params.permit(:email, :password)
  end

  def user_json(user)
    user.as_json(only: %i[id name email profile created_at updated_at])
  end
end
