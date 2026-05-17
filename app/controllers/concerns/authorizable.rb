# frozen_string_literal: true

module Authorizable
  extend ActiveSupport::Concern

  private

  def apply_access_scope(scope)
    return scope if current_user.profile == 'main'

    scope.where(created_by: current_user.id)
  end

  def authorize_record!(record)
    return if current_user.profile == 'main'
    raise ActiveRecord::RecordNotFound unless record.created_by == current_user.id
  end
end
