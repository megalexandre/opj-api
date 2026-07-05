# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :require_main_profile!
  before_action :set_user, only: %i[destroy reset_password]

  def destroy
    raise ActiveRecord::RecordNotFound, 'Cannot delete your own account' if @user.id == current_user.id

    @user.destroy!
    head :no_content
  end

  def reset_password
    if @user.update(reset_password_params)
      render json: user_json(@user), status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_content
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def reset_password_params
    params.permit(:password, :password_confirmation)
  end

  def user_json(user)
    user.as_json(only: %i[id name email profile created_at updated_at])
  end

  def require_main_profile!
    render json: { message: 'Forbidden' }, status: :forbidden unless current_user.admin?
  end
end
