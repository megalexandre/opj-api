# frozen_string_literal: true

class AddressPolicy < ApplicationPolicy
  # Addresses the user created, plus those of visible projects and their clients.
  class Scope < ApplicationPolicy::Scope
    def resolve
      return relation if user.admin?

      relation.where(created_by: user.id)
              .or(relation.where(id: projects.select(:address_id)))
              .or(relation.where(id: Customer.where(id: projects.select(:client_id)).select(:address_id)))
    end

    private

    def projects
      Project.visible_to(user)
    end
  end
end
