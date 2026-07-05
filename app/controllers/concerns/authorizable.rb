# frozen_string_literal: true

module Authorizable
  extend ActiveSupport::Concern

  class ForbiddenError < StandardError
  end

  private

  def apply_access_scope(scope)
    return scope if current_user.admin?

    scope.where(created_by: current_user.id)
  end

  def authorize_record!(record)
    return if current_user.admin?
    raise ActiveRecord::RecordNotFound unless record.created_by == current_user.id
  end

  def authorize_main!
    raise ForbiddenError, 'Forbidden' unless current_user.admin?
  end

  def authorize_view!(record)
    raise ActiveRecord::RecordNotFound unless record.visible_to?(current_user)
  end

  def authorize_project_participant!(project)
    return if current_user.admin?
    raise ActiveRecord::RecordNotFound unless project.visible_to?(current_user)
  end
end
