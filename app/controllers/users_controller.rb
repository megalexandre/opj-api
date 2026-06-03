# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :require_main_profile!
  before_action :set_user, only: [:destroy]

  def destroy
    raise ActiveRecord::RecordNotFound, 'Cannot delete your own account' if @user.id == current_user.id

    @user.destroy!
    head :no_content
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def require_main_profile!
    render json: { message: 'Forbidden' }, status: :forbidden unless current_user.profile == 'main'
  end
end
