# frozen_string_literal: true

class UploadPolicy < ApplicationPolicy
  # Files attached to a visible project, plus the ones the user uploaded.
  class Scope < ApplicationPolicy::Scope
    def resolve
      return relation if user.admin?

      relation.where(item_id: visible_project_ids).or(relation.where(created_by: user.id))
    end
  end
end
