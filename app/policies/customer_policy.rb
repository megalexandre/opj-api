# frozen_string_literal: true

class CustomerPolicy < ApplicationPolicy
  # Customers the user created, plus the clients of visible projects.
  class Scope < ApplicationPolicy::Scope
    def resolve
      return relation if user.admin?

      relation.where(created_by: user.id)
              .or(relation.where(id: Project.visible_to(user).select(:client_id)))
    end
  end
end
