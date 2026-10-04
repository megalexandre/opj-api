# frozen_string_literal: true

class TechnicalDetailPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      return relation if user.admin?

      relation.where(project_id: visible_project_ids)
    end
  end
end
