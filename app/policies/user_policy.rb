# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      return relation if user.admin?

      relation.where(id: user.id)
    end
  end
end
