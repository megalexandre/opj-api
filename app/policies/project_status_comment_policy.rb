# frozen_string_literal: true

class ProjectStatusCommentPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      return relation if user.admin?

      relation.where(project_status_id: ProjectStatus.where(project_id: visible_project_ids).select(:id))
    end
  end
end
