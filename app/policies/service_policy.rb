# frozen_string_literal: true

class ServicePolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      relation.visible_to(user)
    end
  end
end
