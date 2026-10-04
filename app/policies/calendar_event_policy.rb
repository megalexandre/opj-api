# frozen_string_literal: true

class CalendarEventPolicy < ApplicationPolicy
  # Records of any project visible to the user, plus the ones they created.
  class Scope < ApplicationPolicy::Scope
    def resolve
      return relation if user.admin?

      relation.where(project_id: visible_project_ids).or(relation.where(created_by: user.id))
    end
  end
end
