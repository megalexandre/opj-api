# frozen_string_literal: true

class AddressPolicy < ApplicationPolicy
  # Addresses the user created, plus those of visible projects, services and their clients.
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
        projects.select(:address_id),
        services.select(:construction_address_id),
        services.select(:generating_address_id),
        clients.select(:address_id)
      ]
    end

    def clients
      Customer.where(id: projects.select(:client_id)).or(Customer.where(id: services.select(:customer_id)))
    end

    def projects
      Project.visible_to(user)
    end

    def services
      Service.visible_to(user)
    end
  end
end
