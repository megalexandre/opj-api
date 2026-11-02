# frozen_string_literal: true

class CustomerPolicy < ApplicationPolicy
  # Customers the user created, plus the clients of visible projects and services.
  class Scope < ApplicationPolicy::Scope
    def resolve
      return relation if user.admin?

      visible_ids.reduce(relation.where(created_by: user.id)) do |scope, ids|
        scope.or(relation.where(id: ids))
      end
    end

    private

    def visible_ids
      [
        Project.visible_to(user).select(:client_id),
        Service.visible_to(user).select(:customer_id)
      ]
    end
  end
end
